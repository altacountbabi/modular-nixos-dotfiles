if [ "$(id -u)" -eq 0 ]; then
    echo "Error: this script can not be ran as root."
    exit 1
fi

if [ ! -d "/tmp/dotfiles/.git" ]; then
    git clone https://github.com/altacountbabi/modular-nixos-dotfiles "/tmp/dotfiles"
fi

DISKO_CONFIG="/tmp/dotfiles/modules/optional/disko.nix"

if [ ! -e "$DISKO_CONFIG" ]; then
    echo "Error: unable to find disko config at \"$DISKO_CONFIG\""
fi

export GUM_CHOOSE_HEADER_FOREGROUND=""
export GUM_CHOOSE_CURSOR_FOREGROUND=""
export GUM_CHOOSE_SELECTED_FOREGROUND="4"
export GUM_INPUT_CURSOR_FOREGROUND=""
export GUM_INPUT_CURSOR_FOREGROUND=""
export GUM_CONFIRM_PROMPT_FOREGROUND=""
export GUM_CONFIRM_SELECTED_BACKGROUND="4"
export GUM_SPIN_SPINNER_FOREGROUND="4"
export GUM_SPIN_SPINNER="line"

HOSTS=$(find /tmp/dotfiles/hosts -type f -name "config.nix" -printf "%h\n" | awk -F'/' '{print $(NF)}')
CHOICES=$(echo -e "$HOSTS\nCreate New")
TARGET_HOST=$(echo -e "$CHOICES" | gum choose --header "Please pick a host to use or create a new one")

# TODO: Add the new host to the `mkHosts` call so that the new host is actually usable.
if [ "$TARGET_HOST" = "Create New" ]; then
    NEW_HOST_NAME=$(gum input --placeholder "New host name")
    echo "What GPU brand do you have?"
    GPU_TYPE=$(gum choose "AMD" "NVIDIA" "None" --height=5 | awk '{print tolower($0)}')

    mkdir -p /tmp/dotfiles/hosts/"$NEW_HOST_NAME"
    # Copy base config
    cp /tmp/dotfiles/pkgs/installer/base.nix /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    # Set GPU type
    sed -i "s/GPU_TYPE/$GPU_TYPE/g" /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    # Set hostname
    sed -i "s/HOSTNAME/$NEW_HOST_NAME/g" /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    TARGET_HOST=$NEW_HOST_NAME
fi

echo "Generating hardware config..."
nixos-generate-config --root /tmp/hwconf --no-filesystems
cp "/tmp/hwconf/etc/nixos/hardware-configuration.nix" /tmp/dotfiles/hosts/"$TARGET_HOST"/hardware.nix

# Prompt for what disk to install to:
# list disks | remove first line of lsblk | prefix disk name with `/dev/` | choose from disks
DISK=$(lsblk -d -o NAME,TYPE | grep -E 'disk|part' | awk '{print "/dev/" $1}' | gum choose --header "What disk do you want to install to?")

# Set disko module `device` option
sed -i "s|DISKO_DEVICE|$DISK|g" /tmp/dotfiles/hosts/"$TARGET_HOST"/config.nix

if ! gum confirm --default=false "Are you sure you want to install to $DISK? This operation will ERASE ALL DATA from the disk."; then
    echo "Exiting"
    exit 0
fi

sudo nix run "github:nix-community/disko/latest#disko-install" --extra-experimental-features "nix-command flakes" -- --write-efi-boot-entries --flake "/tmp/dotfiles/#$TARGET_HOST" --disk "main" "$DISK"
# gum spin --title "Partitioning disks..." -- sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" --no-write-lock-file -- --mode destroy,format,mount "/tmp/dotfiles/pkgs/installer/disko.nix"
# gum spin --title "Installing NixOS... (this may take a while)" -- sudo nixos-install --flake "/tmp/dotfiles/#$TARGET_HOST"