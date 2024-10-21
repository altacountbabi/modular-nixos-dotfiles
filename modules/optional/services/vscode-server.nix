{ mkModule, inputs, ... }:

mkModule {
  name = "vscode ssh server";
  path = "services.vscode-server";
  imports = [ inputs.vscode-server.nixosModules.default ];
  cfg = cfg: { services.vscode-server.enable = true; };
}
