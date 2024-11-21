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
        strings
        listToAttrs
        concatMap
        nixosSystem
        ;

      mkHosts =
        hosts:
        listToAttrs (
          map (host: {
            name = host.host;
            value = nixosSystem (rec {
              inherit (host) system;
              specialArgs = {
                inherit inputs system;
              };

              modules = [
                ./hosts/${host.host}/config.nix
                ./modules
              ];
            });
          }) hosts
        );
    in
    {
      nixosConfigurations = mkHosts [
        {
          system = "x86_64-linux";
          host = "laptop-nixos";
        }
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
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin.url = "github:catppuccin/nix";
    disko.url = "github:nix-community/disko";
    nixcord.url = "github:kaylorben/nixcord";
    sops-nix.url = "github:Mic92/sops-nix";
  };
}
