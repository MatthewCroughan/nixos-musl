{ modulesPath, pkgs, lib, config, inputs, ... }:
{
  imports = [
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];

  fileSystems."/".device = "/dev/disk/by-label/nixos";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-label/ESP";
  fileSystems."/boot".fsType = "vfat";

#  i18n.glibcLocales = pkgs.runCommandNoCC "neutered" {} "mkdir -p $out";

#########

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

  programs.nano.enable = false;
#  console.enable = false;
  security.polkit.enable = lib.mkForce false;
  programs.ssh.package = pkgs.runCommandNoCC "neutered" {} "mkdir -p $out";
  systemd.tpm2.enable = false;
  security.sudo.enable = false;
  users.users.root.hashedPassword = "$y$j9T$v066AR/T9Bjrbwzc/Ui6v/$Hde7sT8tvocfHU/u.RYMEw4jdZxRLg0JbG5LGZM23E.";
  services.lvm.enable = false;
  boot.bcache.enable = false;
  powerManagement.enable = false;

  boot.initrd.availableKernelModules = lib.mkForce [];
  boot.kernelModules = lib.mkForce [];
  boot.initrd.kernelModules = lib.mkForce [];

  environment.systemPackages = lib.mkForce [];

  boot.enableContainers = false;
#  systemd.package = pkgs.customSystemd;
  networking.resolvconf.enable = false;

  nixpkgs.overlays = let
    glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
  in [(self: super: {
    pandoc = glibcPkgs.pandoc;
    glibcLocales = glibcPkgs.glibcLocales;
    go-md2man = glibcPkgs.go-md2man;
    systemdUkify = glibcPkgs.systemdUkify;
    util-linux = super.util-linux.override { systemdSupport = false; };
    unixtools = super.unixtools // {
      bins.getent = {
        linux = null;
      };
    };
#    erofs-utils = super.erofs-utils.overrideAttrs {
#      NIX_CFLAGS_COMPILE = "-D_LARGEFILE64_SOURCE";
#    };
    move-mount-beneath = super.move-mount-beneath.overrideAttrs (old: {
      patches = old.patches ++ [
        ./move-mount-beneath-musl.patch
      ];
    });
#    coreutils-full = self.coreutils;
#    dbus = super.dbus.override {
#      x11Support = false;
#    };
    systemd = super.systemd.override {
      withAcl = false;
      withAnalyze = true;
      withApparmor = false;
      withAudit = false;
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
      withMachined = false;
      withNetworkd = false;
      withNss = false;
      withOomd = false;
      withPCRE2 = false;
      withPolkit = false;
      withPortabled = false;
      withRemote = false;
      withResolved = false;
      withShellCompletions = false;
      withSysusers = false;
      withTimedated = false;
      withTimesyncd = false;
      withTpm2Tss = false;
      withUserDb = false;
      withPasswordQuality = false;
      withVmspawn = false;
      withLibarchive = false;
      #nice
      withKmod = false;
      # Needed
      withPam = true;
      withCompression = true;
      withLogind = true;
      withQrencode = false;
      withUkify = false;
      withEfi = false;
      withCryptsetup = false;
      withRepart = false;
      withSysupdate = false;
      withOpenSSL = true;
      withBootloader = false;
    };
    })
  ];

  systemd.coredump.enable = false;
  systemd.repart.enable = false;
  system.switch.enable = false;
  nix.enable = false;

#  systemd.package = pkgs.customSystemd;
#  services.nscd.package = pkgs.callPackage ./musl-nscd.nix {};
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  # https://github.com/NixOS/nixpkgs/issues/404169
  security.pam.services.login.rules.session.lastlog.enable = lib.mkForce false;

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
  boot.uki.settings.UKI.Stub = "${inputs.nixpkgs.legacyPackages.${pkgs.hostPlatform.system}.systemd}/lib/systemd/boot/efi/linux${pkgs.stdenv.hostPlatform.efiArch}.efi.stub";
  boot.hardwareScan = false;
}
