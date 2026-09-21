{
  inputs,
  pkgs,
  system,
  ...
}:
{
  services.stasis = {
    enable = true;

    extraConfig = ''
      default:
        monitor_media true
        ignore_remote_media true

        inhibit_apps [
          "vlc"
          "mpv"
          r"steam_app_.*"
        ]

        ac:
          brightness:
            timeout 300
            command "brightnessctl set 50%"
          end

          dpms:
            timeout 120
            command "niri msg action power-off-monitors"
            resume_command "niri msg action power-on-monitors"
          end

          lock_screen:
            timeout 180
            command "dms ipc call lock lock"
          end

          suspend:
            timeout 600
            command "systemctl suspend"
          end
        end

        battery:
          brightness:
            timeout 60
            command "brightnessctl set 30%"
          end

          dpms:
            timeout 30
            command "niri msg action power-off-monitors"
            resume_command "niri msg action power-on-monitors"
          end

          lock_screen:
            timeout 60
            command "dms ipc call lock lock"
          end

          suspend:
            timeout 120
            command "systemctl suspend"
          end
        end
      end
    '';

    extraPathPackages = [
      inputs.niri.packages.${system}.default
      inputs.dms.packages.${system}.default
      pkgs.brightnessctl
    ];
  };
}
