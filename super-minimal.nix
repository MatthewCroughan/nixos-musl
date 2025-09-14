{
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
in
{
  imports = [
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];
  networking.dhcpcd.enable = false;
  fonts.fontconfig.enable = false;
  environment.etc."udev/hwdb.bin".enable = false;
  services.timesyncd.enable = false;
  systemd.oomd.enable = false;
  networking.wireless.enable = false;

  systemd.network.enable = false;
  networking.useNetworkd = false;
  services.resolved.enable = false;
  services.openssh.enable = lib.mkForce false;
  networking.useDHCP = false;

  # Complains about lastlog
  systemd.tmpfiles.packages = lib.mkForce [ ];

  # https://github.com/NixOS/nixpkgs/issues/404169
  security.pam.services.login.rules.session.lastlog.enable = lib.mkForce false;

  programs.nano.enable = false;
  security.polkit.enable = lib.mkForce false;
  programs.ssh.package = pkgs.runCommandNoCC "neutered" { } "mkdir -p $out";
  systemd.tpm2.enable = false;
  security.sudo.enable = false;
  services.lvm.enable = false;
  boot.bcache.enable = false;
  powerManagement.enable = false;

#  # We use a builtins based kernel with no modules anyway
#  boot.initrd.availableKernelModules = lib.mkForce [ ];
#  boot.kernelModules = lib.mkForce [ ];
#  boot.initrd.kernelModules = lib.mkForce [ ];

  services.fstrim.enable = lib.mkForce false;

  boot.hardwareScan = lib.mkForce false;

  boot.enableContainers = false;
  networking.resolvconf.enable = false;

  security.pam.services.login.updateWtmp = lib.mkForce false;

  nixpkgs.overlays = [
    (self: super: {
      # prevent runtime reference to bash when cross-compiling
      gnugrep = super.gnugrep.override { runtimeShellPackage = self.runCommandNoCC "neutered" { } "mkdir -p $out"; };

      # checks fail due to some override in this super-minimal profile
      go-md2man = glibcPkgs.go-md2man;

      util-linux = super.util-linux.override {
        systemdSupport = false;
        pamSupport = false;
        cryptsetupSupport = false;
        nlsSupport = false;
        ncursesSupport = false;
        withLastlog = false;
      };
      coreutils-full = self.coreutils;
      dbus = (super.dbus.overrideAttrs (old: {
        configureFlags = (lib.remove "--enable-libaudit" old.configureFlags) ++ [
        ];
        buildInputs = (lib.remove super.audit old.buildInputs);
      })).override { x11Support = false; };
      wireplumber = super.wireplumber.override {
        enableGI = false;
      };
      systemd = (super.systemd.override {
        kbd = self.kbd.overrideAttrs { unpackPhase = "mkdir -p {$out/bin,$dev,$man,$scripts}; touch $out/bin/{loadkeys,setfont}; exit 0"; };
        coreutils = self.runCommandNoCC "neutered" { } "mkdir -p $out";
        withUkify = false;
        withRepart = false;
        withCryptsetup = false;
        withEfi = false;
        withBootloader = false;

        withAcl = false;
        withAnalyze = false;
        withApparmor = false;
        withAudit = false;
        withCompression = false;
        withCoredump = false;
        withDocumentation = false;
        withFido2 = false;
        withGcrypt = false;
        withHostnamed = false;
        withHomed = false;
        withHwdb = false;
        withImportd = false;
        withLibBPF = false;
        withLibidn2 = false;
        withLocaled = false;
        withLogind = false;
        withMachined = false;
        withNetworkd = false;
        withNss = false;
        withOomd = false;
        withOpenSSL = false;
        withPCRE2 = false;
        withPam = false;
        withPolkit = false;
        withPortabled = false;
        withRemote = false;
        withResolved = false;
        withShellCompletions = false;
        withSysupdate = false;
        withSysusers = false;
        withTimedated = false;
        withTimesyncd = false;
        withTpm2Tss = false;
        withUserDb = false;
        withPasswordQuality = false;
        withVmspawn = false;
        withQrencode = false;
        withLibarchive = false;
      });
    })
  ];
  systemd.coredump.enable = false;
  systemd.repart.enable = false;
  system.switch.enable = false;
  nix.enable = false;
  networking.firewall.enable = false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  environment.corePackages = lib.mkForce [];
  boot.initrd.systemd.suppressedUnits = [
    "systemd-logind.service"
    "systemd-user-sessions.service"
    "dbus-org.freedesktop.login1.service"
  ];
  systemd.suppressedSystemUnits = [
    "systemd-logind.service"
    "systemd-user-sessions.service"
    "dbus-org.freedesktop.login1.service"
  ];
  boot.initrd.systemd.suppressedStorePaths = [
    "${config.systemd.package}/example/systemd/system/systemd-logind.service"
    "${config.systemd.package}/example/systemd/system/systemd-user-sessions.service"
    "${config.systemd.package}/example/systemd/system/dbus-org.freedesktop.login1.service"
  ];
  boot.kernelParams = [ "quiet" "mitigations=off" ];
}
