_: {
  home.file.".config/weston.ini".text = ''
    [core]
    shell=kiosk-shell.so

    [output]
    name=wayland0
    mode=preferred
    fullscreen=true
  '';
}
