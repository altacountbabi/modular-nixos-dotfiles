{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
in
pkgs.writeShellApplication {
  name = "notify-info";
  runtimeInputs = with pkgs; [ libnotify ];
  text =
    let
      volumeScript = getExe (import ./volume.nix pkgs);
      timeout = 5000;
    in
    ''
      notify-send -t "${builtins.toString timeout}" -e "Time:   $(date +"%H:%M")" "Volume: $(${volumeScript} g)%"
    '';
}
