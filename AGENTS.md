# AGENTS.md — Server (NixOS Headless)

## Environment

- **OS:** NixOS 26.05 (headless, QEMU guest)
- **Shell:** zsh (Oh My Zsh)
- **Package manager:** Nix (system) + bun (user)
- **Secrets:** SOPS + age → `/run/secrets/`
- **Network:** Tailscale mesh, Cloudflare tunnel

## Available Tools

| Tool | Purpose |
|------|---------|
| `opencode` | AI coding agent (primary) |
| `gh` | GitHub CLI |
| `git` | Version control (SSH for GitHub) |
| `just` | Task runner |
| `nix` | Package management |
| `bun` | JS runtime + package manager |
| `semgrep` | Static analysis |
| `codegraph` | Code knowledge graph |

## MCP Servers

| Server | Type | Status |
|--------|------|--------|
| codegraph | local | connected |
| context7 | local | connected |
| github | local | connected |
| semgrep | local | connected |
| agentmemory | local | connected |
| web-reader | remote (Z.AI) | connected |
| web-search-prime | remote (Z.AI) | connected |
| zread | remote (Z.AI) | connected |

## LSP Servers

bash-language-server, gopls, nixd, pyright, typescript-language-server, vscode-json-languageserver, yaml-language-server, clangd, rust-analyzer

## Conventions

- **Nix formatting:** `nixfmt --strict`
- **Commits:** GPG-signed, semantic prefixes (`feat:`, `fix:`, `chore:`)
- **Secrets:** Never in plaintext; via SOPS → `/run/secrets/`
- **Skills:** Synced from local machine via `just sync-skills`

## Build & Deploy

```bash
just deploy          # NixOS rebuild on remote
just home            # Home-Manager switch
just full-deploy     # Both
just sync-skills     # Sync skills from local
just sops-view       # View decrypted secrets
```

## Gotchas

1. **Skills:** Installed locally, synced to server via `just sync-skills` (server network too slow for git clones)
2. **OpenCode:** Installed via `bun add -g opencode-ai` (glibc-linked binary)
3. **Z.AI MCP:** API key patched directly into config at activation (not env var)
4. **nixpkgs-stable:** 25.11 (26.05 tarball download issues)
