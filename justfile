# Debugging
repl:
    nix repl -f '<nixpkgs>'

eval:
    nix-instantiate --eval --strict eval.nix | nixfmt

# Build Commands
dryb:
    sudo nixos-rebuild dry-build --flake .\#$(hostname) --option eval-cache false --show-trace

b:
    sudo nixos-rebuild build --flake .\#$(hostname) --option eval-cache false --show-trace

# NixOS Commands
switch:
    sudo nixos-rebuild switch --flake .\#$(hostname) --option eval-cache false --show-trace

update:
    nix flake update
    just switch

gc:
    sudo nix-collect-garbage -d

# VM Commands
vm:
    sudo nixos-rebuild build-vm --flake .\#$(hostname) --option eval-cache false --show-trace

rmvm:
    rm -rf result nixos.qcow2