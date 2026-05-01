host := "USER@SERVER_IP"

# Build and switch to new config on remote server
deploy:
    nixos-rebuild switch --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password

# Build config without switching (dry-run)
build:
    nixos-rebuild build --flake .#server

# Test config (revert after reboot)
test:
    nixos-rebuild test --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password

# Check flake evaluation and formatting
check:
    nix flake check

# Update flake inputs
update:
    nix flake update

# SSH into the server
ssh:
    ssh {{host}}

# Show diff between current and next generation on remote
diff:
    nixos-rebuild switch --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password --dry-run
