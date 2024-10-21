{ mkModule, ... }:

mkModule {
  name = "gdm";
  path = "desktop.dm.gdm";
  cfg = cfg: { services.xserver.displayManager.gdm.enable = true; };
}
