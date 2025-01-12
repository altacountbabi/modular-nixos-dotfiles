{
  mkModule,
  config,
  pkgs,
  ...
}:

mkModule {
  name = "virt-manager";
  path = "virt-manager";
  cfg = cfg: {
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;

    home.packages = with pkgs; [
      qemu
    ];

    users.groups.libvirtd.members = [ config.modules.user.username ];
  };
}
