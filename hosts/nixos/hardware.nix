{ pkgs, ... }: {
  hardware.uinput.enable = true;

  # WSL2: systemd-modules-load is skipped (kernel cmdline conditions unmet),
  # so boot.kernelModules never fires. Load uinput explicitly at startup.
  systemd.services.load-uinput = {
    description = "Load uinput kernel module";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/modprobe uinput";
      RemainAfterExit = true;
    };
  };
}
