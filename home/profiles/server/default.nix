# Single source of truth for identity: the server reuses the KangaZero user
# (username stays "KangaZero", home dir /home/KangaZero) so noctalia's hardcoded
# asset paths resolve. Only the home profile (linux.nix) diverges — this box is
# bare-metal, so it drops the WSL-only weston bridge + software-GL fallback.
import ../KangaZero/default.nix
