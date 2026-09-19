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
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_action 'copy-pipe' # copy on mouse selection and stay in copy mode (don't scroll back down)
        '';
      }
    ];

    extraConfig = ''
      set-option -g default-command "''${SHELL}"  # start a non-login shell
      set-option -g detach-on-destroy no-detached # switch to an available session on exit

      # Terminal capabilities
      set-option -as terminal-features 'xterm-ghostty:RGB' # advertise true color support to tmux

      # Extended keys
      set-option -g extended-keys on                          # extended keys (ctrl+enter, shift+enter, ...)
      set-option -g extended-keys-format csi-u                # use the kitty keyboard protocol (generic?)
      set-option -as terminal-features 'xterm-ghostty:csi-u'  # use the kitty keyboard protocl (ghostty)

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

      # Copy mode: copy on double/triple click and stay in copy mode
      set-option -g set-clipboard on                            # sync clipboard via OSC 52
      bind-key -T root DoubleClick1Pane select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe }
      bind-key -T root TripleClick1Pane select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe }
      bind-key -T copy-mode-vi DoubleClick1Pane select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe
      bind-key -T copy-mode-vi TripleClick1Pane select-pane \; send-keys -X select-line \; run-shell -d 1.3 \; send-keys -X copy-pipe
    '';
  };
}
