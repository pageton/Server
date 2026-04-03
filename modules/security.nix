# Server security hardening.
{user, ...}: {
  boot.kernel.sysctl = {
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "kernel.core_pattern" = "|/bin/false";
  };

  security = {
    protectKernelImage = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [
        {
          users = [user];
          commands = [
            {
              command = "/run/current-system/sw/bin/nixos-rebuild";
              options = ["NOPASSWD"];
            }
            {
              command = "/nix/store/*/bin/nixos-rebuild";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };

  networking.firewall = {
    enable = true;
    logRefusedConnections = true;
    allowPing = false;
  };
}
