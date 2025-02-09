{
  mkModule,
  ...
}:

mkModule {
  name = "tailscale";
  path = "services.tailscale";
  cfg = cfg: {
    services.tailscale.enable = true;
  };
}
