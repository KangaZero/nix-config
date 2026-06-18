{
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    port = 11434;
  };
}
