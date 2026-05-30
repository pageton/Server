# Consolidated helpers for Server ai-agents — models, MCP transforms, settings.
{ cfg, lib, constants }:

let
  # ── Models (same as System) ──────────────────────────────────────────────
  models = {
    claude-opus = "opencode/claude-opus-4-7";
    claude-sonnet = "opencode/claude-sonnet-4-7";
    claude-haiku = "opencode/claude-haiku-4-5";
    gpt-default = "openai/gpt-5.5";
    openrouter = "openrouter/tencent/hy3-preview:free";
    glm = "zai-coding-plan/glm-5.1";
    gemini = "google/gemini-3-pro-preview";
    zen = "opencode/minimax-m2.5-free";
    deepseek-pro = "deepseek/deepseek-v4-pro";
    deepseek-flash = "deepseek/deepseek-v4-flash";
    mimo-pro = "xiaomi-token-plan-sgp/mimo-v2.5-pro";
    mimo-default = "xiaomi-token-plan-sgp/mimo-v2.5-pro";
  };

  # ── Z.AI MCP services ────────────────────────────────────────────────────
  zaiBaseUrl = "${constants.services.zai.apiRoot}/mcp";
  zaiServices = [
    { name = "web_search_prime"; mcpKey = "web-search-prime"; }
    { name = "web_reader"; mcpKey = "web-reader"; }
    { name = "zread"; mcpKey = "zread"; }
  ];

  mkZaiRemoteMcp = path: {
    enable = true;
    type = "remote";
    url = "${zaiBaseUrl}/${path}/mcp";
    headers = {
      Authorization = "Bearer __ZAI_API_KEY_PLACEHOLDER__";
    };
  };

  zaiMcpServers = builtins.listToAttrs (map (svc: {
    name = svc.mcpKey;
    value = mkZaiRemoteMcp svc.name;
  }) zaiServices);

  # ── Shared MCP servers ───────────────────────────────────────────────────
  mcpServers = zaiMcpServers // {
    context7 = {
      enable = true;
      command = "bunx";
      args = [ "@upstash/context7-mcp@2.1.2" "--api-key" "__CONTEXT7_API_KEY_PLACEHOLDER__" ];
    };
    github = {
      enable = true;
      command = "github-mcp-server";
      args = [ "stdio" "--toolsets=default,actions,code_security,dependabot,secret_protection" ];
      env = { GITHUB_PERSONAL_ACCESS_TOKEN = "__GITHUB_TOKEN_PLACEHOLDER__"; };
    };
    semgrep = {
      enable = true;
      command = "semgrep";
      args = [ "mcp" ];
    };
    codegraph = {
      enable = true;
      command = "codegraph";
      args = [ "serve" "--mcp" ];
    };
    agentmemory = {
      enable = true;
      command = "bunx";
      args = [ "--silent" "@agentmemory/mcp@latest" ];
    };
  };

  # ── MCP transforms for OpenCode format ───────────────────────────────────
  opencodeMcpServers = lib.mapAttrs (_: server:
    let
      isLocal = (server.type or "local") == "local";
      base = if isLocal then {
        type = "local";
        command = [ server.command ] ++ (server.args or []);
      } else {
        type = "remote";
        inherit (server) url;
      } // lib.optionalAttrs (server.headers or null != null) { inherit (server) headers; };
      envAttrs = lib.optionalAttrs (server.env or {} != {}) { environment = server.env; };
    in base // envAttrs
  ) (lib.filterAttrs (_: s: s.enable) mcpServers);

  # ── OpenCode settings builder ────────────────────────────────────────────
  opencodeSettings = {
    "$schema" = "https://opencode.ai/config.json";
    model = cfg.opencode.model;
    mcp = opencodeMcpServers;
    plugin = cfg.opencode.plugins;
    provider = cfg.opencode.providers;
    snapshot = false;
    logLevel = "WARN";
    compaction = {
      auto = true;
      prune = true;
      reserved = 12000;
      tail_turns = 4;
      preserve_recent_tokens = 12000;
    };
    tool_output = {
      max_bytes = 50000;
      max_lines = 2000;
    };
    watcher.ignore = [
      "node_modules/**" "dist/**" ".git/**" ".venv/**"
      "target/**" "build/**" "coverage/**"
    ];
    experimental = {
      batch_tool = true;
      continue_loop_on_deny = true;
      mcp_timeout = 120000;
    };
    share = "disabled";
    autoupdate = true;
    small_model = models.zen;
  };

  # ── jq filters for secret patching ───────────────────────────────────────
  zaiPlaceholderFilter = ''
    walk(if type == "string" then gsub("__ZAI_API_KEY_PLACEHOLDER__"; $key) else . end)
  '';
  githubPlaceholderFilter = ''
    walk(if type == "string" then gsub("__GITHUB_TOKEN_PLACEHOLDER__"; $token) else . end)
  '';
  openrouterPlaceholderFilter = ''
    walk(if type == "string" then gsub("__OPENROUTER_API_KEY_PLACEHOLDER__"; $key) else . end)
  '';
  context7PlaceholderFilter = ''
    walk(if type == "string" then gsub("__CONTEXT7_API_KEY_PLACEHOLDER__"; $key) else . end)
  '';

in {
  inherit models mcpServers opencodeSettings
    zaiPlaceholderFilter githubPlaceholderFilter
    openrouterPlaceholderFilter context7PlaceholderFilter;
}
