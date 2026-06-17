_: {
  services = {
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };
    xrdp = {
      enable = true;
      port = 3390;
      openFirewall = true;
    };
  };
}
