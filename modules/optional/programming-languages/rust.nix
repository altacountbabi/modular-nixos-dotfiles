{
  mkModule,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    ;
in
mkModule {
  name = "programming-language.rust";
  path = "programming-language.rust";
  opts = with types; {
    channel = mkOption {
      type = enum [
        "stable"
        "nightly"
      ];
      default = "nightly";
    };
    components = mkOption {
      # TODO: Use a listOf enum for this
      type = listOf str;
      default = [
        "rustfmt"
        "clippy"
        "rust-src"
        "rust-analyzer"
      ];
    };
    targets = mkOption {
      type = listOf str;
      default = [
        "x86_64-unknown-linux-musl"
        "aarch64-unknown-linux-musl"
        "aarch64-unknown-linux-gnu"
        "x86_64-unknown-uefi"
        "wasm32-unknown-unknown"
      ];
    };
  };
  cfg = cfg: {
    environment.systemPackages = with pkgs; [
      (rust-bin."${cfg.channel}".latest.default.override {
        extensions = cfg.components;
        targets = cfg.targets;
      })
      gcc14
      lldb

      cargo-binstall
      wasm-bindgen-cli
    ];
  };
}
