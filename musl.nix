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

      # Tests are so flaky...
      git = super.git.overrideAttrs { doInstallCheck = false; };

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

      # checks fail on musl
      rsync = super.rsync.overrideAttrs {
        doCheck = false;
      };
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
