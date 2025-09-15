{ pkgs, lib, ... }:
{
#  nixpkgs.localSystem = {
#    system = "aarch64-unknown-linux-gnu";
#  };
#  nixpkgs.crossSystem = {
#    config = "aarch64-unknown-linux-musl";
#    useLLVM = true;
#    linker = "lld";
#  };

  nixpkgs.buildPlatform = "aarch64-unknown-linux-gnu";
  nixpkgs.hostPlatform = lib.recursiveUpdate (lib.systems.elaborate "aarch64-unknown-linux-musl") {
    useLLVM = true;
    linker = "lld";
    linux-kernel.target = "vmlinuz.efi";
    linux-kernel.installTarget = "zinstall";
    config = "aarch64-unknown-linux-musl";
  };

#  nixpkgs.buildPlatform = "aarch64-unknown-linux-gnu";
#  nixpkgs.hostPlatform = {
#    useLLVM = true;
#    linker = "lld";
#    system = "aarch64-linux";
#    config = "aarch64-unknown-linux-musl";
#    linux-kernel = {
#      name = "aarch64-multiplatform";
#      baseConfig = "defconfig";
#      DTB = true;
#      extraConfig = "";
#      autoModules = true;
#      preferBuiltin = true;
#      target = "vmlinuz.efi";
#      installTarget = "zinstall";
#    };
#  };
}
