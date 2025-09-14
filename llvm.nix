{
  nixpkgs.buildPlatform = "aarch64-unknown-linux-gnu";
  nixpkgs.hostPlatform = {
    useLLVM = true;
    linker = "lld";
    system = "aarch64-linux";
    config = "aarch64-unknown-linux-musl";
    linux-kernel = {
      name = "aarch64-multiplatform";
      baseConfig = "defconfig";
      DTB = true;
      extraConfig = "";
      autoModules = false;
      preferBuiltin = true;
      target = "vmlinuz.efi";
      installTarget = "zinstall";
    };
  };
}
