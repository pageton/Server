# Cloudflare Tunnel — outbound-only, no inbound ports needed.
#
# Requires /etc/cloudflared/secrets.env containing:
#   CF_TUNNEL_ID=<tunnel-id>
#   CF_ACCOUNT_TAG=<account-tag>
#   CF_TUNNEL_SECRET=<tunnel-secret>
#
{ pkgs, ... }:
let
  credFile = "/etc/cloudflared/creds.json";
  secretsEnv = "/etc/cloudflared/secrets.env";

  configFile = pkgs.writeText "cloudflared-config.yml" ''
    tunnel: ''${CF_TUNNEL_ID}
    credentials-file: ${credFile}

    ingress:
      - hostname: vault.sadiq.lol
        service: http://localhost:8222
      - service: http_status:404
  '';

  credSetupScript = pkgs.writeShellScript "cloudflared-cred-setup" ''
    set -euo pipefail
    source ${secretsEnv}
    cat > ${credFile} <<CREDJSON
    {
      "AccountTag": "$CF_ACCOUNT_TAG",
      "TunnelSecret": "$CF_TUNNEL_SECRET",
      "TunnelID": "$CF_TUNNEL_ID",
      "Endpoint": ""
    }
    CREDJSON
    chown cloudflared:cloudflared ${credFile}
    chmod 0400 ${credFile}
  '';
in
{
  environment.systemPackages = [ pkgs.cloudflared ];

  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
  };
  users.groups.cloudflared = { };

  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = "${credSetupScript}";

    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate --config ${configFile} run";
      EnvironmentFile = secretsEnv;
      Restart = "on-failure";
      RestartSec = 5;
      User = "cloudflared";
      Group = "cloudflared";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
    };
  };
}
