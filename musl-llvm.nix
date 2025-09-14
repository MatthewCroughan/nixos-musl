{ pkgs, lib, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
in
{
  imports = [
    ./musl.nix
  ];
  nixpkgs.overlays = [
    (self: super: {
      # Prevents accidental runtime linkage to llvm bintools
      gnugrep = super.gnugrep.override { runtimeShellPackage = self.runCommandNoCC "neutered" { } "mkdir -p $out"; };

      dbus = super.dbus.overrideAttrs (old: { configureFlags = old.configureFlags ++ [ "--disable-libaudit" "--disable-apparmor" ]; });
      libcap = super.libcap.override { withGo = false; };

      # https://github.com/NixOS/nixpkgs/pull/445833
      netbsd = super.netbsd.overrideScope (
        _final: prev: {
          compat = prev.compat.overrideAttrs (old: { makeFlags = old.makeFlags ++ [ "OBJCOPY=${glibcPkgs.binutils}/bin/strip" ]; });
        }
      );
      pam = super.pam.overrideAttrs {
        NIX_LDFLAGS = lib.optionalString (super.stdenv.cc.bintools.isLLVM && lib.versionAtLeast super.stdenv.cc.bintools.version "17") "--undefined-version";
      };
    })
  ];
}
