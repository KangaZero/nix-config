{ pkgs, ... }: {
  # ollama for local LLMs. On macOS home-manager runs this as a launchd agent
  # (`ollama serve` on login). The default `pkgs.ollama` builds with Metal
  # acceleration on darwin. Pull models manually post-activation
  # (e.g. `ollama pull qwen2.5:7b`).
  programs.opencode = {
    enable = true;
    settings = {
      # Frontend MCP servers.
      #
      # `shadcn@latest mcp` is the canonical shadcn/ui registry server. It also
      # serves the @canvas-ui registry (canvasui.dev — tasteful html-in-canvas
      # components): Canvas UI is a trusted shadcn registry, so its components
      # are browsable/installable via this same server out of the box
      # (e.g. `npx shadcn@latest add @canvas-ui/liquid-react`).
      mcp = {
        shadcn = {
          type = "local";
          command = [
            "npx"
            "-y"
            "shadcn@latest"
            "mcp"
          ];
          enabled = true;
        };
        # Browser automation for previewing & testing Next.js/React apps.
        playwright = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@playwright/mcp"
          ];
          enabled = true;
        };
      };
    }; # → opencode.json (the main config)
    context = ""; # (formerly "rules")
    agents = { };
    commands = { };
    skills = { };
    themes = { };
    tools = { };
    tui = { };
    enableMcpIntegration = true;
    # Frontend toolchain for Next.js/React dev. nodejs is required — it ships
    # npx, which launches the MCP servers above. pnpm is the package manager;
    # typescript provides tsc for type-checking.
    extraPackages = [
      pkgs.nodejs
      pkgs.pnpm
      pkgs.typescript
    ];
    package = pkgs.opencode;
    web = {
      enable = false;
    };
  };
}
