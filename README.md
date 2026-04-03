# Server

Declarative NixOS server configuration managed with flakes.

## Services

| Service | Module | Description |
|---------|--------|-------------|
| MTProxy | `modules/mtproxy.nix` | Telegram proxy (AYMENJD) with DDoS protection |
| Vaultwarden | `modules/bitwarden.nix` | Self-hosted password manager |
| Nginx | `modules/nginx.nix` | Reverse proxy (Vaultwarden) |
| Cloudflare Tunnel | `modules/cloudflared.nix` | Outbound-only tunnel |
| Tailscale | `modules/tailscale.nix` | Mesh VPN |

## Security

- Kernel and network hardening (`modules/security.nix`)
- iptables rate limiting (`modules/ddos.nix`)
- SSH: key-only auth, no root login
- Systemd sandboxing per service
- No secrets in the Nix store — loaded from env files at runtime

## Deploy

```sh
just deploy
```

Requires the target host set in `justfile` and SSH access configured.

## Secrets

Create these files on the server:

```sh
# /etc/mtproxy/mtproxy.env
MTPROXY_SECRET=<your_secret>
MTPROXY_TAG=<optional_tag>

# /etc/cloudflared/secrets.env
CF_TUNNEL_ID=<tunnel-id>
CF_ACCOUNT_TAG=<account-tag>
CF_TUNNEL_SECRET=<tunnel-secret>
```

## Structure

```
├── flake.nix                # Flake inputs/outputs
├── configuration.nix        # Main config
├── hardware-configuration.nix
├── disk-config.nix          # Disko disk layout
├── justfile                 # Build/deploy commands
└── modules/
    ├── nix.nix              # Nix settings
    ├── security.nix         # Kernel & network hardening
    ├── ddos.nix             # iptables rate limiting
    ├── mtproxy.nix          # MTProxy service
    ├── bitwarden.nix        # Vaultwarden
    ├── nginx.nix            # Reverse proxy
    ├── cloudflared.nix      # Cloudflare Tunnel
    └── tailscale.nix        # Tailscale VPN
```
