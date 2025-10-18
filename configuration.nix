{ lib, pkgs, ... }:
{
  # Make CI Happy, NixOS wants a rootfs defined in order to be able to build toplevel
  fileSystems."/".device = lib.mkDefault "/dev/disk/by-label/nixos";
  # the toplevel also won't build unless grub is disabled
  boot.loader.grub.enable = lib.mkDefault false;
  hardware.graphics.enable = true;
  services.udisks2.enable = lib.mkForce false;

#  services.xserver.enable = true; # optional
#  services.displayManager.sddm.enable = true;
#  services.displayManager.sddm.wayland.enable = true;
#  services.desktopManager.plasma6.enable = true;

  programs.sway.enable = true;
  environment.systemPackages = [ pkgs.ungoogled-chromium ];

#  services.displayManager.gdm.enable = true;
#  services.desktopManager.gnome.enable = true;
#  services.gnome.core-apps.enable = false;
#  services.gnome.core-developer-tools.enable = false;
#  services.gnome.games.enable = false;
#  programs.gnome-disks.enable = false;
#  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs gnome-disk-utility ];
#  services.gnome.gnome-browser-connector.enable = false;
}
