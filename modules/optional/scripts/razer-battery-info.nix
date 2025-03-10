{
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "razer-battery-info";
  runtimeInputs = with pkgs; [
    libnotify
    razer-cli
  ];
  text =
    let
      timeout = 5000;
    in
    ''
      info=$(razer-cli --battery print)
      # get the first line
      summary=$(echo "$info" | head -n 1)
      # get second and third lines and trim the leading whitespace
      body=$(echo "$info" | sed -n '2,3p' | sed 's/^[[:space:]]*//')

      notify-send -t "${builtins.toString timeout}" "$summary" "$body"
    '';
}
