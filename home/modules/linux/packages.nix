{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wget
    openssh
    tldr
    ffmpeg-full
    unzip
    uv
    (azure-cli.withExtensions [ azure-cli-extensions.azure-devops ])
  ];
}
