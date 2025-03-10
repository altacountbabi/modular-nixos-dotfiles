# Launch repl with nixpkgs in scope
repl:
    nix repl -f '<nixpkgs>'

# Evaluate `eval.nix` and format the output
eval:
    nix-instantiate --eval --strict eval.nix | nixfmt

# Dry build a config
dryb:
    sudo nixos-rebuild dry-build --flake .\#$(hostname)

# Build a config
b:
    sudo nixos-rebuild build --flake .\#$(hostname)

# NixOS Commands
switch:
    sudo nixos-rebuild switch --flake .\#$(hostname)

# Update flakes and rebuild system
update:
    nix flake update
    just switch

# Clean up /nix/store
gc:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Build a VM with the $(hostname) host
vm:
    sudo nixos-rebuild build-vm --flake .\#$(hostname)

# Clean up after the VM
rmvm:
    rm -rf result nixos.qcow2
