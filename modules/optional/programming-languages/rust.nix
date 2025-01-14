{
  mkModule,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
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
        "rust-analyzer"
      ];
    };
    targets = mkOption {
      # I am NOT making this an enum
      type = listOf str;
      default = [ ];
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
    ];
  };
}
