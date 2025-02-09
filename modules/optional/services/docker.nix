{
  mkModule,
  config,
  ...
}:

mkModule {
  name = "docker";
  path = "services.docker";
  cfg = cfg: {
    virtualisation.docker.enable = true;
    users.users."${config.modules.user.username}".extraGroups = [ "docker" ];
  };
}
