{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "nixos-installer";
  runtimeInputs = with pkgs; [
    git
    gum # TUI Dialogs
  ];
  text = builtins.readFile ./main.sh;
}
