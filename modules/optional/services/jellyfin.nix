{
  mkModule,
  lib,
  ...
}:

mkModule {
  name = "jellyfin";
  path = "services.jellyfin";
  cfg = cfg: {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
