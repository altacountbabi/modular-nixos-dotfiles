{ pkgs, config, ... }:

pkgs.writeShellApplication {
  name = "rofi-projects-picker";
  runtimeInputs = with pkgs; [
    rofi
  ];
  text =
    let
      terminals = config.modules.desktop.terminal;
      terminal = if terminals.kitty.enable then "kitty -d" else "$TERMINAL"; # if theres no terminal in the config set try to use the `TERMINAL` env var
      shells = config.modules.shells;
      shell = if shells.nushell.enable then "nu -e" else "$SHELL"; # same thing but for shells
    in
    ''
      recent_projects="$HOME/.cache/recent-projects"

      case "$1" in
        pick)
          [ -f "$recent_projects" ] || touch "$recent_projects"
          # this lint just makes the code more unreadable
          # shellcheck disable=SC2002
          project=$(cat "$recent_projects" | rofi -dmenu -p "Pick:")
          ${terminal} "$project" ${shell} "$EDITOR ."
          ;;
        add)
          [ -f "$recent_projects" ] || touch "$recent_projects"
          sed -i "\|^$PWD\$|d" "$recent_projects"
          echo "$PWD" | cat - "$recent_projects" > temp && mv temp "$recent_projects"
          ;;
        *)
          echo "Usage: $0 {pick|add}"
          exit 1
          ;;
      esac
    '';
}
