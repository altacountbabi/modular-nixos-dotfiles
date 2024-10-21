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
              system = host.system;
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
        inherit (pkgs) mkShell;
      in
      {
        devShells.default = mkShell { packages = with pkgs; [ just ]; };
      }
    );

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
  };
}
