{ lib, ... }:

{
  # Remove bash from activation
  system.nixos-init.enable = lib.mkForce true;
  system.activatable = lib.mkForce false;
  environment.shell.enable = lib.mkForce false;
  programs.bash.enable = lib.mkForce false;

  # Random bash remnants
  environment.corePackages = lib.mkForce [ ];
  # Contains bash completions
  nix.enable = lib.mkForce false;
  # The fuse{,3} package contains a runtime dependency on bash.
  programs.fuse.enable = lib.mkForce false;
  documentation.man.man-db.enable = lib.mkForce false;
  # autovt depends on bash
  console.enable = lib.mkForce false;
  # dhcpcd and openresolv depend on bash
  # bcache tools depend on bash.
  boot.bcache.enable = lib.mkForce false;
  # iptables depends on bash and nixos-firewall-tool is a bash script
  networking.firewall.enable = lib.mkForce false;
  # the wrapper script is in bash
  security.enableWrappers = lib.mkForce false;
  # kexec script is written in bash
  boot.kexec.enable = lib.mkForce false;
  # Relies on bash scripts
  powerManagement.enable = lib.mkForce false;
  # Has some bash inside
  systemd.shutdownRamfs.enable = lib.mkForce false;
  # Relies on the gzip command which depends on bash
  services.logrotate.enable = lib.mkForce false;
  # Service relies on bash scripts
  services.timesyncd.enable = lib.mkForce false;

  # Check that the system does not contain a Nix store path that contains the
  # string "bash".
  system.forbiddenDependenciesRegexes = [ "bash" ];

  services.udev.packages = lib.mkForce [];

  boot.kernelParams = [ "systemd.journald.forward_to_kmsg=1" "loglevel=8" ];
}

