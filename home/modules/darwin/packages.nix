{ pkgs, inputs, ... }:
{
  home.packages =
    (with pkgs; [
      ani-cli
      vim
      fastfetch
      tree
      ffmpeg-full
      imagemagick
      _7zz
      poppler
      resvg
      yt-dlp
    ])
    ++ [
      inputs.odysseus-nix.packages.${pkgs.stdenv.hostPlatform.system}.odysseus-dev
    ];
}
