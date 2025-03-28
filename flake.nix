{
  description = "A NixOS configuration";

  outputs =
    {
      self,
      nixpkgs,
      lix-module,
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
                lix-module.nixosModules.default

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

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nuenv.url = "https://flakehub.com/f/DeterminateSystems/nuenv/*.tar.gz";
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    catppuccin.url = "github:altacountbabi/catppuccin-nix";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
    niri.url = "github:sodiboo/niri-flake/";

    # Apps
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixcord.url = "github:kaylorben/nixcord";
    helix.url = "github:helix-editor/helix";
  };
}
