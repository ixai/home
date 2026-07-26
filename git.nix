{
  programs.git = {
    enable = true;

    settings = {
      user.name = "Ixai Lanzagorta";

      init.defaultBranch = "main";
      pager.branch = true;

      # Launch the difftool without prompting before each file.
      difftool.prompt = false;
    };
  };
}
