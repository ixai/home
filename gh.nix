{
  programs.gh = {
    enable = true;

    # Git credential handling is configured explicitly per-host (gh on Linux,
    # gcm-core on Darwin), so keep the module from also registering itself as a
    # credential helper and colliding with those settings.
    gitCredentialHelper.enable = false;
  };
}
