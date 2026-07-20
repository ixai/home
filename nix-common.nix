# nix.conf settings shared by both layers of this flake:
#   - the home-manager `nix` module   → ~/.config/nix/nix.conf   (user)
#   - the system-manager `nix` module → /etc/nix/nix.conf         (system)
#
# Add a key here to keep both files in sync. Layer-only keys (e.g.
# trusted-users, substituters, build-users-group) belong in the file
# that owns them — common.nix (user) or system.nix (system) — which
# override or extend what's defined here via `//`.
{
  settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };
}
