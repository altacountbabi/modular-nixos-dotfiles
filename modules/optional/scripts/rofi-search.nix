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
      input=$(rofi -dmenu -p "Search: ")
      ${browser} "${search_engine}$input"
      ${workspace_switch_cmd}
    '';
}
