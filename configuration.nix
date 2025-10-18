{ lib, ... }:
{
  # Make CI Happy, NixOS wants a rootfs defined in order to be able to build toplevel
  fileSystems."/".device = lib.mkDefault "/dev/disk/by-label/nixos";
  # the toplevel also won't build unless grub is disabled
  boot.loader.grub.enable = lib.mkDefault false;
  # scripted initrd is bad, and you can't run the vm output of the
  # nixosConfigurations without this
  boot.initrd.systemd.enable = lib.mkDefault true;
}
