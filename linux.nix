{
  config,
  pkgs,
  inputs,
  system,
  ...
}:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.hermes-agent.homeManagerModules.default
    inputs.stasis.homeModules.default
    ./hermes-agent.nix
    ./niri.nix
    ./power.nix
  ];

  home.username = "ixai";
  home.homeDirectory = "/home/ixai";

  home.sessionVariables = {
    npm_config_prefix = "$HOME/.local";
  };

  home.packages = [
    pkgs._1password-cli
    pkgs._1password-gui
    # pkgs.keybase-gui
    pkgs.dos2unix
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
  };

  programs.chromium.enable = true;

  services.keybase.enable = true;
  services.kbfs.enable = true;

  programs.zsh = {
    initContent = ''
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
    '';

    profileExtra = ''
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
      if uwsm check may-start; then
          exec uwsm start default
      fi
    '';
  };

  programs.git = {
    enable = true;
    settings.user.email = "ixai.lanzagorta@gmail.com";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.ollama = {
    enable = true;
    # acceleration = "rocm";
    environmentVariables = {
      ROCR_VISIBLE_DEVICES = "1";
    };
  };
}
