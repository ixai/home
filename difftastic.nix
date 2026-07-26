{
  programs.difftastic = {
    enable = true;

    git = {
      enable = true;
      # Configure difftastic only as a git difftool (`git difftool`); leave
      # plain `git diff` untouched.
      mode = "difftool";
    };
  };
}
