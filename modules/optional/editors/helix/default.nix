{
  getScript,
  mkModule,
  config,
  inputs,
  system,
  pkgs,
  ...
}:

let
  inherit (pkgs.lib) mkEnableOption;

  rofiProjectsPickerScript = getScript "rofi-projects-picker";
in
mkModule {
  name = "Helix IDE";
  path = "editor.helix";
  opts = {
    latest = mkEnableOption "compile from source, this requires a lot of ram!";
  };
  hm = cfg: {
    programs.helix = {
      enable = true;
      package = if cfg.latest then inputs.helix.packages.${system}.default else pkgs.helix;
      extraPackages = with pkgs; [
        # Nix
        nixd
        nixfmt-rfc-style

        # Nushell
        nufmt

        # TOML
        taplo
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
            formatter = {
              command = "bash";
              args = [
                "-c"
                "rustfmt --edition 2024 | dx fmt -f -"
              ];
            };
            language-servers = [ "rust-analyzer" ];
          }
          {
            name = "toml";
            auto-format = true;
            formatter = {
              command = "taplo";
              args = [
                "format"
                "-"
              ];
            };
          }
          {
            name = "nu";
            auto-format = true;
            formatter.command = "nufmt --stdin";
          }
          {
            name = "tl";
            scope = "source.tl";
            injection-regex = "tl";
            file-types = [ "tl" ];
            comment-tokens = "//";
            indent = {
              tab-width = 4;
              unit = "\t";
            };
          }
        ];
        grammar = [
          {
            name = "tl";
            source = {
              git = "https://github.com/PoopyPooOS/tree-sitter-tl";
              rev = "d5bc1d6c3d85c5f4896fac8751ed857e2ae76897";
            };
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
          continue-comments = false;
        };
        keys = {
          normal = {
            space = {
              space = "file_picker_in_current_directory";

              # Swap space.f and space.F
              f = "file_picker_in_current_directory";
              F = "file_picker";

              ${if cfg.latest then "e" else null} = "file_explorer_in_current_directory";
              ${if cfg.latest then "E" else null} = "file_explorer";
            };

            # Swap `a` and `i` because `a` is more convenient to press
            a = "insert_mode";
            i = "append_mode";

            C-s = ":w";
            C-w = ":buffer-close!";
            C-q = ":q";

            p = "paste_before";
            P = "paste_after";

            ret = "goto_word";

            X = "extend_line_above";

            y = [
              ":clipboard-yank"
              "yank"
            ];
            C-v = ":clipboard-paste-before";

            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];

            tab = "goto_next_buffer";
            A-tab = "goto_previous_buffer";

            A-w = ":sh ${rofiProjectsPickerScript} add $PWD && echo \"Saved \"$PWD\" to recent projects\"";
          };
          insert = {
            C-s = ":w";
            C-w = ":buffer-close!";
            C-q = ":q";

            C-v = [ ":clipboard-paste-before" ];
          };
          select = {
            y = [
              ":clipboard-yank"
              "yank"
            ];
            X = "extend_line_above";
          };
        };
      };
    };

    xdg.configFile = {
      "helix/runtime/queries/tl".source = ./tl-queries;
    };
  };
}
