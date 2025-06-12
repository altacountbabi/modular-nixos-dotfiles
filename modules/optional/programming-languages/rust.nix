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
  name = "Rust dev environment";
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
        "llvm-tools-preview"
      ];
    };
    targets = mkOption {
      type = listOf str;
      default = [
        "x86_64-unknown-linux-musl"
        "aarch64-unknown-linux-musl"
        "aarch64-unknown-linux-gnu"
        "wasm32-unknown-unknown"

        # no_std
        "x86_64-unknown-none"
        "x86_64-unknown-uefi"

        # Android
        "aarch64-linux-android"
        "armv7-linux-androideabi"
        "i686-linux-android"
        "x86_64-linux-android"
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
      clang

      # CLI Tools
      wasm-bindgen-cli
      cargo-show-asm
      cargo-binstall
      cargo-expand
      cargo-bloat
      irust
    ];
  };
}
