HOST := $(shell uname -n)

.PHONY: build build/home-manager build/system-manager
.PHONY: switch switch/home-manager switch/system-manager
.PHONY: fmt update

build: build/home-manager
switch: switch/home-manager

# system-manager only applies to the Linux host (system.nix pins
# nixpkgs.hostPlatform to x86_64-linux); skip it on Darwin.
ifeq ($(shell uname -s),Linux)
build: build/system-manager
switch: switch/system-manager
endif

build/home-manager:
	home-manager build --flake ".#ixai@$(HOST)"

build/system-manager:
	nix run .#system-manager -- build --flake .

switch/home-manager:
	home-manager switch --flake ".#ixai@$(HOST)"

switch/system-manager:
	nix run .#system-manager -- switch --flake . --sudo

fmt:
	nix fmt

update:
	nix flake update
