{ pkgs, ... }:

with pkgs;
writeShellApplication {
  name = "nixos-installer";
  runtimeInputs = [
    git
    gum # TUI Dialogs
  ];
  text = builtins.readFile ./main.sh;
}
