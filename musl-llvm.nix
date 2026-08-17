{ pkgs, lib, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.stdenv.hostPlatform.system; });
in
{
  imports = [
    ./musl.nix
  ];
  nixpkgs.overlays = [
    (self: super: {
      ## Prevents accidental runtime linkage to llvm bintools
      # gnugrep = super.gnugrep.override { runtimeShellPackage = self.runCommand "neutered" { } "mkdir -p $out"; };

      libressl = super.libressl.overrideAttrs (old: {
        doCheck = false;
      });

      libapparmor = super.libapparmor.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          sed -i 's/char buff\[total_size\];/char buff[];/' src/kernel.c
        '';
      });


      #libapparmor = super.libapparmor.overrideAttrs (old: {
      #  # gnu23 rejects `char buff[total_size];` inside a struct and the
      #  # externally_visible attribute.  gnu17 keeps the GNU extension and
      #  # the build stays the same.
      #  env.NIX_CFLAGS_COMPILE = "-std=gnu17 -Wno-unknown-attributes";
      #});

      #coreutils = super.coreutils.overrideAttrs {
      #  doCheck = false;
      #};

      ## https://github.com/NixOS/nixpkgs/pull/445833
      #netbsd = super.netbsd.overrideScope (
      #  _final: prev: {
      #    compat = prev.compat.overrideAttrs (old: { makeFlags = old.makeFlags ++ [ "OBJCOPY=${glibcPkgs.binutils}/bin/strip" ]; });
      #  }
      #);
      #pam = super.pam.overrideAttrs {
      #  NIX_LDFLAGS = lib.optionalString (super.stdenv.cc.bintools.isLLVM && lib.versionAtLeast super.stdenv.cc.bintools.version "17") "--undefined-version";
      #};
    })
  ];
}
