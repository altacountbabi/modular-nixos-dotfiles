{
  lib,
  pkgs,
  batteryInfo ? false,
  ...
}:

let
  inherit (lib) getExe;
in
pkgs.writeShellApplication {
  name = "notify-info";
  runtimeInputs = with pkgs; [
    libnotify
    acpi
  ];
  text =
    let
      volumeScript = getExe (import ./volume.nix pkgs);
      timeout = 5000;
    in
    ''
      notify-send -t "${builtins.toString timeout}" -e "Time:   $(date +%-I:%M)" "Date:   $(date +"%A, %d, %B")
      Volume:  $(${volumeScript} g)%
      ${if batteryInfo then "$(acpi -b)" else ""}"
    '';
}
