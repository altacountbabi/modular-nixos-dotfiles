{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage {
  pname = "mdpls";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "euclio";
    repo = "mdpls";
    rev = "master";
    sha256 = "sha256-4n1MX8hS7JmKzaL8GfMq2q3IdwE4fvMmWOYo7rY+cdY=";
  };

  buildInputs = with pkgs; [
    rustc
    cargo
  ];

  cargoHash = "sha256-0braGtUUckReN1fqRtXcnKGlBQJzJ9XuWBk2T3ieMR8=";

  buildPhase = ''
    export CARGO_HOME=$TMPDIR/cargo
    mkdir -p $CARGO_HOME

    cargo build --release --locked
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/mdpls $out/bin/
  '';

  meta = with pkgs.lib; {
    description = "Markdown Preview Language Server";
    homepage = "https://github.com/euclio/mdpls";
  };
}
