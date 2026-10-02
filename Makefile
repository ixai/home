HOST := $(shell uname -n)

# Generations to retain per profile. `nix-env --delete-generations +N` keeps
# the N most recent.
KEEP ?= 3

USER_PROFILES := $(HOME)/.local/state/nix/profiles
SYSTEM_PROFILES := /nix/var/nix/profiles

.PHONY: help build build/home-manager build/nix-darwin build/system-manager
.PHONY: switch switch/home-manager switch/nix-darwin switch/system-manager
.PHONY: fmt update update/all check check/inputs generations
.PHONY: clean clean/generations clean/generations/dry-run clean/store clean/cache optimise

# Flake inputs grouped by the host that consumes them. `update` only touches
# the inputs this host uses; `check/inputs` fails when flake.nix declares an
# input that is missing from every list.
COMMON_INPUTS := nixpkgs home-manager try llm-agents treefmt-nix
DARWIN_INPUTS := nix-darwin
LINUX_INPUTS := hermes-agent niri stasis dms dank-greeter system-manager nix-system-graphics

ifeq ($(shell uname -s),Darwin)
# home-manager activates as a nix-darwin module here, so one darwin-rebuild
# run covers both layers.
BUILD_LAYERS := build/nix-darwin
SWITCH_LAYERS := switch/nix-darwin
HOST_INPUTS := $(COMMON_INPUTS) $(DARWIN_INPUTS)
else
# system-manager only applies to the Linux host (system.nix pins
# nixpkgs.hostPlatform to x86_64-linux).
BUILD_LAYERS := build/home-manager build/system-manager
SWITCH_LAYERS := switch/home-manager switch/system-manager
HOST_INPUTS := $(COMMON_INPUTS) $(LINUX_INPUTS)
endif

help: ## Show this help
	@awk 'BEGIN { FS = ":.*## " } /^[a-zA-Z_\/-]+:.*## / { printf "%-28s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build: $(BUILD_LAYERS) ## Build every layer for this host

switch: $(SWITCH_LAYERS) ## Build and activate every layer for this host

build/home-manager: ## Build the home-manager generation
	home-manager build --flake ".#ixai@$(HOST)"

build/nix-darwin: ## Build the nix-darwin system
	darwin-rebuild build --flake ".#$(HOST)"

build/system-manager: ## Build the system-manager configuration
	nix run .#system-manager -- build --flake .

switch/home-manager: ## Activate the home-manager generation
	home-manager switch --flake ".#ixai@$(HOST)"

# Activation is the one darwin-rebuild action that requires root; `build` does
# not.
switch/nix-darwin: ## Activate the nix-darwin system (sudo)
	sudo darwin-rebuild switch --flake ".#$(HOST)"

switch/system-manager: ## Activate the system-manager configuration (sudo)
	nix run .#system-manager -- switch --flake . --sudo

fmt: ## Format the nix files
	nix fmt

update: ## Update the flake inputs this host uses
	nix flake update $(HOST_INPUTS)

update/all: ## Update every flake input
	nix flake update

check: check/inputs ## Run the flake checks
	nix flake check

check/inputs: ## Fail when a flake input is in no Makefile input list
	@status=0; \
	declared=$$(nix flake metadata --json | jq --raw-output '.locks.nodes.root.inputs | keys[]' | tr '\n' ' '); \
	listed='$(COMMON_INPUTS) $(DARWIN_INPUTS) $(LINUX_INPUTS)'; \
	for i in $$declared; do \
	  case " $$listed " in *" $$i "*) ;; *) echo "flake input not in any Makefile list: $$i"; status=1;; esac; \
	done; \
	for i in $$listed; do \
	  case " $$declared " in *" $$i "*) ;; *) echo "Makefile lists an input not in flake.nix: $$i"; status=1;; esac; \
	done; \
	exit $$status

generations: ## List user and system profile generations
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
clean: ## Trim generations, then run store GC
	$(MAKE) clean/generations
	$(MAKE) clean/store

clean/generations/dry-run: DRY_RUN := --dry-run
clean/generations/dry-run: clean/generations ## Preview generation trimming

clean/generations: ## Keep the KEEP newest generations per profile (default 3)
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

clean/store: ## Garbage-collect the nix store
	nix store gc --verbose

# Eval and fetcher caches; both are rebuilt on demand.
clean/cache: ## Delete the nix eval and fetcher caches
	rm -rf $(HOME)/.cache/nix

# Replaces duplicate store files with hardlinks. Slow, and safe to interrupt.
optimise: ## Hardlink duplicate store files (slow)
	nix store optimise
