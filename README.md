# nixos-musl 🐚

This is a tracking Flake with CI for keeping track of how good Nixpkgs is at
building musl systems. There are some useful profiles at the root of this repo
that can be imported into your own NixOS config, should you wish to build your
system with musl. Though, this is not likely to work for anything more than the
basic invocation of `(pkgs.nixos {})`, or `(nixpkgs.lib.nixosSystem {})` for
Flake users. For anything more minimal than a base NixOS system, it should work
well.

#### Usage

The goal of this Flake is to no longer be necessary in the future, so there may
be a love-hate relationship with it, where you feel like you no longer need it,
and so remove it from your inputs, only to add it back a few months later. Any
patches I add to `musl.nix` or `musl-llvm.nix` will be sent upstream to Nixpkgs
and tracked with a comment.

###### Using extendModules

Of the available `nixosConfigurations` in this flake, you could choose to use
the method `extendModules` on them, to grab this known-working tested and CI'd
output from my flake, and use it instead of `lib.nixosSystem`

```nix
{
  inputs = {
    nixos-musl.url = "github:matthewcroughan/nixos-musl";
  };
  outputs = { nixos-musl, ... }: {
    # Extend the nixosConfigurations I have on offer, available are gnu-musl, gnu-musl-llvm, musl, musl-llvm
    # This guarantees reproducing my setup, because it will use my nixpkgs, and my fixes
    nixosConfigurations.mySystem = nixos-musl.nixosConfigurations.gnu-musl-llvm.extendModules {
      modules = [
        { networking.hostName = "gnu-musl-llvm"; }
      ];
    };
  };
}
```

###### YOLO, just use the profile with a different Nixpkgs

You could just apply the profile by adding it to the `modules` argument of your
`lib.nixosSystem`, but since you are not using my Nixpkgs that has been tested
in my CI, it may fail and diverge, as things may have been already fixed in
Nixpkgs and obsoleted my code.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-musl.url = "github:matthewcroughan/nixos-musl";
  };
  outputs = { nixos-musl, nixpkgs, ... }@inputs: {
    nixosConfigurations.mySystem = nixpkgs.lib.nixosSystem {
      modules = [
        # Import the musl.nix profile to enable the fixes that I've recognised for this system
        "${inputs.nixos-musl}/musl.nix"
        {
          nixpkgs.buildPlatform = (nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-gnu");
          nixpkgs.hostPlatform = nixpkgs.inputs.nixpkgs.lib.recursiveUpdate (nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {};
        }
      ];
    };
  };
}
```
