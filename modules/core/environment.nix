{ mkModule, ... }:

mkModule {
  name = "environment variables";
  path = "environment";
  cfg = cfg: {
    environment.sessionVariables = {
      MICRO_TRUECOLOR = 1;
      NIXOS_OZONE_WL = "1";
      # Fix audio crackling/popping in some games
      PULSE_LATENCY_MSEC = 50;
    };
  };
}
