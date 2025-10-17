{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:matthewcroughan/nixpkgs/mc/conditional-glibcsystemdinitrd";
  };

  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];
      perSystem = { system, ... }: {
        checks = builtins.mapAttrs (n: v: v.config.system.build.toplevel) self.nixosConfigurations;
        legacyPackages =
          builtins.listToAttrs (map
            (name: {
              name = "vmtest-${name}";
              value = self.nixosConfigurations.${name}.config.system.build.vmtest;
            })
            (builtins.attrNames self.nixosConfigurations));
      };
      flake = rec {
        herculesCI.ciSystems = [ "aarch64-linux" ];
        nixosConfigurations.base = let
          systemconfig = {
            imports = [ ./configuration.nix ];
          };
        in inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            systemconfig
            ({ pkgs, ... }: {
              system.build.vmtest = pkgs.lib.mkDefault (pkgs.callPackage ./vmtest.nix { config = systemconfig ; });
            })
          ];
        };
        nixosConfigurations.gnu-musl = let
          systemconfig = {
            imports = [ ./musl.nix ];
            nixpkgs.buildPlatform = (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-gnu");
            nixpkgs.hostPlatform = inputs.nixpkgs.lib.recursiveUpdate (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {};
          };
        in nixosConfigurations.base.extendModules {
          modules = [
            systemconfig
            ({ pkgs, ... }: {
              system.build.vmtest = pkgs.callPackage ./vmtest.nix { config = systemconfig ; };
            })
          ];
        };
        nixosConfigurations.gnu-musl-llvm = let
          systemconfig = {
            imports = [ ./musl-llvm.nix ];
            nixpkgs.buildPlatform = (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-gnu");
            nixpkgs.hostPlatform = inputs.nixpkgs.lib.recursiveUpdate (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {
              useLLVM = true;
              linker = "lld";
              config = "aarch64-unknown-linux-musl";
            };
          };
        in nixosConfigurations.base.extendModules {
          modules = [
            systemconfig
            ({ pkgs, ... }: {
              system.build.vmtest = pkgs.callPackage ./vmtest.nix { config = systemconfig ; };
            })
          ];
        };
        nixosConfigurations.musl-llvm = let
          systemconfig = {
            imports = [ ./musl-llvm.nix ];
            nixpkgs.buildPlatform = (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl");
            nixpkgs.hostPlatform = inputs.nixpkgs.lib.recursiveUpdate (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {
              useLLVM = true;
              linker = "lld";
              config = "aarch64-unknown-linux-musl";
            };
          };
        in nixosConfigurations.base.extendModules {
          modules = [
            systemconfig
            ({ pkgs, ... }: {
              system.build.vmtest = pkgs.callPackage ./vmtest.nix { config = systemconfig ; };
            })
          ];
        };
        nixosConfigurations.musl = let
          systemconfig = {
            imports = [ ./musl.nix ];
            nixpkgs.buildPlatform = (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl");
            nixpkgs.hostPlatform = inputs.nixpkgs.lib.recursiveUpdate (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {};
          };
        in nixosConfigurations.base.extendModules {
          modules = [
            systemconfig
            ({ pkgs, ... }: {
              system.build.vmtest = pkgs.callPackage ./vmtest.nix { config = systemconfig ; };
            })
          ];
        };
      };
    };
}
