_: {
  # ollama for local LLMs. On macOS home-manager runs this as a launchd agent
  # (`ollama serve` on login). The default `pkgs.ollama` builds with Metal
  # acceleration on darwin. Pull models manually post-activation
  # (e.g. `ollama pull qwen2.5:7b`).
  services.ollama = {
    enable = true;
    port = 11434;
  };
}
