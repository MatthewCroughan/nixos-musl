{ modulesPath, pkgs, lib, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];

  fileSystems."/".device = "/dev/disk/by-label/nixos";
  fileSystems."/".fsType = "btrfs";
  fileSystems."/boot".device = "/dev/disk/by-label/ESP";
  fileSystems."/boot".fsType = "vfat";

  i18n.supportedLocales = lib.mkForce [ ];
  i18n.glibcLocales = pkgs.glibcLocales;

  nixpkgs.overlays = [(self: super: {
    glibcLocales = super.runCommandNoCC "neutered-locales" {} "mkdir -p $out";
  })];
}
