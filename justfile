host := "sadiq@server"

# Build and switch NixOS config on remote server
deploy:
    nixos-rebuild switch --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password

# Build NixOS config without switching
build:
    nixos-rebuild build --flake .#server

# Test NixOS config (revert after reboot)
test:
    nixos-rebuild test --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password

# Check flake evaluation
check:
    nix flake check

# Update flake inputs
update:
    nix flake update

# SSH into the server
ssh:
    ssh {{host}}

# Show diff on remote
diff:
    nixos-rebuild switch --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password --dry-run

# Switch Home-Manager config (run on server)
home:
    home-manager switch --flake .#sadiq

# View decrypted SOPS secrets
sops-view:
    sops -d secrets/secrets.yaml

# Edit SOPS secrets
sops-edit:
    sops secrets/secrets.yaml

# Deploy both NixOS + Home-Manager to remote
full-deploy:
    nixos-rebuild switch --flake .#server --build-host {{host}} --target-host {{host}} --sudo --ask-sudo-password
    ssh {{host}} "home-manager switch -b backup --flake ~/Server#sadiq"

# Sync skills from local machine to server (fast local network)
sync-skills:
    rsync -avz --delete ~/.agents/skills/ {{host}}:~/.agents/skills/
    rsync -avz --delete ~/.claude/skills/ {{host}}:~/.claude/skills/
    rsync -avz --delete ~/.config/opencode/skills/ {{host}}:~/.config/opencode/skills/
    ssh {{host}} "mkdir -p ~/.cache/ai-agents ~/.agents"
    rsync -avz ~/.cache/ai-agents/skills-state.sha256 {{host}}:~/.cache/ai-agents/skills-state.sha256
    ssh {{host}} "touch ~/.agents/.skill-lock.json"
    @echo "✓ Skills synced to server"

# Run all checks
qa: check
