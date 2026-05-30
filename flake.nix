{
  description = "NixOS server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    user = "sadiq";
    hostname = "server";
    stateVersion = "26.05";

    pkgsStable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    constants = import ./shared/constants.nix;
  in {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs stateVersion hostname user pkgsStable constants;
      };
      modules = [
        ./configuration.nix
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
      ];
    };

    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit constants inputs;
      };
      modules = [
        ./home/home.nix
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
  };
}
