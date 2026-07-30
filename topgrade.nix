{
  programs.topgrade = {
    enable = true;

    settings = {
      misc = {
        # Disable updates for nix-managed binaries
        disable = [
          "claude_code"
          "gcloud"
          "tmux"
          "uv"
        ];

        cleanup = true;
        assume_yes = true;
        ask_retry = false;
      };
    };
  };
}
