{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "color-picker";
  runtimeInputs = with pkgs; [
    hyprpicker
    libnotify
  ];
  text = ''
    color=$(hyprpicker -n -a)
    notify-send "Copied to Clipboard" "$color" --expire-time=2000
  '';
}
