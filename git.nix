{
  programs.git = {
    enable = true;

    settings = {
      user.name = "Ixai Lanzagorta";

      init.defaultBranch = "main";
      pager.branch = true;
      core.pager = "hunk pager";
      diff.tool = "hunk";
      difftool.hunk.cmd = ''hunk difftool "$LOCAL" "$REMOTE" "$MERGED"'';

      # Launch the difftool without prompting before each file.
      difftool.prompt = false;
    };
  };
}
