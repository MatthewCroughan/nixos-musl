{ config, lib, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      systemd = super.systemd.override { withKmod = false; };
    })
  ];
  boot.initrd.systemd.suppressedUnits = [
    "systemd-bsod.service"
    "kmod-static-nodes.service"
    "systemd-modules-load.service"
  ];
  systemd.suppressedSystemUnits = [
    "systemd-bsod.service"
    "kmod-static-nodes.service"
    "systemd-modules-load.service"
  ];
  boot.initrd.systemd.suppressedStorePaths = [
    "${config.systemd.package}/lib/systemd/systemd-bsod"
    "${config.systemd.package}/lib/systemd/systemd-modules-load"
  ];
  boot.initrd.services.udev.packages = lib.mkForce [];
}
