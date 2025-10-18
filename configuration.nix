{ lib, ... }:
{
  # Make CI Happy, NixOS wants a rootfs defined in order to be able to build toplevel
  fileSystems."/".device = lib.mkDefault "/dev/disk/by-label/nixos";
  # the toplevel also won't build unless grub is disabled
  boot.loader.grub.enable = lib.mkDefault false;
  hardware.graphics.enable = true;
}
