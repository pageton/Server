# Option definitions for Server aiAgents — OpenCode-only subset.
{ lib, ... }:
{
  options.programs.aiAgents = {
    enable = lib.mkEnableOption "AI coding agents configuration";

    globalInstructions = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Global instructions injected into all AI agents";
    };

    secrets = {
      zaiApiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "/run/secrets/zai_api_key";
        description = "Path to sops-decrypted Z.AI API key file";
      };
      openrouterApiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "/run/secrets/openrouter_api_key";
        description = "Path to sops-decrypted OpenRouter API key file";
      };
      context7ApiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "/run/secrets/context7-api-key";
        description = "Path to sops-decrypted Context7 API key file";
      };
      deepseekApiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "/run/secrets/deepseek_api_key";
        description = "Path to sops-decrypted DeepSeek API key file";
      };
      mimoApiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "/run/secrets/mimo_api_key";
        description = "Path to sops-decrypted MiMo API key file";
      };
    };

    skills = lib.mkOption {
      type = lib.types.listOf (
        lib.types.either lib.types.str (lib.types.submodule {
          options = {
            repo = lib.mkOption { type = lib.types.str; description = "GitHub repository"; };
            skill = lib.mkOption { type = lib.types.str; description = "Skill name"; };
          };
        })
      );
      default = [];
      description = "Skills to install from skills.sh";
    };

    opencode = {
      enable = lib.mkEnableOption "OpenCode configuration";
      model = lib.mkOption {
        type = lib.types.str;
        default = "opencode/claude-opus-4-7";
        description = "Default model for OpenCode";
      };
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "OpenCode plugins";
      };
      providers = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Provider configurations";
      };
    };

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption { type = lib.types.bool; default = true; };
          type = lib.mkOption { type = lib.types.enum ["local" "remote"]; default = "local"; };
          command = lib.mkOption { type = lib.types.str; default = ""; };
          args = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          url = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
          headers = lib.mkOption { type = lib.types.nullOr (lib.types.attrsOf lib.types.str); default = null; };
          env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
        };
      });
      default = {};
      description = "MCP server definitions";
    };
  };
}
