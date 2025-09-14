# Further minimization, at the cost of being able to interact with the system by any means
{ lib, pkgs, ... }:
{
  imports = [
    ./bashless.nix
  ];
  # Maybe in the end..
  environment.systemPackages = lib.mkForce [ ];
  # Can save 1MB by disabling console
  console.enable = false;
  boot.initrd.systemd.extraBin = lib.mkForce {};
  security.pam.package = lib.mkForce (pkgs.runCommandNoCC "neutered" { } "mkdir -p $out");
  systemd.globalEnvironment.TZDIR = lib.mkForce "";
  environment.etc.zoneinfo.source = lib.mkForce (pkgs.runCommandNoCC "neutered" { } "mkdir -p $out");
  security.pam.services = lib.mkForce {};
}
