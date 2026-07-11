{ lib, pkgs, ... }:
{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    system-manager.allowAnyDistro = true;

    # Manage /etc/nix/nix.conf (system-level). system-manager imports only
    # nixpkgs' `config/nix.nix` (settings → environment.etc."nix/nix.conf"),
    # gated behind `nix.enable`. It does NOT import the nix-daemon NixOS
    # module, so enabling this only writes the config file — it won't start a
    # competing daemon or replace the Nix install.
    # The module generates the *whole* file from `nix.settings`, so we must
    # preserve the keys the Nix installer put there (build-users-group,
    # max-jobs, trusted-users) or multi-user builds break on the next switch.
    nix.enable = true;
    nix.settings = (import ./nix-common.nix).settings // {
      build-users-group = "nixbld";
      max-jobs = "auto";
      # mkForce overrides the nixpkgs default `trusted-users = [ "root" ]`
      # instead of list-merging with it (which would yield "root ixai root").
      trusted-users = lib.mkForce [
        "root"
        "ixai"
      ];
    };

    system-graphics = {
      enable = true;
      extraPackages = with pkgs.rocmPackages; [
        clr.icd
        # hipblas
        rocm-runtime
        rocm-smi
        rocminfo
      ];
    };

    # Enable and configure services
    services = {
      # nginx.enable = true;
    };

    environment = {
      # Packages that should be installed on a system
      systemPackages = with pkgs; [
        btop # Beautiful system monitor
        bat # Modern 'cat' with syntax highlight
        clinfo
      ];

      # Add directories and files to `/etc` and set their permissions
      etc = {
        # with_ownership = {
        #   text = ''
        #     This is just a test!
        #   '';
        #   mode = "0755";
        #   uid = 5;
        #   gid = 6;
        # };
        #
        # with_ownership2 = {
        #   text = ''
        #     This is just a test!
        #   '';
        #   mode = "0755";
        #   user = "nobody";
        #   group = "users";
        # };
      };
    };

    # Enable and configure systemd services
    systemd.services = { };

    # Configure systemd tmpfile settings
    systemd.tmpfiles = {
      # rules = [
      #   "D /var/tmp/system-manager 0755 root root -"
      # ];
      #
      # settings.sample = {
      #   "/var/tmp/sample".d = {
      #     mode = "0755";
      #   };
      # };
    };
  };
}
