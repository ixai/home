{
  programs.topgrade = {
    enable = true;

    settings = {
      misc = {
        # Disable updates for nix-managed binaries
        disable = [
          "tmux"
          "uv"
          "claude_code"
        ];

        cleanup = true;
      };
    };
  };
}
