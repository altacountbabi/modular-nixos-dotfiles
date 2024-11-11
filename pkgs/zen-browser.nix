{ pkgs, ... }:

let
  inherit (pkgs) wrapFirefox callPackage;
  zen-browser-unwrapped = import ./zen-browser-unwrapped { inherit pkgs; };
in
wrapFirefox zen-browser-unwrapped {
  pname = "zen-browser";
  libName = "zen";
}
