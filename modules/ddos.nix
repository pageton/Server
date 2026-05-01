{ ... }:
{
  # Basic L3/L4 hardening for public services.
  boot.kernel.sysctl = {
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.core.somaxconn" = 4096;
    "net.netfilter.nf_conntrack_max" = 262144;
  };

  networking.firewall = {
    # Rate/connection guard for MTProxy listener.
    extraCommands = ''
      iptables -N MTPROXY_GUARD 2>/dev/null || true
      iptables -F MTPROXY_GUARD

      iptables -A MTPROXY_GUARD -m connlimit --connlimit-above 60 --connlimit-mask 32 -j DROP
      iptables -A MTPROXY_GUARD -m hashlimit \
        --hashlimit-name mtproxy_rate \
        --hashlimit-mode srcip \
        --hashlimit-upto 30/second \
        --hashlimit-burst 100 \
        -j RETURN
      iptables -A MTPROXY_GUARD -j DROP

      iptables -C nixos-fw -p tcp --dport 8443 -j MTPROXY_GUARD 2>/dev/null || \
        iptables -I nixos-fw 1 -p tcp --dport 8443 -j MTPROXY_GUARD
    '';

    extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 8443 -j MTPROXY_GUARD 2>/dev/null || true
      iptables -F MTPROXY_GUARD 2>/dev/null || true
      iptables -X MTPROXY_GUARD 2>/dev/null || true
    '';
  };
}
