# Nginx reverse proxy.
{...}: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "default" = {
        default = true;
        locations."/" = {return = 404;};
      };
      "vault.sadiq.lol" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
