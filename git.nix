{
  programs.git = {
    enable = true;

    settings = {
      user.name = "Ixai Lanzagorta";

      init.defaultBranch = "main";
      pager.branch = true;
      core.pager = "hunk pager";

      # Launch the difftool without prompting before each file.
      difftool.prompt = false;
    };
  };
}
