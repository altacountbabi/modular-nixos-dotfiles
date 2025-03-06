{
  config,
  pkgs,
  lib,
  ...
}:

name: lib.getExe (import ../modules/optional/scripts/${name}.nix { inherit lib pkgs config; })
