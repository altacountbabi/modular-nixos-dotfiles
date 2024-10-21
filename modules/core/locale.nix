{ mkModule, lib, ... }:

let
  inherit (lib) mkOption types;
in
mkModule {
  path = "locale";
  opts = with types; {
    timeZone = mkOption { type = str; };
    i18n =
      let
        default = "en_US.UTF-8";
      in
      {
        main = mkOption {
          type = str;
          inherit default;
        };
        extra = mkOption {
          type = str;
          inherit default;
        };
      };
  };
  cfg = cfg: {
    time.timeZone = cfg.timeZone;
    i18n = with cfg.i18n; {
      defaultLocale = main;
      extraLocaleSettings = {
        LC_ADDRESS = extra;
        LC_IDENTIFICATION = extra;
        LC_MEASUREMENT = extra;
        LC_MONETARY = extra;
        LC_NAME = extra;
        LC_NUMERIC = extra;
        LC_PAPER = extra;
        LC_TELEPHONE = extra;
        LC_TIME = extra;
      };
    };
  };
}
