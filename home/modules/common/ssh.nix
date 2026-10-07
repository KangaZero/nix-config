{
  programs.ssh = {
    enable = true;

    # Opt out of the legacy implicit defaults. Leaving this true emits
    # "`programs.ssh` default values will be removed in the future" on every
    # evaluation, so the values are restated verbatim under settings."*" below.
    enableDefaultConfig = false;
    # Verbatim copy of what enableDefaultConfig used to inject, so turning it off
    # changes nothing but the warning.
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };
}
