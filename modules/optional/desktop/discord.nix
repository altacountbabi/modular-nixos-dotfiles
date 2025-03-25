{
  mkModule,
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
mkModule {
  name = "desktop.discord";
  path = "desktop.discord";
  opts.autoStart = mkEnableOption "Discord as a startup app";
  hm = cfg: {
    imports = [ inputs.nixcord.homeManagerModules.nixcord ];

    programs.nixcord = {
      enable = true;
      quickCss =
        (
          if config.modules.colorscheme.catppuccin.enable then
            ''
              @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css");
            ''
          else
            ""
        )
        + builtins.readFile (
          builtins.fetchurl {
            url = "https://gist.githubusercontent.com/altacountbabi/fbb93e52946c2571b678119e0f4f8b69/raw/880f5e179e360cd523923cbe0a9cdb13ed7883f3/style.css";
            sha256 = "3c9455f25ee727aa5353b8116b65b04fd9c515fb2ddf1eb81a547354aa810809";
          }
        );

      discord.openASAR.enable = false; # OpenASAR seems to be missing some kind of module, maybe I'll figure it out later.
      config = {
        useQuickCss = true;
        frameless = true;
        plugins = {
          webScreenShareFixes.enable = true;
          betterUploadButton.enable = true;
          showHiddenChannels.enable = true;
          permissionFreeWill.enable = true;
          permissionsViewer.enable = true;
          favoriteGifSearch.enable = true;
          noTypingAnimation.enable = true;
          betterGifPicker.enable = true;
          noUnblockToJump.enable = true;
          themeAttributes.enable = true;
          youtubeAdblock.enable = true;
          loadingQuotes.enable = true;
          messageLogger.enable = true;
          silentTyping.enable = true;
          spotifyCrack.enable = true;
          onePingPerDM.enable = true;
          emoteCloner.enable = true;
          experiments.enable = true;
          fakeNitro.enable = true;
          validUser.enable = true;
          viewRaw.enable = true;
          imageZoom = {
            nearestNeighbour = true;
            enable = true;
            square = true;
            size = 200.0;
            zoom = 5.0;
          };
        };
      };
    };

    wayland.windowManager.hyprland.settings =
      mkIf (config.modules.desktop.desktops.hyprland.enable && cfg.autoStart)
        {
          exec-once = [
            "[workspace 2 silent] discord --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"
          ];
          windowrulev2 = [
            # [workspace 2 silent] in exec-once only seems to apply to the launcher not the whole app
            "workspace 2 silent,class:(discord)"
          ];
        };
  };
}
