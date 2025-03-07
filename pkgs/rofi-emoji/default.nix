{
  pkgs,
  wayland ? true,
  ...
}:

(if wayland then pkgs.rofi-emoji else pkgs.rofi-emoji-wayland).overrideAttrs (prev: {
  patches = prev.patches ++ [
    ./emojis.patch
  ];
})
