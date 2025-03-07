{ pkgs, config, ... }:

pkgs.writeShellApplication {
  name = "rofi-search";
  runtimeInputs = with pkgs; [
    rofi
  ];
  text =
    let
      browsers = config.modules.desktop.browser;
      browser =
        if browsers.zen.enable then
          "zen --new-tab"
        else if browsers.firefox.enable then
          "firefox --new-tab"
        else
          "true"; # does nothing in bash
      search_engine = "https://search.brave.com/search?q=";
      desktops = config.modules.desktop.desktops;
      workspace_switch_cmd = if desktops.hyprland.enable then "hyprctl dispatch workspace 1" else "true";
    in
    ''
      input=$(rofi -dmenu -p "Search" | tr -d '\n')

      if echo "$input" | grep -qE '^(https?://|www\.)|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$'; then
        url="$input"
      else
        url="${search_engine}$input"
      fi

      ${browser} "$url"
      ${workspace_switch_cmd}
    '';
}
