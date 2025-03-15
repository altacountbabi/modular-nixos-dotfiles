{
  description = "A NixOS configuration";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      pkgs = nixpkgs;
      inherit (pkgs.lib)
        listToAttrs
        nixosSystem
        ;

      mkHosts =
        hosts:
        listToAttrs (
          map (host: {
            name = host.host;
            value = nixosSystem rec {
              inherit (host) system;
              specialArgs = {
                inherit inputs system;
              };

              modules = [
                ./hosts/${host.host}/config.nix
                ./modules
              ];
            };
          }) hosts
        );
    in
    {
      nixosConfigurations = mkHosts [
        {
          system = "x86_64-linux";
          host = "laptop-nixos";
        }
        {
          system = "x86_64-linux";
          host = "main-pc";
        }
        {
          system = "x86_64-linux";
          host = "LaptopNixOS";
        }
        # config-placeholder
      ];
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          packages = [
            nixfmt-rfc-style
            just
          ];
        };
      }
    )
    // (
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      {
        packages.x86_64-linux = {
          installer = pkgs.callPackage ./pkgs/installer { inherit pkgs; };
          default = self.packages.x86_64-linux.installer;
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin.url = "github:altacountbabi/catppuccin-nix";
    disko.url = "github:nix-community/disko";

    # Apps
    nixcord.url = "github:kaylorben/nixcord";
    helix.url = "github:helix-editor/helix";
    # Lock to 1.7b because later versions break lots of themes.
    zen-browser.url = "github:0xc000022070/zen-browser-flake?rev=32f3692cc4d6a1d1cb8943be7d2e712a63c4b374";
    zen-browser-new.url = "github:0xc000022070/zen-browser-flake";
  };
}
