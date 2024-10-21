{ mkModule, ... }:

mkModule {
  name = "ssh";
  path = "services.ssh";
  cfg = cfg: { services.openssh.enable = true; };
}
