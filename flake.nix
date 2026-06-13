{
  description = "Home Manager config for MacBook M4 and NixOS PC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = inputs@{ nixpkgs, home-manager, catppuccin, ... }:
    let
      darwinSystem = "aarch64-darwin";
      linuxSystem = "x86_64-linux";
      homeManagerModules = import ./modules/home-manager;
    in {
      formatter.${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt;
      formatter.${linuxSystem} = nixpkgs.legacyPackages.${linuxSystem}.nixfmt;

      homeConfigurations = {
        "linhnguyen@mac-m4" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${darwinSystem};
          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [
            catppuccin.homeModules.catppuccin
            homeManagerModules.darwin-trampoline-apps
            ./home-manager/macbook-pro.nix
          ];
        };

        "linhnguyen@nixos-pc" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${linuxSystem};
          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [
            catppuccin.homeModules.catppuccin
            homeManagerModules.darwin-trampoline-apps
            ./home-manager/nixos-pc.nix
          ];
        };
      };
    };
}
