{ ... }:
{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xrdp = {
    enable = true;
    port = 3390;
    openFirewall = true;
  };
}
