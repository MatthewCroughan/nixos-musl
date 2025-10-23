{ pkgs, lib, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
in
{
  # Fails to build, and doesn't make sense on musl anyway
  services.nscd.enableNsncd = false;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  # wrappers use pkgsStatic which has issues on native musl at this time
  security.enableWrappers = pkgs.stdenv.buildPlatform.isGnu;

  # stub-ld doesn't make sense with musl
  environment.stub-ld.enable = false;

  # Fails unless neutered error: expected a set but found null: null
  i18n.glibcLocales = pkgs.runCommandNoCC "neutered" { } "mkdir -p $out";

  # 206/OOM_Adjust crashes for Systemd v258 when using musl
  # https://github.com/systemd/systemd/pull/38825#issuecomment-3391312797
  systemd.units = {
    "service.d/10-unset-oom-score.conf".text = ''
      [Service]
      OOMScoreAdjust=
    '';
  };
  boot.initrd.systemd.units = {
    "service.d/10-unset-oom-score.conf".text = ''
      [Service]
      OOMScoreAdjust=
    '';
  };
  systemd.user.units = {
    "service.d/10-unset-oom-score.conf".text = ''
      [Service]
      OOMScoreAdjust=
    '';
    "socket.d/10-unset-oom-score.conf".text = ''
      [Socket]
      OOMScoreAdjust=
    '';
  };

  nixpkgs.overlays = [
    (self: super: {
      # qemu doesn't build for musl, and if we want to run the
      # config.system.build.vm, we need a glibc qemu, doens't impact anything
      # else
      qemu = glibcPkgs.qemu;

      # But the qemu_test binary is fine on musl
      qemu_test = super.qemu;

      # python3-fb-re2 fails
      mercurial = super.mercurial.override {
        re2Support = false;
      };

      perlPackages = super.perlPackages // {
        # https://github.com/NixOS/nixpkgs/pull/451665
        Test2Harness = super.perlPackages.Test2Harness.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
        ## https://github.com/NixOS/nixpkgs/pull/452642
        #DBI = super.perlPackages.DBI.overrideAttrs (oldAttrs: {
        #  env = {
        #    NIX_CFLAGS_COMPILE =
        #      lib.optionalString super.stdenv.cc.isGNU "-Wno-error=incompatible-pointer-types"
        #      + lib.optionalString super.stdenv.hostPlatform.isMusl " -Doff64_t=off_t";
        #   };
        #});
      };

      # Tests are so flaky...
      git = super.git.overrideAttrs { doInstallCheck = false; };

      # audit doesn't build on musl yet
      pam = super.pam.override { withAudit = false; };
      dbus = super.dbus.overrideAttrs (old: {
        configureFlags = (lib.remove "--enable-libaudit" old.configureFlags) ++ [
        ];
        buildInputs = (lib.remove super.audit old.buildInputs);
      });
      systemd = (super.systemd.override {
        withAudit = false;
      });

      # https://github.com/NixOS/nixpkgs/pull/451147
      diffutils = super.diffutils.overrideAttrs (old: {
        postPatch =
          if (super.stdenv.buildPlatform.isGnu && super.stdenv.hostPlatform.isMusl) then
      ''
        sed -i -E 's:test-getopt-gnu::g' gnulib-tests/Makefile.in
        sed -i -E 's:test-getopt-posix::g' gnulib-tests/Makefile.in
      '' else null;
      });

      # https://github.com/NixOS/nixpkgs/pull/451506
      python3 = super.python3.override {
        packageOverrides = pyfinal: pyprev: {
          pytest = pyprev.pytest.overrideAttrs {
            dontWrapPythonPrograms = false;
          };
        };
      };

      # time patch can be removed when https://github.com/NixOS/nixpkgs/pull/447166
      time = super.time.overrideAttrs {
        patches = [
          "${super.pkgs.path}/pkgs/by-name/ti/time/time-1.9-implicit-func-decl-clang.patch"
        ];
      };

      # checks fail on musl
      rsync = super.rsync.overrideAttrs {
        doCheck = false;
      };

      # checks fail on musl
      texinfoInteractive = super.texinfoInteractive.overrideAttrs {
        doCheck = false;
      };

      # https://github.com/NixOS/nixpkgs/pull/446139
      onetbb = super.onetbb.overrideAttrs (old: {
        doCheck = false;
        patches = old.patches ++ [
          # Fix build with gcc15
          # <https://github.com/uxlfoundation/oneTBB/pull/1831>
          # https://github.com/NixOS/nixpkgs/pull/446139
          (super.fetchpatch {
            name = "onetbb-fix-gcc15-build.patch";
            url = "https://github.com/uxlfoundation/oneTBB/commit/712ad98443300aab202f5e93a76472d59b79752a.patch";
            hash = "sha256-4qoVCy3xQZK6Vp471miE79FSrU0D0Iu6KWMJ08m0EsE=";
          })
        ];
      });
    })
  ];

  # These options sometimes work, and sometimes don't, because of perl
  nix.enable = lib.mkForce false;
  system = {
    tools.nixos-generate-config.enable = lib.mkForce false;
    switch.enable = lib.mkForce false;
    disableInstallerTools = lib.mkForce false;
    tools.nixos-option.enable = lib.mkForce false;
  };
  documentation = {
    enable =  false;
    doc.enable =  false;
    info.enable =  false;
    man.enable =  false;
    nixos.enable =  false;
  };
}
