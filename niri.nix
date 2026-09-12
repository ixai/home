{ inputs, system, ... }:
{
  wayland.windowManager.niri = {
    enable = true;

    # Use niri's own flake instead of nixpkgs, for a more current build.
    package = inputs.niri.packages.${system}.default;

    # `checkConfig` (which defaults to on once `package` is set) runs `niri
    # validate` at build time, but the config's `include "dms/*.kdl"` files
    # live only in the real $HOME, not in the repo, so validation would
    # always fail in the Nix sandbox.
    checkConfig = false;

    # Session startup goes through uwsm (see linux.nix), not niri's own
    # systemd units, and no portal is configured elsewhere in this repo.
    systemd.enable = false;
    portalPackage = null;
    xwaylandSatellitePackage = null;

    settings = {
      input = {
        keyboard = {
          xkb.layout = "us";
          # caps:ctrl_modifier,ctrl:swapcaps -> swap Caps Lock and Ctrl
          xkb.options = "caps:ctrl_modifier,ctrl:swapcaps";
          numlock = { };
        };

        touchpad = {
          tap = { };
          tap-button-map = "left-right-middle";
          click-method = "clickfinger";
          dwt = { };
          natural-scroll = { };
          scroll-factor = 0.5;
          accel-speed = 0.5; # -1.0 to 1.0
        };
      };

      layout = {
        gaps = 16;
        center-focused-column = "never";

        preset-column-widths._children = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width.proportion = 0.5;

        focus-ring = {
          width = 1;
          active-color = "#7fc8ff";
          inactive-color = "#505050";
        };

        border = {
          off = { };
          width = 4;
          active-color = "#ffc87f";
          inactive-color = "#505050";
          urgent-color = "#9b0000";
        };

        shadow = {
          softness = 30;
          spread = 5;
          offset._props = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = { };

        "Mod+T" = {
          _props.hotkey-overlay-title = "Open a Terminal: ghostty";
          spawn = [ "ghostty" ];
        };
        "Mod+D" = {
          _props.hotkey-overlay-title = "Run an Application: fuzzel";
          spawn = [ "fuzzel" ];
        };
        "Super+Alt+L" = {
          _props.hotkey-overlay-title = "Lock the Screen: swaylock";
          spawn = [ "swaylock" ];
        };
        "Super+Alt+S" = {
          _props = {
            allow-when-locked = true;
            hotkey-overlay-title = null;
          };
          spawn-sh = "pkill orca || exec orca";
        };

        "XF86AudioLowerVolume" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
        };
        "XF86AudioRaiseVolume" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
        };
        "XF86AudioMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        "XF86AudioPlay" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl play-pause";
        };
        "XF86AudioStop" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl stop";
        };
        "XF86AudioPrev" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl previous";
        };
        "XF86AudioNext" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl next";
        };

        "XF86MonBrightnessUp" = {
          _props.allow-when-locked = true;
          spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "+10%"
          ];
        };
        "XF86MonBrightnessDown" = {
          _props.allow-when-locked = true;
          spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "10%-"
          ];
        };

        "Mod+O" = {
          _props.repeat = false;
          toggle-overview = { };
        };
        "Mod+Q" = {
          _props.repeat = false;
          close-window = { };
        };

        "Mod+H".focus-column-left = { };
        "Mod+J".focus-window-or-workspace-down = { };
        "Mod+K".focus-window-or-workspace-up = { };
        "Mod+L".focus-column-right = { };

        "Mod+Ctrl+H".move-column-left = { };
        "Mod+Ctrl+J".move-window-down-or-to-workspace-down = { };
        "Mod+Ctrl+K".move-window-up-or-to-workspace-up = { };
        "Mod+Ctrl+L".move-column-right = { };

        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };
        "Mod+Ctrl+Home".move-column-to-first = { };
        "Mod+Ctrl+End".move-column-to-last = { };

        "Mod+Shift+H".focus-monitor-left = { };
        "Mod+Shift+J".focus-monitor-down = { };
        "Mod+Shift+K".focus-monitor-up = { };
        "Mod+Shift+L".focus-monitor-right = { };

        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

        "Mod+Shift+Page_Down".move-workspace-down = { };
        "Mod+Shift+Page_Up".move-workspace-up = { };
        "Mod+Shift+U".move-workspace-down = { };
        "Mod+Shift+I".move-workspace-up = { };

        "Mod+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          focus-workspace-down = { };
        };
        "Mod+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          focus-workspace-up = { };
        };
        "Mod+Ctrl+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          move-column-to-workspace-down = { };
        };
        "Mod+Ctrl+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          move-column-to-workspace-up = { };
        };

        "Mod+WheelScrollRight".focus-column-right = { };
        "Mod+WheelScrollLeft".focus-column-left = { };
        "Mod+Ctrl+WheelScrollRight".move-column-right = { };
        "Mod+Ctrl+WheelScrollLeft".move-column-left = { };

        "Mod+Shift+WheelScrollDown".focus-column-right = { };
        "Mod+Shift+WheelScrollUp".focus-column-left = { };
        "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = { };
        "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = { };

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+Ctrl+1".move-column-to-workspace = 1;
        "Mod+Ctrl+2".move-column-to-workspace = 2;
        "Mod+Ctrl+3".move-column-to-workspace = 3;
        "Mod+Ctrl+4".move-column-to-workspace = 4;
        "Mod+Ctrl+5".move-column-to-workspace = 5;
        "Mod+Ctrl+6".move-column-to-workspace = 6;
        "Mod+Ctrl+7".move-column-to-workspace = 7;
        "Mod+Ctrl+8".move-column-to-workspace = 8;
        "Mod+Ctrl+9".move-column-to-workspace = 9;

        "Mod+BracketLeft".consume-or-expel-window-left = { };
        "Mod+BracketRight".consume-or-expel-window-right = { };
        "Mod+Comma".consume-window-into-column = { };
        "Mod+Period".expel-window-from-column = { };

        "Mod+R".switch-preset-column-width = { };
        "Mod+Shift+R".switch-preset-window-height = { };
        "Mod+Ctrl+R".reset-window-height = { };
        "Mod+F".maximize-column = { };
        "Mod+Shift+F".fullscreen-window = { };
        "Mod+Ctrl+F".expand-column-to-available-width = { };

        "Mod+C".center-column = { };
        "Mod+Ctrl+C".center-visible-columns = { };

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+V".toggle-window-floating = { };
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };
        "Mod+W".toggle-column-tabbed-display = { };

        "Print".screenshot = { };
        "Ctrl+Print".screenshot-screen = { };
        "Alt+Print".screenshot-window = { };

        "Mod+Escape" = {
          _props.allow-inhibiting = false;
          toggle-keyboard-shortcuts-inhibit = { };
        };

        "Mod+Shift+E".quit = { };
        "Ctrl+Alt+Delete".quit = { };

        "Mod+Shift+P".power-off-monitors = { };
      };

      # Repeated/parameterized top-level nodes (output, window-rule, include,
      # spawn-at-startup can't be plain attrset keys since KDL allows the same
      # node name more than once).
      _children = [
        # Laptop screen
        {
          output = {
            _args = [ "eDP-2" ];
            position._props = {
              x = 0;
              y = 562;
            };
            scale = 1.5;
          };
        }
        # LG external monitor (home). Logical size for eDP-2 is 1706, but
        # setting x=1706 results in an overlap, so x=1707 (1706 + 1).
        {
          output = {
            _args = [ "DP-3" ];
            position._props = {
              x = 1707;
              y = 0;
            };
            scale = 1;
          };
        }

        # Work around WezTerm's initial configure bug by setting an empty
        # default-column-width.
        {
          window-rule = {
            match._props.app-id = "^org\\.wezfurlong\\.wezterm$";
            default-column-width = { };
          };
        }
        {
          window-rule = {
            match._props = {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            };
            open-floating = true;
          };
        }
        # No `match`, so this applies to every window.
        {
          window-rule = {
            geometry-corner-radius = 12;
            clip-to-geometry = true;
          };
        }
        {
          window-rule = {
            match._props.app-id = "^Spotify$";
            open-fullscreen = true;
          };
        }
        {
          window-rule = {
            match._props.app-id = "^(firefox|code-oss)$";
            open-maximized = true;
          };
        }

        { include._args = [ "dms/colors.kdl" ]; }
        { include._args = [ "dms/layout.kdl" ]; }
        { include._args = [ "dms/alttab.kdl" ]; }
        { include._args = [ "dms/binds.kdl" ]; }
        {
          spawn-at-startup = [
            "dms"
            "run"
          ];
        }
        { include._args = [ "dms/cursor.kdl" ]; }
      ];
    };
  };
}
