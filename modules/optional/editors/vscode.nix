{
  mkModule,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types mkIf;
  inherit (lib.strings) splitString;
  inherit (builtins) concatLists elem;
in
mkModule {
  name = "editor.vscode";
  path = "editor.vscode";
  opts = with types; {
    languages =
      let
        languages = [
          "svelte"
          "tauri"
          "rust"
          "toml"
          "nix"
        ];
      in
      mkOption {
        type = listOf (enum languages);
        description = "List of languages to have extensions for in vscode";
        default = languages;
      };
  };
  hm =
    cfg:
    let
      vscodeExts = inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace;
      languageExtensions = with vscodeExts; {
        rust = [ rust-lang.rust-analyzer ];
        nix = [
          brettm12345.nixfmt-vscode
          jnoortheen.nix-ide
        ];
        toml = [ tamasfe.even-better-toml ];
        svelte = [ svelte.svelte-vscode ];
        tauri = [ tauri-apps.tauri-vscode ];
      };

      catppuccinCfg = config.modules.colorscheme.catppuccin;

      uppercaseFirstChar =
        word:
        with lib;
        let
          firstChar = substring 0 1 word;
          rest = substring 1 (stringLength word) word;
        in
        "${toUpper firstChar}${rest}";
    in
    {
      home.packages = [ pkgs.vscode ];

      programs.vscode = {
        enable = true;
        enableUpdateCheck = false;
        extensions =
          with vscodeExts;
          [
            cardinal90.multi-cursor-case-preserve
            usernamehw.errorlens
            albert.tabout
          ]
          ++ concatLists (map (lang: languageExtensions."${lang}") cfg.languages)
          ++ (
            if catppuccinCfg.enable then
              [
                thang-nm.catppuccin-perfect-icons
                catppuccin.catppuccin-vsc
              ]
            else
              [ ]
          );
        userSettings = {
          workbench = {
            # Even though im using catppuccin mocha this has better icon colors in my opinion.
            iconTheme = mkIf catppuccinCfg.enable "catppuccin-perfect-${
              if catppuccinCfg.flavor == "mocha" then "macchiato" else catppuccinCfg.flavor
            }";
            colorTheme = mkIf catppuccinCfg.enable "Catppuccin ${uppercaseFirstChar catppuccinCfg.flavor}";

            editor = {
              enablePreview = false;
              tabSizing = "shrink";
            };
            layoutControl.enabled = false;
            list.smoothScrolling = true;
            statusBar.visible = false;
            startupEditor = "none";
            tips.enabled = false;
            tree.indent = 16;
          };

          explorer = {
            confirmDragAndDrop = true;
            confirmDelete = false;
          };

          editor = {
            cursorSmoothCaretAnimation = "on";
            cursorBlinking = "phase";
            minimap.enabled = false;
            smoothScrolling = true;
            fontLigatures = true;
            linkedEditing = true;
            formatOnSave = true;
            fontFamily = "monospace";
            lineHeight = 2;
          };

          zenMode = {
            centerLayout = false;
            fullScreen = false;
            hideLineNumbers = false;
          };

          git = {
            openRepositoryInParentFolders = "never";
            postCommitCommand = "push";
            enableSmartCommit = true;
            confirmSync = false;
          };

          window = {
            confirmSaveUntitledWorkspace = false;
            menuBarVisibility = "toggle";
            titleBarStyle = "native";
            dialogStyle = "custom";
            commandCenter = false;
            zoomLevel = 1;
          };

          terminal.integrated = {
            fontFamily = "FiraCode Nerd Font Ret";
            cursorStyleInactive = "line";
            cursorStyle = "line";
            fontSize = 13;
          };

          # Misc Settings
          security.workspace.trust.untrustedFiles = "open";
          extensions.ignoreRecommendations = true;
          files.trimTrailingWhitespace = true;
          keyboard.dispatch = "keyCode";

          ## Language Specific
          # Rust
          "[rust]".editor.defaultFormatter = mkIf (elem "rust" cfg.languages) "rust-lang.rust-analyzer";
          rust-analyzer = mkIf (elem "rust" cfg.languages) {
            # Only check cargo projects when needed
            cachePriming.enabled = false;
            check = {
              allTargets = false;

              # Use clippy
              command = "clippy";
              extraArgs = splitString " " "-- -Wclippy::pedantic";

              # Disable inlay hints
              inlayHints = {
                typeHints.enable = false;
                chainingHints.enable = false;
              };
            };
          };

          # Nix
          "[nix]".editor = mkIf (elem "nix" cfg.languages) {
            defaultFormatter = "brettm12345.nixfmt-vscode";
            tabSize = 2;
          };
          nix = mkIf (elem "nix" cfg.languages) {
            serverSettings.nil.diagnostics.ignored = [ "unused_binding" ];
            enableLanguageServer = true;
          };

          # Markdown
          "[markdown]".files.trimTrailingWhitespace = false;

          # JS/TS
          javascript.updateImportsOnFileMove.enabled = "always";
          typescript.updateImportsOnFileMove.enabled = "always";

          # Svelte
          svelte.enable-ts-plugin = mkIf (elem "svelte" cfg.languages) true;
        };
      };
    };
}
