{ pkgs, inputs, ... }:
{
  home.packages =
    (with pkgs; [
      vim
      fastfetch
      tree
      ffmpeg-full
      imagemagick
      _7zz
      poppler
      resvg
      yt-dlp
      opencode # Will be using a local model instead of Claude on my mac
    ])
    ++ [
      inputs.odysseus-nix.packages.${pkgs.stdenv.hostPlatform.system}.odysseus-dev
    ];
}
