_: {
  home.file.".config/weston.ini".text = ''
    [core]
    shell=kiosk-shell.so
    # Lower frame-collection window before present. Default 7ms. 1ms = minimum
    # latency at the cost of slightly higher CPU wake frequency.
    repaint-window=1
    # Explicitly request GL renderer. Without this, weston may silently fall back
    # to pixman (pure software) if GL init is slow — significant perf regression.
    renderer=gl
    # Disable screen blanking. Default is 300s; useless in WSL2 where Windows
    # manages the display lifecycle.
    idle-time=0

    [keyboard]
    # Default repeat-delay ~660ms feels sluggish. 200ms = much snappier held keys.
    repeat-delay=200
    # Default repeat-rate ~25 cps. 40 cps matches a fast typist's expectation.
    repeat-rate=40

    [output]
    name=wayland0
    mode=preferred
    fullscreen=true
    # Forwarded to WSLg via the content-type Wayland protocol hint. May signal
    # the Windows host compositor to reduce internal frame buffering for this surface.
    content-type=game
  '';
}
