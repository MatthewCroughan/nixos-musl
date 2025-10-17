{ lib, ... }:
{
  # Make CI Happy, NixOS wants a rootfs
  fileSystems."/".device = lib.mkDefault "/dev/disk/by-label/nixos";
  # NixOS won't build unless grub is disabled
  boot.loader.grub.enable = lib.mkDefault false;
}
