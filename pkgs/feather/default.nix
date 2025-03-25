{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "feather";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "13unk0wn";
    repo = "Feather";
    rev = "main";
    sha256 = "sha256-pwaADT8+jlIAKeov7TZwQ5lmQGG+2j/I9q8VrNPvnOs=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  cargoBuildFlags = [
    "--manifest-path"
    "feather_frontend/Cargo.toml"
  ];
  cargoLock.lockFile = "${src}/feather_frontend/Cargo.lock";
  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = "${src}/feather_frontend/Cargo.lock";
  };
  cargoRoot = "feather_frontend";

  useFetchCargoVendor = true;
  cargoHash = lib.fakeHash;

  buildPhase = ''
    export CARGO_HOME=$TMPDIR/cargo
    mkdir -p $CARGO_HOME

    cargo build --release --locked
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/feather_frontend $out/bin/feather
  '';

  meta = {
    description = "A lightweight YouTube Music TUI built with rust.";
    homepage = "https://github.com/13unk0wn/Feather";
    license = lib.licenses.mit;
    mainProgram = "feather";
  };
}
