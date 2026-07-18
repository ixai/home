{
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (inputs) try;
in
{
  nixpkgs.config.allowUnfreePredicate = (
    pkg:
    builtins.elem (pkg.pname or (builtins.parseDrvName pkg.name).name) [
      "1password"
      "1password-cli"
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
    pkgs.gh
    pkgs.htop
    pkgs.jq
    pkgs.marp-cli
    pkgs.nixfmt-tree
    pkgs.prettier
    pkgs.ripgrep
    pkgs.ruby
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.tombi
    pkgs.uv
  ]
  ++ [ try.packages.${system}.default ];

  home.file = { };

  home.sessionPath = [
    "$HOME/.local/bin"
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

  programs.chromium.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fzf.enable = true;
  programs.gpg.enable = true;
  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.topgrade = {
    enable = true;

    settings = {
      misc = {
        # We're fully on flakes (no `nix-channel`), so the legacy `nix`
        # step is a no-op — use the `home_manager` step below and the
        # `Update flake inputs` custom command to drive updates.
        #
        # The rest are steps whose binaries live in the read-only Nix
        # store (installed via home-manager), so their bundled
        # self-updaters either fail outright or get clobbered on the
        # next `home-manager switch`:
        #   - tmux         → programs.tmux (Nix path)
        #   - pi           → programs.pi-coding-agent (Nix path)
        #   - uv           → home.packages pkgs.uv (Nix path)
        #   - claude_code  → programs.claude-code (Nix path)
        disable = [
          "tmux"
          "pi"
          "uv"
          "claude_code"
        ];

        cleanup = true;
      };

      # Update flake.lock before the `home_manager` step rebuilds. Order is
      # not guaranteed by topgrade, so on first runs you may need to invoke
      # `topgrade --only "flake-inputs"` once, then run normally.
      commands."flake-inputs" =
        "cd ${config.xdg.configHome}/home-manager && nix flake update --commit-lock-file";
    };
  };
  programs.zoxide.enable = true;
  xdg.enable = true;

  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";
    setOptions = [ "EXTENDED_GLOB" ];
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = ''
      unsetopt beep
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
      eval "$(try init ~/src/tries)"
    '';

    history = {
      path = "$ZDOTDIR/.zhistory";
      size = 10000;
      save = 20000;
    };

    antidote = {
      enable = true;
      plugins = [
        ''
          getantidote/use-omz
          ohmyzsh/ohmyzsh path:lib
          ohmyzsh/ohmyzsh path:plugins/git
          olets/zsh-abbr
          olets/zsh-autosuggestions-abbreviations-strategy
          zsh-users/zsh-autosuggestions
        ''
      ];
    };

    shellAliases = {
      docker-rmall-containers = "docker rm $(docker ps -a -q)";
      docker-rmall-images = "docker rmi -f $(docker images -q)";
      docker-stopall = "docker stop $(docker ps -a -q)";
      vim = "nvim";
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user.name = "Ixai Lanzagorta";

      init.defaultBranch = "main";
      pager.branch = true;
    };
  };

  programs.tmux = {
    enable = true;

    baseIndex = 1;
    clock24 = true;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = "set -g @catppuccin_flavor 'frappe'";
      }
      sensible
      yank
    ];

    extraConfig = ''
      set-option -g default-command "''${SHELL}"  # start a non-login shell
      set-option -g detach-on-destroy no-detached # switch session if available

      # Terminal capabilities
      # set-option -ga terminal-overrides ",*:Tc"   # enable terminfo true colors
      set-option -as terminal-features 'xterm-ghostty:RGB'    # advertise true color support to tmux

      # Extended keys
      set-option -g extended-keys on                          # extended keys (ctrl+enter, shift+enter, ...)
      set-option -g extended-keys-format csi-u                # kitty keyboard protocol
      set-option -as terminal-features 'xterm-ghostty:csi-u'  # Ghostty speaks Kitty natively

      # Windows
      bind-key c new-window -c "#{pane_current_path}" # retain cwd on new window

      # Panes
      bind-key C-l split-window -h -c "#{pane_current_path}"  # split pane right
      bind-key C-j split-window -v -c "#{pane_current_path}"  # split pane down

      bind-key -n C-S-h select-pane -L -Z
      bind-key -n C-S-j select-pane -D -Z
      bind-key -n C-S-k select-pane -U -Z
      bind-key -n C-S-l select-pane -R -Z

      bind-key -n C-S-Left resize-pane -L
      bind-key -n C-S-Down resize-pane -D
      bind-key -n C-S-Up resize-pane -U
      bind-key -n C-S-Right resize-pane -R

      bind-key -n C-S-\; resize-pane -Z
    '';
  };

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    enableZshIntegration = true;

    settings = {
      command = ''${pkgs.zsh}/bin/zsh -c "${pkgs.tmux}/bin/tmux new-session"'';
      cursor-style = "block";
      fullscreen = true;
      keybind = "shift+enter=text:\\n";
      mouse-hide-while-typing = true;
      shell-integration = "zsh";
      theme = "Catppuccin Frappe";
    };
  };

  programs.pi-coding-agent = {
    enable = true;
    context = ./config/agents/AGENTS.md;
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    lspServers = {
      go = {
        args = [ "serve" ];
        command = [ "gopls" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    };

    context = ./config/agents/AGENTS.md;
  };
}
