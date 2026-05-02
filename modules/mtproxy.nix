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

  # Shared curl flags: connection timeout, overall timeout, retries with delay.
  curlOpts = "--connect-timeout 10 --max-time 30 --retry 3 --retry-delay 2 --retry-all-errors";

  stateDir = "/var/lib/mtproxy";

  # Script to atomically download a file with fallback to the existing copy.
  # Usage: downloadWithFallback <url> <dest>
  # Downloads to <dest>.tmp first, then renames on success.
  # If download fails and <dest> already exists, keeps the old copy.
  downloadWithFallback = pkgs.writeShellScript "mtproxy-download" ''
    url="$1"
    dest="$2"

    if ${pkgs.curl}/bin/curl ${curlOpts} -fsSL "$url" -o "$dest.tmp"; then
      mv -f "$dest.tmp" "$dest"
    else
      rm -f "$dest.tmp"
      if [[ -f "$dest" ]]; then
        echo "WARNING: Failed to download $url, using cached copy." >&2
      else
        echo "ERROR: Failed to download $url and no cached copy exists." >&2
        exit 1
      fi
    fi
  '';

  startScript = pkgs.writeShellScript "mtproxy-start" ''
    set -euo pipefail

    tag_args=()
    if [[ -n "''${MTPROXY_TAG:-}" ]]; then
      tag_args=(-P "$MTPROXY_TAG")
    fi

    ${downloadWithFallback} https://core.telegram.org/getProxySecret ${stateDir}/proxy-secret
    ${downloadWithFallback} https://core.telegram.org/getProxyConfig ${stateDir}/proxy-multi.conf

    exec ${mtproxyPkg}/bin/mtproto-proxy \
      -p ${toString cfg.statsPort} \
      -H ${toString cfg.port} \
      -S "$MTPROXY_SECRET" \
      "''${tag_args[@]}" \
      --aes-pwd ${stateDir}/proxy-secret ${stateDir}/proxy-multi.conf \
      -M ${toString cfg.workers}
  '';

  # Periodic refresh of proxy-multi.conf to keep DC config current.
  configRefreshScript = pkgs.writeShellScript "mtproxy-refresh-config" ''
    ${downloadWithFallback} https://core.telegram.org/getProxyConfig ${stateDir}/proxy-multi.conf
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
      default = 12;
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

      # Restart on failure but with exponential backoff to avoid crash loops
      # when Telegram servers are unreachable.
      startLimitIntervalSec = 300;
      startLimitBurst = 5;

      serviceConfig = {
        Type = "simple";
        User = "mtproxy";
        Group = "mtproxy";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = startScript;
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "mtproxy";
        StateDirectoryMode = "0750";

        # Watchdog: declare health; systemd restarts if no ping within 60s.
        WatchdogSec = 60;

        LimitNOFILE = 1000000;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;

        # Restrict network to TCP only (MTProxy needs outbound HTTPS + inbound client port).
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      };
    };

    # Refresh proxy-multi.conf every 6 hours to keep DC config current.
    # This prevents the proxy from becoming unreliable when Telegram rotates DCs.
    systemd.timers.mtproxy-refresh = {
      description = "Refresh MTProxy DC configuration";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00/6:00:00";
        Persistent = true;
      };
    };

    systemd.services.mtproxy-refresh = {
      description = "Refresh MTProxy DC configuration";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "mtproxy";
        Group = "mtproxy";
        ExecStart = configRefreshScript;
        StateDirectory = "mtproxy";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
