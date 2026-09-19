HOST := $(shell uname -n)

# Generations to retain per profile. `nix-env --delete-generations +N` keeps
# the N most recent.
KEEP ?= 3

USER_PROFILES := $(HOME)/.local/state/nix/profiles
SYSTEM_PROFILES := /nix/var/nix/profiles

.PHONY: build build/home-manager build/nix-darwin build/system-manager
.PHONY: switch switch/home-manager switch/nix-darwin switch/system-manager
.PHONY: fmt update check generations
.PHONY: clean clean/generations clean/generations/dry-run clean/store clean/cache optimise

ifeq ($(shell uname -s),Darwin)
# home-manager activates as a nix-darwin module here, so one darwin-rebuild
# run covers both layers.
build: build/nix-darwin
switch: switch/nix-darwin
else
# system-manager only applies to the Linux host (system.nix pins
# nixpkgs.hostPlatform to x86_64-linux).
build: build/home-manager build/system-manager
switch: switch/home-manager switch/system-manager
endif

build/home-manager:
	home-manager build --flake ".#ixai@$(HOST)"

build/nix-darwin:
	darwin-rebuild build --flake ".#$(HOST)"

build/system-manager:
	nix run .#system-manager -- build --flake .

switch/home-manager:
	home-manager switch --flake ".#ixai@$(HOST)"

# Activation is the one darwin-rebuild action that requires root; `build` does
# not.
switch/nix-darwin:
	sudo darwin-rebuild switch --flake ".#$(HOST)"

switch/system-manager:
	nix run .#system-manager -- switch --flake . --sudo

fmt:
	nix fmt

update:
	nix flake update

check:
	nix flake check

generations:
	@for p in $(USER_PROFILES)/*; do \
	  case "$$p" in *-link) continue;; esac; \
	  [ -L "$$p" ] || continue; \
	  printf '\n==> %s\n' "$$p"; \
	  nix-env --list-generations --profile "$$p"; \
	done
	@for p in $(SYSTEM_PROFILES)/*; do \
	  case "$$p" in *-link) continue;; esac; \
	  [ -L "$$p" ] || continue; \
	  printf '\n==> %s\n' "$$p"; \
	  sudo nix-env --list-generations --profile "$$p"; \
	done

# Trimming runs before collection: a generation is a GC root, so the store
# keeps every closure still referenced by one.
clean:
	$(MAKE) clean/generations
	$(MAKE) clean/store

clean/generations/dry-run: DRY_RUN := --dry-run
clean/generations/dry-run: clean/generations

clean/generations:
	@for p in $(USER_PROFILES)/*; do \
	  case "$$p" in *-link) continue;; esac; \
	  [ -L "$$p" ] || continue; \
	  printf '\n==> %s\n' "$$p"; \
	  nix-env --delete-generations +$(KEEP) --profile "$$p" $(DRY_RUN); \
	done
	@for p in $(SYSTEM_PROFILES)/*; do \
	  case "$$p" in *-link) continue;; esac; \
	  [ -L "$$p" ] || continue; \
	  printf '\n==> %s\n' "$$p"; \
	  sudo nix-env --delete-generations +$(KEEP) --profile "$$p" $(DRY_RUN); \
	done

clean/store:
	nix store gc --verbose

# Eval and fetcher caches; both are rebuilt on demand.
clean/cache:
	rm -rf $(HOME)/.cache/nix

# Replaces duplicate store files with hardlinks. Slow, and safe to interrupt.
optimise:
	nix store optimise
