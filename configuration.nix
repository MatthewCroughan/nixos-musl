{ modulesPath, lib, pkgs, config, ... }:
{
  fileSystems."/".device = "/dev/disk/by-label/nixos";
  boot.initrd.systemd.emergencyAccess = true;
  systemd.enableEmergencyMode = true;

  boot.initrd.systemd.enable = true;
  boot.loader.grub.enable = false;
  boot.kernelPatches = [
    {
      name = "config-enable-zboot";
      patch = null;
      structuredExtraConfig = {
        EFI_ZBOOT = lib.mkForce lib.kernel.yes;
        KERNEL_ZSTD = lib.mkForce lib.kernel.yes;
        RD_ZSTD = lib.mkForce lib.kernel.yes;
      };
    }
  ];
#  boot.loader.systemd-boot = {
#    enable = true;
#  };
  users.users.root.password = "default";
  #services.userborn.enable = lib.mkForce true;
  #systemd.sysusers.enable = lib.mkForce false;
  #services.openssh = {
  #  enable = true;
  #  settings = {
  #    PermitRootLogin = "yes";
  #    PasswordAuthentication = true;
  #  };
  #};
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
