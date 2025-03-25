{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;
in
pkgs.rustPlatform.buildRustPackage {
  pname = "nuls";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "jokeyrhyme";
    repo = "nuls";
    rev = "main";
    sha256 = "sha256-wVuRMWXRsb/cOcovuslmn3yMw0L9GMJdbwsFKUWmETw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-6IRhyHoVpBEoCRw06u6GWfgHxZdttJXczJWN8+3fvfM=";

  buildPhase = ''
    export CARGO_HOME=$TMPDIR/cargo
    mkdir -p $CARGO_HOME

    cargo build --release --locked
  '';

  checkFlags = [
    "--skip=nu::tests::run_compiler_for_diagnostic_ok"
    "--skip=nu::tests::run_compiler_for_completion_ok"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/nuls $out/bin
  '';

  meta = {
    description = "Language Server Protocol implementation for nushell";
    homepage = "https://github.com/jokeyrhyme/nuls";
    license = lib.licenses.mit;
    mainProgram = "nuls";
  };
}
