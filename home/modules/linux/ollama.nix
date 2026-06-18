{ pkgs, ... }:
{
  # ollama for local LLMs. On Linux home-manager runs this as a systemd user
  # service. `ollama-vulkan` provides Vulkan acceleration. Pull models manually
  # post-activation (e.g. `ollama pull qwen2.5:7b`).
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    port = 11434;
  };
}
