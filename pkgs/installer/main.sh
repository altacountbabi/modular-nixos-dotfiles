# shellcheck disable=SC2148
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

if [ "$TARGET_HOST" = "Create New" ]; then
    NEW_HOST_NAME=$(gum input --placeholder "New host name")
    echo "What GPU brand do you have?"
    GPU_TYPE=$(gum choose "AMD" "NVIDIA" "None" --height=5 | awk '{print tolower($0)}')

    mkdir -p /tmp/dotfiles/hosts/"$NEW_HOST_NAME"
    # Copy base config
    cp /tmp/dotfiles/pkgs/installer/base.nix /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix
    # Copy disko config
    cp /tmp/dotfiles/pkgs/installer/disko_base.nix /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/disko.nix

    # Set GPU type
    sed -i "s/GPU_TYPE/$GPU_TYPE/g" /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    # Set hostname
    sed -i "s/HOSTNAME/$NEW_HOST_NAME/g" /tmp/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    # Add new host to flake
    sed -i '/# config-placeholder/c\
        {\
          system = "x86_64-linux";\
          host = '"\"$NEW_HOST_NAME\""';\
        }\
        # config-placeholder' /tmp/dotfiles/flake.nix

    TARGET_HOST=$NEW_HOST_NAME
fi

echo "Generating hardware config..."
nixos-generate-config --root /tmp/hwconf --no-filesystems
cp "/tmp/hwconf/etc/nixos/hardware-configuration.nix" /tmp/dotfiles/hosts/"$TARGET_HOST"/hardware.nix

# Prompt for what disk to install to:
# list disks | remove first line of lsblk | prefix disk name with `/dev/` | choose from disks
DISK=$(lsblk -d -o NAME,TYPE | grep -E 'disk|part' | awk '{print "/dev/" $1}' | gum choose --header "What disk do you want to install to?")

# Set disko module `device` option
sed -i "s|DISKO_DEVICE|$DISK|g" /tmp/dotfiles/hosts/"$TARGET_HOST"/disko.nix

if gum confirm --default=false "Do you want to modify the disko configuration file?"; then
    $EDITOR /tmp/dotfiles/hosts/"$TARGET_HOST"/disko.nix
fi

if ! gum confirm --default=false "Are you sure you want to install to $DISK? This operation will ERASE ALL DATA from the disk."; then
    echo "Exiting"
    exit 0
fi

echo "Partitioning disks..."
sudo nix run github:nix-community/disko --extra-experimental-features "nix-command flakes" --no-write-lock-file -- --mode destroy,format,mount /tmp/dotfiles/hosts/"$TARGET_HOST"/disko.nix --yes-wipe-all-disks

echo "Installing NixOS... (this may take a while)"
(
    # shellcheck disable=SC2164
    cd /tmp/dotfiles
    git add -A
)

if find /mnt/home -maxdepth 1 -type d | grep -q .; then
    cp -r /tmp/dotfiles /mnt/home/dotfiles
    echo "Copied config to installation."
else
    echo "No user was setup in installation, unable to copy config."
fi


if sudo nixos-install --flake "/tmp/dotfiles/#$TARGET_HOST"; then
    if gum confirm --default=yes "Installation complete, would you like to reboot now?"; then
        sudo reboot
    fi
fi