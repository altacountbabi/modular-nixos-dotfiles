if [ "$(id -u)" -eq 0 ]; then
    echo "Error: this script can not be ran as root."
    exit 1
fi

if [ ! -d "$HOME/dotfiles/.git" ]; then
    git clone https://github.com/altacountbabi/modular-nixos-dotfiles "$HOME/dotfiles"
fi

DISKO_CONFIG="$HOME/dotfiles/modules/optional/disko.nix"

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

HOSTS=$(find ~/dotfiles/hosts -type f -name "config.nix" -printf "%h\n" | awk -F'/' '{print $(NF)}')
CHOICES=$(echo -e "$HOSTS\nCreate New")
TARGET_HOST=$(echo -e "$CHOICES" | gum choose --header "Please pick a host to use or create a new one")

if [ "$TARGET_HOST" = "Create New" ]; then
    NEW_HOST_NAME=$(gum input --placeholder "New host name")
    echo "What GPU brand do you have?"
    GPU_TYPE=$(gum choose "AMD" "NVIDIA" "None" --height=5 | awk '{print tolower($0)}')

    mkdir -p ~/dotfiles/hosts/"$NEW_HOST_NAME"
    # Copy base config
    cp ~/dotfiles/pkgs/installer/base.nix ~/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    # Set GPU type
    sed -i "s/GPU_TYPE/$GPU_TYPE/g" ~/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    # Set hostname
    sed -i "s/HOSTNAME/$NEW_HOST_NAME/g" ~/dotfiles/hosts/"$NEW_HOST_NAME"/config.nix

    TARGET_HOST=$NEW_HOST_NAME
fi

# Prompt for what disk to install to
DISK=$(lsblk -d -o NAME,TYPE | grep -E 'disk|part' | awk '{print "/dev/" $1}' | gum choose --header "What disk do you want to install to?")

if ! gum confirm --default=false "Are you sure you want to install to $DISK? This operation will ERASE ALL DATA from the disk."; then
    echo "Exiting"
    exit 0
fi

gum spin --spinner line --title "Installing NixOS..." -- sleep 5