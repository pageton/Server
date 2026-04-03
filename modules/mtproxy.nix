{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mtproxyAymen;

  mtproxyPkg = pkgs.stdenv.mkDerivation {
    pname = "mtproxy-aymen";
    version = "2025-05-15";

    src = pkgs.fetchFromGitHub {
      owner = "aymenjd";
      repo = "mtproxy";
      rev = "57bf3375829967b1a92e76c93d6352b1a930dae9";
      hash = "sha256-kgTjFs5+5nDSXKR23JigbYDmhSDgroMWVKeZMCc6SKU=";
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [
      pkgs.openssl
      pkgs.zlib
    ];

    makeFlags = [ "CC=${pkgs.stdenv.cc.targetPrefix}cc" ];

    installPhase = ''
      runHook preInstall
      install -Dm0755 objs/bin/mtproto-proxy $out/bin/mtproto-proxy
      runHook postInstall
    '';
  };

  startScript = pkgs.writeShellScript "mtproxy-start" ''
    set -euo pipefail

    install -d -m 0750 -o mtproxy -g mtproxy /var/lib/mtproxy
    curl -fsSL https://core.telegram.org/getProxySecret -o /var/lib/mtproxy/proxy-secret
    curl -fsSL https://core.telegram.org/getProxyConfig -o /var/lib/mtproxy/proxy-multi.conf

    tag_args=()
    if [[ -n "''${MTPROXY_TAG:-}" ]]; then
      tag_args=(-P "$MTPROXY_TAG")
    fi

    exec ${mtproxyPkg}/bin/mtproto-proxy \
      -u mtproxy \
      -p ${toString cfg.statsPort} \
      -H ${toString cfg.port} \
      -S "$MTPROXY_SECRET" \
      "''${tag_args[@]}" \
      --aes-pwd /var/lib/mtproxy/proxy-secret /var/lib/mtproxy/proxy-multi.conf \
      -M ${toString cfg.workers}
  '';
in
{
  options.services.mtproxyAymen = {
    enable = lib.mkEnableOption "AYMENJD MTProxy service";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Domain clients should use in tg:// proxy link.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "External MTProxy port.";
    };

    statsPort = lib.mkOption {
      type = lib.types.port;
      default = 8888;
      description = "Local MTProxy stats port.";
    };

    workers = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "MTProxy worker count.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/mtproxy/mtproxy.env";
      description = "Environment file with MTPROXY_SECRET and optional MTPROXY_TAG.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ mtproxyPkg ];

    users.users.mtproxy = {
      isSystemUser = true;
      group = "mtproxy";
    };
    users.groups.mtproxy = { };

    systemd.services.mtproxy = {
      description = "MTProxy (AYMENJD)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "mtproxy";
        Group = "mtproxy";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = startScript;
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/mtproxy" ];
        PrivateTmp = true;
        PrivateDevices = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
