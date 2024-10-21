{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "volume";
  runtimeInputs = with pkgs; [ pamixer ];
  text =
    let
      osdTimeout = 2500;
    in
    ''
      create_volume_bar() {
        volume=$1
        bar=""
        steps=$((volume / 10))

        for ((i = 0; i < 10; i++)); do
          if ((i < steps)); then
            bar+="▰"
          else
            bar+="▱"
          fi
        done

        echo "$bar"
      }

      update_ui() {
        volume=$($0 g)
        volume_bar=$(create_volume_bar "$volume")

        notify-send -t "${builtins.toString osdTimeout}" "$volume_bar $volume"
      }

      case $1 in
        t)
          pamixer --toggle-mute
          update_ui
          ;;
        i)
          pamixer --increase "$2"
          update_ui
          ;;
        d)
          pamixer --decrease "$2"
          update_ui
          ;;
        g)
          if [ "$(pamixer --get-mute)" = true ]; then
            echo 0
          else
            pamixer --get-volume
          fi
          ;;
      esac
    '';
}
