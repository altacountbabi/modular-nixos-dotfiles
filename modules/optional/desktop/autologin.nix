{
  mkModule,
  config,
  lib,
  ...
}:

mkModule {
  name = "autologin";
  path = "desktop.autologin";
  cfg =
    cfg:
    let
      userCfg = config.modules.user;
    in
    {
      services.displayManager.autoLogin = {
        enable = userCfg.enable;
        user = userCfg.username;
      };
    };
}
