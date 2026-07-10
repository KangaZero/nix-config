_: {
  programs.claude-code = {
    enable = true;

    # HM writes this to $configDir/settings.json (default ~/.claude/settings.json)
    # and injects the $schema field automatically.
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
  };
}
