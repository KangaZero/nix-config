{ userMeta, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "**/.DS_Store"
      ".direnv/"
    ];
    settings = {
      user = {
        name = userMeta.git.personal.name;
        email = userMeta.git.personal.email;
      };
      github.user = userMeta.githubUser;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
      core = {
        autocrlf = "input";
        editor = "nvim";
      };
    };
  };
}
