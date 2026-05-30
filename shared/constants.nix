# Minimal constants for Server — user identity, paths, service endpoints.
let
  localhost = "127.0.0.1";
  ports = {};
in
{
  user = {
    handle = "Sadiq";
    name = "Sadiq";
    email = "pageton@proton.me";
    githubEmail = "pageton@proton.me";
    signingKey = "5684AD6E4045F283";
  };

  inherit localhost ports;

  urls = builtins.mapAttrs (_name: port: "http://${localhost}:${toString port}") ports;

  paths = {
    scripts = "System/scripts";
    opencodeLogDir = ".local/share/opencode/log";
    codexLogDir = ".codex/log";
    aiAgentsLogDir = ".local/share/ai-agents/logs";
  };

  services = {
    zai = {
      apiRoot = "https://api.z.ai/api";
      timeout = 3000000;
      models = {
        haiku = "glm-5-turbo";
        sonnet = "glm-5.1";
        opus = "glm-5.1";
      };
    };
    deepseek = {
      apiRoot = "https://api.deepseek.com";
      anthropicRoot = "https://api.deepseek.com/anthropic";
      models = {
        pro = "deepseek-v4-pro";
        flash = "deepseek-v4-flash";
      };
    };
  };
}
