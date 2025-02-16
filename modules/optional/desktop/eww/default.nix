{
  mkModule,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
in
mkModule {
  name = "eww";
  path = "desktop.eww";
  opts = with types; {
    # UI Panels
    bar = {
      enable = mkEnableOption "Bar UI";
      battery = mkEnableOption "Battery Indicator";
    };

    # Colors
    bg = mkOption {
      type = str;
      default = "#000";
    };
    border = mkOption {
      type = str;
      default = "#111";
    };
    slider_bg = mkOption {
      type = str;
      default = "#2e2e2e";
    };
    fg = mkOption {
      type = str;
      default = "#eee";
    };
    accent = mkOption {
      type = str;
      # Dark Red
      default = "#D35D6E";
    };
  };
  hm = cfg: {
    home.packages = with pkgs; [ eww ];
    xdg.configFile = {
      "eww/eww.yuck".text =
        ''
          (
              defwidget metric [label value onchange]
              (
                  box
                  :orientation "h"
                  :class "metric"
                  :space-evenly false
                  (
                      box
                      :class "label"
                      label
                  )
                  (
                      scale
                      :min 0
                      :max 101
                      :active {onchange != ""}
                      :value value
                      :onchange onchange
                  )
              )
          )

          (defvar volume 0)
          (
              defwindow volume_popup
              :monitor 0
              :stacking "overlay"
              :namespace "volume-popup"
              :geometry (
                  geometry
                  :y "50px"
                  :height "40px"
                  :anchor "bottom center"
              )
              (
                  box
                  :class "volume_popup_background"
                  :orientation "horizontal"
                  (
                      metric
                      :label {
                          ; Muted
                          volume == 0 ? "󰸈" :
                              ; Low volume
                              volume < 26 ? "󰕿" :
                                  ; Medium volume
                                  volume < 51 ? "󰖀" :
                                      ; High volume
                                      volume < 76 ? "󰕾" : "" ; Over 100 volume
                      }
                      :value volume
                      :onchange ""
                  )
              )
          )
        ''
        + (
          if cfg.bar.enable then
            ''
              (defpoll time :interval "30s" "date '+%H:%M'")
              (
                  defwindow bar
                  :monitor 0
                  :geometry (
                      geometry
                      :x "0%"
                      :y "0%"
                      :width "100%"
                      :height "10px"
                      :anchor "bottom center"
                  )
                  :exclusive true
                  (
                      centerbox
                      :orientation "h"
                      (workspaces)
                      (
                          label
                          :text time
                      )
                      (
                          box
                          :class "right"
                          :orientation "h"
                          :space-evenly false
                          :spacing 8
                          :halign "end"

                          ${
                            if cfg.bar.battery then
                              ''
                                (
                                  label
                                  :text "Battery: {EWW_BATTERY.BAT1.status}"
                                )
                              ''
                            else
                              ""
                          }
                          (
                              metric
                              :label ""
                              :value volume
                              :onchange ""
                          )
                      )
                  )
              )
              (
                  defwidget workspaces []
                  (
                      box
                      :class "workspaces"
                      :orientation "h"
                      :space-evenly true
                      :halign "start"
                      :spacing 10
                      (button :onclick "hyprctl dispatch workspace 1" 1)
                      (button :onclick "hyprctl dispatch workspace 2" 2)
                      (button :onclick "hyprctl dispatch workspace 3" 3)
                      (button :onclick "hyprctl dispatch workspace 4" 4)
                      (button :onclick "hyprctl dispatch workspace 5" 5)
                      (button :onclick "hyprctl dispatch workspace 6" 6)
                  )
              )
            ''
          else
            ""
        );
      "eww/eww.scss".text =
        let
          inherit (cfg)
            bg
            border
            slider_bg
            fg
            accent
            ;
        in
        ''
          * {
            all: unset;
          }

          tooltip {
          	background: ${bg};
          	border-radius: 5px;
          }

          .bar {
          	background: ${bg};
            color: ${fg};
            padding: 10px;
          }

          .metric scale trough highlight {
            background-color: ${accent};
            color: ${accent};
            border-radius: 10px;
          }

          .metric scale trough {
            background-color: ${slider_bg};
            border-radius: 50px;
            min-height: 3px;
            min-width: 50px;
            margin-left: 10px;
            margin-right: 20px;
          }

          .workspaces button {
            padding-left: 10px;
          }

          .volume_popup_background {
            background: ${bg};
            border-radius: 9px;
            border: 2px solid ${border};
            padding-left: 17px;
          }
        '';
    };
  };
}
