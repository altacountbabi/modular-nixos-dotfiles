{ config, lib, ... }:

let
  mkError = import ./mkError.nix;

  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    splitString
    types
    attrsets
    lists
    ;

  inherit (attrsets) setAttrByPath getAttrFromPath;
in
{
  name ? path,
  path ? mkError "path" "module definition",
  imports ? [ ],
  opts ? { },
  requirements ? [ ],
  cfg ? mkError "cfg" "module definition",
}:
let
  mergedOpts = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the ${name} module.";
    };
  } // opts;

  pathList = splitString "." path;
  configPath = getAttrFromPath pathList config.modules;

  enable = builtins.all (x: x) ([ configPath.enable ] ++ requirements);
in
{
  inherit imports;

  options.modules = setAttrByPath pathList mergedOpts;
  config = (mkIf enable (cfg configPath));
}
