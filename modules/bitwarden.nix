# Vaultwarden — self-hosted password manager (hardened).
{...}: {
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.sadiq.lol";

      # Single-user lockdown
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = false;
      SHOW_PASSWORD_HINT = false;
      PASSWORD_HINTS_ALLOWED = false;
      ORG_CREATION_USERS = "none";

      # Rate limiting
      LOGIN_RATELIMIT_SECONDS = 60;
      LOGIN_RATELIMIT_MAX_BURST = 10;
      ADMIN_RATELIMIT_SECONDS = 300;
      ADMIN_RATELIMIT_MAX_BURST = 3;

      # Logging
      EXTENDED_LOGGING = true;
      LOG_LEVEL = "info";

      # SSRF protection
      HTTP_REQUEST_BLOCK_NON_GLOBAL_IPS = true;

      # Binding
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      # Real client IP from reverse proxy
      IP_HEADER = "X-Real-IP";
    };
  };
}
