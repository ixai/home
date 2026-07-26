{ pkgs, ... }:
{
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
}
