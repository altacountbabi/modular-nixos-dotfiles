repl:
    nix repl -f '<nixpkgs>'

dryb:
    sudo nixos-rebuild dry-build --flake .\#$(hostname) --option eval-cache false --show-trace

switch:
    sudo nixos-rebuild switch --flake .\#$(hostname) --option eval-cache false --show-trace


vm:
    sudo nixos-rebuild build-vm --flake .\#$(hostname) --option eval-cache false --show-trace

rmvm:
    rm -rf result nixos.qcow2