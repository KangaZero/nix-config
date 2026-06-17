_: {
  # Safety net: if WSL/terminal launches bash, hop to zsh.
  # Pair with `chsh -s "$(command -v zsh)"` (see README) for $SHELL correctness.
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $- == *i* ]] && [[ -z "$ZSH_VERSION" ]] && command -v zsh >/dev/null; then
        exec zsh -l
      fi
    '';
  };
}
