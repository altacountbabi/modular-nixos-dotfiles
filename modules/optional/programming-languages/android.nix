{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) types;
in
mkModule {
  name = "Android dev environment";
  path = "programming-language.android";
  opts = with types; { };
  cfg = cfg: {
    programs.adb.enable = true;
    users.users."${config.modules.user.username}".extraGroups = [
      "kvm"
      "adbusers"
    ];

    services.udev.packages = with pkgs; [
      android-udev-rules
    ];

    environment.systemPackages = with pkgs; [
      android-studio
    ];

    nixpkgs.config.android_sdk.accept_license = true;
  };
}
