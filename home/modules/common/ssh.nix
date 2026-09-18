{
  programs.ssh = {
    enable = true;

    # Opt out of the legacy implicit defaults. Leaving this true emits
    # "`programs.ssh` default values will be removed in the future" on every
    # evaluation, so the values are restated verbatim under settings."*" below.
    enableDefaultConfig = false;

    matchBlocks = {
      # This network blocks outbound port 22, so `git@github.com` times out:
      #   ssh: connect to host github.com port 22: Connection timed out
      # GitHub serves the same SSH endpoint on 443. Rewriting the host here means
      # the plain `git@github.com:...` remotes keep working untouched, rather than
      # every repo needing an HTTPS URL (which also leaves refs/remotes/* stale,
      # since pushing to a URL does not update the tracking ref).
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
    };

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
