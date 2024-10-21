repl:
    nix repl -f '<nixpkgs>'

# Build Commands
dryb:
    sudo nixos-rebuild dry-build --flake .\#$(hostname) --option eval-cache false --show-trace

b:
    sudo nixos-rebuild build --flake .\#$(hostname) --option eval-cache false --show-trace


# Switch Command
switch:
    sudo nixos-rebuild switch --flake .\#$(hostname) --option eval-cache false --show-trace


# VM Commands
vm:
    sudo nixos-rebuild build-vm --flake .\#$(hostname) --option eval-cache false --show-trace

rmvm:
    rm -rf result nixos.qcow2