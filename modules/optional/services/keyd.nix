{ mkModule, ... }:

mkModule {
  name = "keyd";
  path = "services.keyd";
  cfg = cfg: {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          capslock = "escape";
          escape = "capslock";
        };
      };
    };
  };
}
