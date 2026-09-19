{ inputs, homeArgs, ... }:
{
  # home-manager activates as part of `darwin-rebuild switch` on this host.
  # The Linux host still activates it standalone via `homeConfigurations`;
  # both evaluate the same modules with the same arguments.
  home-manager = {
    extraSpecialArgs = homeArgs;

    # Activation refuses to replace a path home-manager does not already own,
    # which includes output its own earlier generations wrote in a different
    # shape. Move those aside instead of failing the switch.
    backupFileExtension = "nix-darwin-home-manager-backup";
    users.ixai.imports = [
      ./common.nix
      ./darwin.nix
    ];
  };

  users.users.ixai.home = "/Users/ixai";

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Manage /etc/nix/nix.conf (system-level). nix-darwin generates the *whole*
  # file from `nix.settings` and moves the installer's nix.custom.conf aside,
  # so every key the Nix installer wrote must be restated here or it is lost
  # on the next switch. Keys nix-darwin already defaults correctly
  # (build-users-group, max-jobs, trusted-users) are left to the module.
  nix.settings = (import ./nix-common.nix).settings // {
    always-allow-substitutes = true;
    bash-prompt-prefix = "(nix:$name)\\040";
    # `extra-` appends to Nix's built-in nix-path instead of replacing it,
    # which is what the installer wrote.
    extra-nix-path = "nixpkgs=flake:nixpkgs";
  };

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Read `darwin-rebuild changelog` before changing.
  system.stateVersion = 6;
}
