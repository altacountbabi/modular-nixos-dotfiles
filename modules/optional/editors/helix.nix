{
  mkModule,
  config,
  pkgs,
  ...
}:

mkModule {
  name = "Helix IDE";
  path = "editor.helix";
  hm = cfg: {
    programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        nixd
        nixfmt-rfc-style
      ];
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "nixfmt";
            language-servers = [ "nixd" ];
          }
          {
            name = "rust";
            auto-format = true;
            formatter.command = "rustfmt";
            language-servers = [ "rust-analyzer" ];
          }
        ];
        language-server = {
          nixd = {
            command = "nixd";
            args = [ "--inlay-hints=true" ];
            config.nixd =
              let
                username = config.modules.user.username;
                hostname = config.modules.network.hostname;
              in
              {
                nixpkgs.expr = "import (builtins.getFlake \"/home/${username}/dotfiles\")inputs.nixpkgs { }";
                options = {
                  nixos.expr = "(builtins.getFlake \"/home/${username}/dotfiles\").nixosConfigurations.${hostname}.options";
                  home_manager.expr = "(builtins.getFlake \"/home/${username}/dotfiles\").nixosConfigurations.${hostname}.options.home-manager.users.type.getSubOptions []";
                };
                diagnostic.suppress = [ "sema-extra-with" ];
              };
          };
          rust-analyzer.config = {
            check = {
              command = "clippy";
              extraArgs = [
                "--examples"
                "--tests"
                "--"
                "-Wclippy::pedantic"
              ];
              allTargets = false;
            };
            inlayHints = {
              typeHints.enable = false;
              chainingHints.enable = false;
            };
            cachePriming.enable = false;
          };
        };
      };
      settings = {
        editor = {
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides = {
            render = true;
            character = "▏";
            skip-levels = 1;
          };
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
            prefix-len = 2;
            max-diagnostics = 5;
          };
          lsp = {
            display-inlay-hints = true;
            display-messages = true;
          };
          bufferline = "multiple";
          true-color = true;
          cursorline = true;
        };
        keys = {
          normal = {
            space.space = "file_picker";

            # Swap `a` and `i` because `a` is more convenient to press
            a = "insert_mode";
            i = "append_mode";

            C-s = ":w";
            C-w = ":buffer-close!";
            C-q = ":q";

            y = [
              ":clipboard-yank"
              "yank"
            ];
            C-v = [ ":clipboard-paste-before" ];
          };
          insert = {
            C-s = ":w";
            C-v = [ ":clipboard-paste-before" ];
          };
          select = {
            y = [
              ":clipboard-yank"
              "yank"
            ];
          };
        };
      };
    };
  };
}
