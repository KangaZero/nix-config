{ pkgs }: {
  # ollama for local LLMs. On macOS home-manager runs this as a launchd agent
  # (`ollama serve` on login). The default `pkgs.ollama` builds with Metal
  # acceleration on darwin. Pull models manually post-activation
  # (e.g. `ollama pull qwen2.5:7b`).
  programs.opencode = {
    enable = true;
    settings = { }; # → opencode.json (the main config)
    context = ""; # (formerly "rules")
    agents = { };
    commands = { };
    skills = { };
    themes = { };
    tools = { };
    tui = { };
    enableMcpIntegration = false;
    extraPackages = [ ];
    package = pkgs.opencode;
    web = {
      enable = false;
    };
  };
}
