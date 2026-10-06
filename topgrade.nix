{ config, ... }:
{
  programs.topgrade = {
    enable = true;

    settings = {
      misc = {
        # Disable updates for nix-managed binaries
        disable = [
          "claude_code"
          "gcloud"
          "pi"
          "tmux"
          "uv"
        ];

        cleanup = true;
        assume_yes = true;
        ask_retry = false;
      };

      # Topgrade skips its `nix` and `home_manager` steps on nix-darwin hosts
      # and has no darwin-rebuild step. The Makefile selects the flake inputs
      # and activation layers for the current host, so it stays the single
      # source of that logic.
      commands = {
        "Nix flake" = "make --directory ${config.xdg.configHome}/home-manager update switch";
      };
    };
  };
}
