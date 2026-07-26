{
  pkgs,
  inputs,
  system,
  treefmt,
  ...
}:

let
  inherit (inputs) try;
in
{
  imports = [
    ./bun.nix
    ./claude-code.nix
    ./ghostty.nix
    ./git.nix
    ./pi-coding-agent.nix
    ./tmux.nix
    ./topgrade.nix
    ./zsh.nix
  ];

  nixpkgs.config.allowUnfreePredicate = (
    pkg:
    builtins.elem (pkg.pname or (builtins.parseDrvName pkg.name).name) [
      "1password"
      "1password-cli"
      "1password-gui"
      "claude-code"
      "obsidian"
      "terraform"
      "vscode"
    ]
  );
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # Manage ~/.config/nix/nix.conf (user-level). Nix reads this file by
  # default, so it takes effect alongside /etc/nix/nix.conf for this user.
  # `nix.package` is required by the home-manager `nix` module to generate /
  # validate the file; it is not added to home.packages automatically.
  nix.package = pkgs.nix;
  nix.settings = (import ./nix-common.nix).settings;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs._1password-cli
    pkgs.ast-grep
    pkgs.bat
    pkgs.curl
    pkgs.difftastic
    pkgs.fd
    pkgs.gci
    pkgs.gopls
    pkgs.gh
    pkgs.htop
    pkgs.httpie
    pkgs.jq
    pkgs.marp-cli
    pkgs.prettier
    pkgs.ripgrep
    pkgs.ruby
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.tombi
    pkgs.uv
    pkgs.xq
    pkgs.yq-go
    treefmt
  ]
  ++ [ try.packages.${system}.default ];

  home.file = { };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cache/.bun/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";

    LESS = "-R --mouse --wheel-lines=3";

    ANSIBLE_NOCOWS = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    ZSH_DISABLE_COMPFIX = "1";
    MIRRORD_CHECK_VERSION = "false";

    # Disable Claude Code auto-updater so it doesn't override the nix-managed version
    DISABLE_AUTOUPDATER = "1";
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fzf.enable = true;
  programs.gpg.enable = true;
  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  xdg.enable = true;
}
