{
  nixpkgs.hostPlatform = {
    system = "aarch64-linux";
    config = "aarch64-unknown-linux-musl";
    linux-kernel = {
      name = "aarch64-multiplatform";
      baseConfig = "defconfig";
      DTB = true;
#      extraConfig = "";
      autoModules = true;
      preferBuiltin = true;
      target = "vmlinuz.efi";
      installTarget = "zinstall";
    };
  };
}

