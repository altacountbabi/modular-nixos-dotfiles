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
          "rust"
          "nix"
          "toml"
          "tauri"
          "svelte"
          # "nu"
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
        tauri = [ tauri-apps.tauri-vscode ];
        svelte = [ svelte.svelte-vscode ];
        # FIXME: Extension is just not in the flake for some reason.
        # nu = [ TheNuProjectContributors.vscode-nushell-lang ];
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
            wayou.vscode-todo-highlight
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
          # Even though im using catppuccin mocha this has better icon colors in my opinion.
          "workbench.iconTheme" = mkIf catppuccinCfg.enable "catppuccin-perfect-${
            if catppuccinCfg.flavor == "mocha" then "macchiato" else catppuccinCfg.flavor
          }";
          "workbench.colorTheme" =
            mkIf catppuccinCfg.enable "Catppuccin ${uppercaseFirstChar catppuccinCfg.flavor}";

          "workbench.editor.enablePreview" = false;
          "workbench.editor.tabSizing" = "shrink";

          "workbench.layoutControl.enabled" = false;
          "workbench.list.smoothScrolling" = true;
          "workbench.statusBar.visible" = false;
          "workbench.startupEditor" = "none";
          "workbench.tips.enabled" = false;
          "workbench.tree.indent" = 16;

          "explorer.confirmDragAndDrop" = true;
          "explorer.confirmDelete" = false;

          "editor.cursorSmoothCaretAnimation" = "on";
          "editor.cursorBlinking" = "phase";
          "editor.minimap.enabled" = false;
          "editor.smoothScrolling" = true;
          "editor.fontLigatures" = true;
          "editor.linkedEditing" = true;
          "editor.formatOnSave" = true;
          "editor.fontFamily" = "monospace";
          "editor.lineHeight" = 2;

          "breadcrumbs.enabled" = false;

          "zenMode.centerLayout" = false;
          "zenMode.fullScreen" = false;
          "zenMode.hideLineNumbers" = false;

          "git.openRepositoryInParentFolders" = "never";
          "git.postCommitCommand" = "push";
          "git.enableSmartCommit" = true;
          "git.confirmSync" = false;

          "window.confirmSaveUntitledWorkspace" = false;
          "window.menuBarVisibility" = "toggle";
          "window.titleBarStyle" = "native";
          "window.dialogStyle" = "custom";
          "window.commandCenter" = false;
          "window.zoomLevel" = 1;

          "terminal.integrated.fontFamily" = "FiraCode Nerd Font Ret";
          "terminal.integrated.cursorStyleInactive" = "line";
          "terminal.integrated.cursorStyle" = "line";
          "terminal.integrated.fontSize" = 13;

          # Misc Settings
          "security.workspace.trust.untrustedFiles" = "open";
          "extensions.ignoreRecommendations" = true;
          "files.trimTrailingWhitespace" = true;
          "keyboard.dispatch" = "keyCode";

          ## Language Specific
          # Rust
          "[rust]"."editor.defaultFormatter" = mkIf (elem "rust" cfg.languages) "rust-lang.rust-analyzer";

          # Only check cargo projects when needed
          "rust-analyzer.cachePriming.enable" = mkIf (elem "rust" cfg.languages) false;
          "rust-analyzer.check.allTargets" = mkIf (elem "rust" cfg.languages) false;

          # Use clippy
          "rust-analyzer.check.command" = mkIf (elem "rust" cfg.languages) "clippy";
          "rust-analyzer.check.extraArgs" = mkIf (elem "rust" cfg.languages) (
            splitString " " "-- -Wclippy::pedantic"
          );

          # Disable inlay hints
          "rust-analyzer.inlayHints.typeHints.enable" = mkIf (elem "rust" cfg.languages) false;
          "rust-analyzer.inlayHints.chainingHints.enable" = mkIf (elem "rust" cfg.languages) false;

          # Nix
          "[nix]"."editor.defaultFormatter" = mkIf (elem "nix" cfg.languages) "brettm12345.nixfmt-vscode";
          "[nix]"."editor.tabSize" = mkIf (elem "nix" cfg.languages) 2;
          "nix.serverSettings"."nil.diagnostics.ignored" = mkIf (elem "nix" cfg.languages) [
            "unused_binding"
          ];
          "nix.enableLanguageServer" = elem "nix" cfg.languages;

          # Markdown
          "[markdown]"."files.trimTrailingWhitespace" = false;

          # JS/TS
          "javascript.updateImportsOnFileMove.enabled" = "always";
          "typescript.updateImportsOnFileMove.enabled" = "always";

          # Svelte
          "svelte.enable-ts-plugin" = elem "svelte" cfg.languages;
        };
      };
    };
}
