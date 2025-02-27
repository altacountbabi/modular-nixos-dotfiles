{
  mkModule,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption;
in
mkModule {
  name = "LibreOffice";
  path = "desktop.libreoffice";
  opts = {
    normalTheme = mkEnableOption "Use the normal adwaita dark theme for libreoffice";
  };
  hm = cfg: {
    home.packages = with pkgs; [ libreoffice-fresh ];
    xdg.${if cfg.normalTheme then "desktopEntries" else null} =
      let
        entry = extraName: extraArg: {
          name = "LibreOffice${if extraName != null then " ${extraName}" else ""}";
          genericName = "Office";
          exec = "env GTK_THEME=Adwaita:dark libreoffice ${
            if extraArg != null then "${extraArg} " else ""
          }%U";
          categories = [
            "Office"
            "X-Red-Hat-Base"
            "X-SuSE-Core-Office"
          ];
          terminal = false;
          noDisplay = false;
          icon = "libreoffice-startcenter";
          mimeType = [
            "application/vnd.openofficeorg.extension"
            "x-scheme-handler/vnd.libreoffice.cmis"
            "x-scheme-handler/vnd.sun.star.webdav"
            "x-scheme-handler/vnd.sun.star.webdavs"
            "x-scheme-handler/vnd.libreoffice.command"
            "x-scheme-handler/ms-word"
            "x-scheme-handler/ms-powerpoint"
            "x-scheme-handler/ms-excel"
            "x-scheme-handler/ms-visio"
            "x-scheme-handler/ms-access"
          ];
        };
      in
      {
        startcenter = entry null null;
        writer = entry "Writer" "--writer";
        calc = entry "Calc" "--calc";
        math = entry "Math" "--math";
        impress = entry "Impress" "--impress";
        base = entry "Base" "--base";
        draw = entry "Draw" "--draw";
      };
  };

}
