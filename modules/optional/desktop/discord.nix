{
  mkModule,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
in
mkModule {
  name = "desktop.discord";
  path = "desktop.discord";
  opts.autoStart = mkEnableOption "Discord as a startup app";
  hm = cfg: {
    imports = [ inputs.nixcord.homeManagerModules.nixcord ];

    programs.nixcord = {
      enable = true;
      quickCss = builtins.readFile (
        builtins.fetchurl {
          url = "https://gist.githubusercontent.com/altacountbabi/fbb93e52946c2571b678119e0f4f8b69/raw/5a0bcfbcde37eb964f2f006d2dc0385ebc301f8b/style.css";
          sha256 = "1fag3qh5a4hrbarpay197nipzadx3d6lps598p7lc85wk4kc1amr";
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
