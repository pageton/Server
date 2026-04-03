# Tailscale VPN.
{
  user,
  pkgsStable,
  ...
}: {
  services.tailscale = {
    enable = true;
    package = pkgsStable.tailscale;
    openFirewall = true;
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    checkReversePath = "loose";
  };

  security.sudo.extraRules = [
    {
      users = [user];
      commands = [
        {
          command = "/run/current-system/sw/bin/tailscale";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
