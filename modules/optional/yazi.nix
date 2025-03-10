{
  mkModule,
  ...
}:

mkModule {
  name = "yazi file manager";
  path = "yazi";
  hm = cfg: {
    programs.yazi = {
      enable = true;
      keymap = {
        manager.prepend_keymap = [
          {
            on = "<Enter>";
            run = "enter";
          }
          {
            on = "<S-Enter>";
            run = "open";
          }
        ];
      };
    };
  };
}
