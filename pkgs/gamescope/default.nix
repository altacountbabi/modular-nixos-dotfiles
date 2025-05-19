{
  pkgs,
  amd ? false,
  ...
}:

pkgs.gamescope.overrideAttrs (prev: {
  patches = prev.patches ++ (if amd then [ ./radv-only.patch ] else [ ]);
})
