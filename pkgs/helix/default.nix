{
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  inherit (pkgs)
    fetchFromGitHub
    lib
    rustPlatform
    git
    installShellFiles
    versionCheckHook
    nix-update-script
    ;
in
rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "25.01.1";

  # This release tarball includes source code for the tree-sitter grammars,
  # which is not ordinarily part of the repository.
  src = fetchFromGitHub {
    owner = "altacountbabi";
    repo = "helix";
    rev = "master";
    sha256 = "sha256-vVhgzdo+T9rn3GuJmJhaWLusQ3DCSx8bESz+VAHc7C0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-isZHpeiUeVb7htmgeHAJFc6tGaodvPYkReA/WFtvl3k=";

  nativeBuildInputs = [
    git
    installShellFiles
  ];

  env = {
    HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";
    HELIX_DEFAULT_RUNTIME = "${placeholder "out"}/lib/runtime";
  };

  postInstall = ''
    mkdir -p $out/lib
    cp -r runtime $out/lib
    installShellCompletion contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
    cp contrib/Helix.desktop $out/share/applications
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/hx";
  versionCheckProgramArg = [ "--version" ];
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Post-modern modal text editor";
    homepage = "https://helix-editor.com";
    changelog = "https://github.com/helix-editor/helix/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    mainProgram = "hx";
  };
}
