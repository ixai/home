# TODO

- Write the macOS system config: `system.defaults`, homebrew, TouchID for sudo. nix-darwin currently manages only Nix and home-manager.
- Drop the orphaned home-manager profile once the nix-darwin migration is proven: `nix profile wipe-history --profile ~/.local/state/nix/profiles/home-manager`. Generation 13 is the pre-migration fallback.
- Decide whether to add `pkgs.home-manager` to `home.packages`. The CLI is absent under nix-darwin, so `home-manager news` is unavailable; it could report but not activate.
- Add a topgrade custom command that runs `nix flake update` then `darwin-rebuild switch --flake .#D6R6PWWX1F`. Topgrade skips its `nix` and `home_manager` steps on nix-darwin hosts and has no darwin-rebuild step, so nothing updates the flake; `nixpkgs` and `nix-darwin` must move together.
