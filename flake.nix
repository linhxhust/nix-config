{
  description = "Home Manager config for MacBook M4";

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
      system = "aarch64-darwin";
      homeManagerModules = import ./modules/home-manager;
    in {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

      homeConfigurations."linhnguyen@mac-m4" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [
            catppuccin.homeModules.catppuccin
            homeManagerModules.darwin-trampoline-apps
            ./home-manager/macbook-pro.nix
          ];
        };
    };
}
