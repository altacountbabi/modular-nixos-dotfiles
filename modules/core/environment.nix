{ mkModule, config, ... }:

mkModule {
  name = "environment variables";
  path = "environment";
  cfg = cfg: {
    environment.sessionVariables = {
      MICRO_TRUECOLOR = 1;
      ${if config.modules.graphics.gpuType != "nvidia" then "NIXOS_OZONE_WL" else null} = "1";
      # Fix audio crackling/popping in some games
      PULSE_LATENCY_MSEC = 50;
    };
  };
}
