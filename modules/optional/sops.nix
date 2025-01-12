{
  mkModule,
  config,
  inputs,
  ...
}:

mkModule {
  name = "secret management";
  path = "sops";
  imports = [ inputs.sops-nix.nixosModules.sops ];
  cfg = cfg: {
    sops = {
      defaultSopsFile = ../../secrets.yaml;
      defaultSopsFormat = "yaml";

      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };

      secrets.user-password.neededForUsers = true;
    };

    users.users."${config.modules.user.username}".hashedPasswordFile =
      config.sops.secrets.user-password.path;
  };
}
