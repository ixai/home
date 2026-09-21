{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  dmsGreeter = inputs.dank-greeter.packages.${system}.default;
  compositor = inputs.niri.packages.${system}.default;

  dmsGreeterSession = pkgs.writeShellScript "dms-greeter-session" ''
    set -eu
    export PATH="${
      lib.makeBinPath [
        pkgs.quickshell
        compositor
        pkgs.glib
        pkgs.systemd
      ]
    }:$PATH"

    exec ${dmsGreeter}/bin/dms-greeter \
      --cache-dir /var/lib/dms-greeter \
      --command niri \
      --remember-last-user true
  '';

  syncDmsGreeter = pkgs.writeShellScript "sync-dms-greeter" ''
    set -eu
    export PATH="${lib.makeBinPath [ pkgs.coreutils ]}:$PATH"

    cache_dir=/var/lib/dms-greeter
    install -d -o greeter -g greeter -m 0750 "$cache_dir"

    copy_file() {
      source=$1
      destination=$2
      if [ -r "$source" ]; then
        install -o greeter -g greeter -m 0644 "$source" "$cache_dir/$destination"
      fi
    }

    copy_file /home/ixai/.config/DankMaterialShell/settings.json settings.json
    copy_file /home/ixai/.local/state/DankMaterialShell/session.json session.json
    copy_file /home/ixai/.cache/DankMaterialShell/dms-colors.json colors.json

    chown -R greeter:greeter "$cache_dir"
  '';
in
{
  environment.systemPackages = with pkgs; [
    dmsGreeter
    compositor
    quickshell
    fira-code
    inter
    material-symbols
  ];

  environment.etc."greetd/config.toml" = {
    mode = "0644";
    replaceExisting = true;
    text = ''
      [terminal]
      vt = 1

      [default_session]
      command = "${dmsGreeterSession}"
      user = "greeter"
    '';
  };

  systemd.tmpfiles.settings."10-dms-greeter"."/var/lib/dms-greeter" = {
    d = {
      user = "greeter";
      group = "greeter";
      mode = "0750";
    };
    Z = {
      user = "greeter";
      group = "greeter";
    };
  };

  systemd.services.dms-greeter-sync = {
    description = "Sync DMS configuration for dms-greeter";
    wantedBy = [ "greetd.service" ];
    before = [ "greetd.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = syncDmsGreeter;
    };
  };
}
