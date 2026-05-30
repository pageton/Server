# AI agents config for Server — OpenCode only, full skills from System.
{ config, constants, lib, pkgs, ... }:

let
  cfg = config.programs.aiAgents;
  helpers = import ./helpers.nix { inherit cfg lib constants; };
  inherit (helpers) models opencodeSettings;

  opencodeConfigJson = builtins.toJSON opencodeSettings;

  # Full skills list — ported from System _skills.nix
  skills = [
    # ── Real tools ────────────────────────────────────────────────────────
    { repo = "vercel-labs/agent-browser"; skill = "agent-browser"; }
    { repo = "callstackincubator/agent-device"; skill = "agent-device"; }
    { repo = "microsoft/playwright-cli"; skill = "playwright-cli"; }
    { repo = "ChromeDevTools/chrome-devtools-mcp"; skill = "chrome-devtools-cli"; }

    # ── Anthropic official ────────────────────────────────────────────────
    { repo = "anthropics/skills"; skill = "webapp-testing"; }
    { repo = "anthropics/skills"; skill = "frontend-design"; }
    { repo = "anthropics/skills"; skill = "mcp-builder"; }
    { repo = "anthropics/skills"; skill = "skill-creator"; }
    { repo = "anthropics/skills"; skill = "web-artifacts-builder"; }

    # ── Matt Pocock methodology ───────────────────────────────────────────
    "mattpocock/skills"

    # ── Vercel skills ─────────────────────────────────────────────────────
    "vercel-labs/agent-skills"
    { repo = "vercel-labs/skills"; skill = "find-skills"; }

    # ── Supercent UI/UX design skills ─────────────────────────────────────
    { repo = "supercent-io/skills-template"; skill = "adapt"; }
    { repo = "supercent-io/skills-template"; skill = "animate"; }
    { repo = "supercent-io/skills-template"; skill = "arrange"; }
    { repo = "supercent-io/skills-template"; skill = "audit"; }
    { repo = "supercent-io/skills-template"; skill = "bolder"; }
    { repo = "supercent-io/skills-template"; skill = "clarify"; }
    { repo = "supercent-io/skills-template"; skill = "colorize"; }
    { repo = "supercent-io/skills-template"; skill = "critique"; }
    { repo = "supercent-io/skills-template"; skill = "delight"; }
    { repo = "supercent-io/skills-template"; skill = "distill"; }
    { repo = "supercent-io/skills-template"; skill = "extract"; }
    { repo = "supercent-io/skills-template"; skill = "harden"; }
    { repo = "supercent-io/skills-template"; skill = "normalize"; }
    { repo = "supercent-io/skills-template"; skill = "onboard"; }
    { repo = "supercent-io/skills-template"; skill = "optimize"; }
    { repo = "supercent-io/skills-template"; skill = "overdrive"; }
    { repo = "supercent-io/skills-template"; skill = "polish"; }
    { repo = "supercent-io/skills-template"; skill = "quieter"; }
    { repo = "supercent-io/skills-template"; skill = "responsive-design"; }
    { repo = "supercent-io/skills-template"; skill = "typeset"; }

    # ── Samber Golang skills ──────────────────────────────────────────────
    "samber/cc-skills-golang"

    # ── TON blockchain ────────────────────────────────────────────────────
    { repo = "ton-org/skills"; skill = "ton-balance"; }
    { repo = "ton-org/skills"; skill = "ton-cli"; }
    { repo = "ton-org/skills"; skill = "ton-create-wallet"; }
    { repo = "ton-org/skills"; skill = "ton-docs"; }
    { repo = "ton-org/skills"; skill = "ton-manage-wallets"; }
    { repo = "ton-org/skills"; skill = "ton-nfts"; }
    { repo = "ton-org/skills"; skill = "ton-send"; }
    { repo = "ton-org/skills"; skill = "ton-swap"; }
    { repo = "ton-org/skills"; skill = "ton-xstocks"; }

    # ── Obra superpowers ──────────────────────────────────────────────────
    "obra/superpowers"

    # ── Impeccable design system ──────────────────────────────────────────
    "pbakaus/impeccable"

    # ── Everything Claude Code ────────────────────────────────────────────
    { repo = "affaan-m/everything-claude-code"; skill = "everything-claude-code"; }
    { repo = "affaan-m/everything-claude-code"; skill = "bun-runtime"; }
    { repo = "affaan-m/everything-claude-code"; skill = "security-review"; }

    # ── Coding methodology — multi-agent ──────────────────────────────────
    { repo = "michaelboeding/skills"; skill = "debug-council"; }
    { repo = "michaelboeding/skills"; skill = "parallel-builder"; }

    # ── Architecture & code structure ─────────────────────────────────────
    { repo = "michaelshimeles/skills"; skill = "code-structure"; }

    # ── Practical dev tools ───────────────────────────────────────────────
    { repo = "mxyhi/ok-skills"; skill = "gh-fix-ci"; }
    { repo = "mxyhi/ok-skills"; skill = "find-docs"; }

    # ── Security ──────────────────────────────────────────────────────────
    { repo = "TerminalSkills/skills"; skill = "security-audit"; }

    # ── Reverse engineering ───────────────────────────────────────────────
    { repo = "wshobson/agents"; skill = "protocol-reverse-engineering"; }

    # ── Documentation discipline ──────────────────────────────────────────
    { repo = "github/awesome-copilot"; skill = "documentation-writer"; }
    { repo = "github/awesome-copilot"; skill = "create-readme"; }
    { repo = "softaworks/agent-toolkit"; skill = "crafting-effective-readmes"; }
    "addyosmani/agent-skills"
    { repo = "narlyseorg/superhackers"; skill = "assessment-orchestrator"; }
    { repo = "narlyseorg/superhackers"; skill = "security-assessment"; }

    # ── Reverse engineering & security research ───────────────────────────
    { repo = "P4nda0s/reverse-skills"; skill = "rev-frida"; }

    # ── Web scraping ──────────────────────────────────────────────────────
    { repo = "apify/agent-skills"; skill = "apify-ultimate-scraper"; }

    # ── Cloud & infra ─────────────────────────────────────────────────────
    { repo = "cloudflare/skills"; skill = "cloudflare"; }
    { repo = "Jeffallan/claude-skills"; skill = "postgres-pro"; }
    { repo = "squirrelscan/skills"; skill = "audit-website"; }

    # ── Framework-specific ────────────────────────────────────────────────
    { repo = "yusukebe/hono-skill"; skill = "hono"; }
    { repo = "shadcn-ui/ui"; skill = "shadcn"; }
    { repo = "google-labs-code/stitch-skills"; skill = "design-md"; }
    { repo = "nextlevelbuilder/ui-ux-pro-max-skill"; skill = "ui-ux-pro-max"; }

    # ── Telegram ──────────────────────────────────────────────────────────
    { repo = "PBnicad/telegram-bot-grammy-skill"; skill = "telegram-bot-grammy"; }
    { repo = "sickn33/antigravity-awesome-skills"; skill = "telegram-mini-app"; }

    # ── Various utilities ─────────────────────────────────────────────────
    { repo = "Yeachan-Heo/oh-my-claudecode"; skill = "autoresearch"; }
    { repo = "Yeachan-Heo/oh-my-claudecode"; skill = "ultrawork"; }
    { repo = "Yeachan-Heo/oh-my-claudecode"; skill = "deepinit"; }
    { repo = "xixu-me/skills"; skill = "develop-userscripts"; }
    { repo = "xixu-me/skills"; skill = "github-actions-docs"; }
    { repo = "xixu-me/skills"; skill = "openclaw-secure-linux-cloud"; }
    { repo = "xixu-me/skills"; skill = "opensource-guide-coach"; }
    { repo = "xixu-me/skills"; skill = "readme-i18n"; }
    { repo = "xixu-me/skills"; skill = "running-claude-code-via-litellm-copilot"; }
    { repo = "xixu-me/skills"; skill = "secure-linux-web-hosting"; }
    { repo = "xixu-me/skills"; skill = "skills-cli"; }
    { repo = "xixu-me/skills"; skill = "use-my-browser"; }

    # ── Telegram — mtgo library + CLI ─────────────────────────────────────
    { repo = "mtgo-labs/mtgo"; skill = "mtgo"; }
    { repo = "mtgo-labs/mtgo-cli"; skill = "mtgo-cli"; }

    # ── Telegram development (gotg-cli) ───────────────────────────────────
    { repo = "pageton/gotg-cli"; skill = "tg-dev-agent"; }
  ];
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkMerge [
    # ── Defaults (always applied, no mkIf guard) ─────────────────────────
    {
      programs.aiAgents = {
        enable = lib.mkDefault true;
        inherit skills;
        opencode = {
          enable = lib.mkDefault true;
          model = lib.mkDefault models.claude-opus;
          plugins = lib.mkDefault [ "opencode-gemini-auth@latest" ];
          providers = lib.mkDefault {
            openrouter.options.apiKey = "__OPENROUTER_API_KEY_PLACEHOLDER__";
            deepseek.options.apiKey = "__DEEPSEEK_API_KEY_PLACEHOLDER__";
            xiaomi-token-plan-sgp.options.apiKey = "__MIMO_API_KEY_PLACEHOLDER__";
          };
        };
      };
    }

    # ── Config (only when enabled) ───────────────────────────────────────
    (lib.mkIf cfg.enable {
    # ── OpenCode config file ──────────────────────────────────────────────
    xdg.configFile = {
      "opencode/opencode.json" = {
        text = opencodeConfigJson;
        force = true;
      };
      "opencode/tui.json" = {
        text = builtins.toJSON { theme = "catppuccin-macchiato"; };
        force = true;
      };
    };

    # ── Packages ─────────────────────────────────────────────────────────
    home.packages = with pkgs; [
      jq
      gnused
      git
      nodejs_22
      bun
      gh
      semgrep
    ];

    # ── Activation: secret patching ──────────────────────────────────────
    home.activation.patchAiAgentSecrets = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
      patch_json_file() {
        local file="$1" arg_name="$2" arg_value="$3" filter="$4"
        ${pkgs.jq}/bin/jq --arg "$arg_name" "$arg_value" "$filter" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      }

      escape_sed_replacement() {
        printf '%s\n' "$1" | ${pkgs.gnused}/bin/sed 's/[&/\]/\\&/g'
      }

      OPENCODE_CFG="$HOME/.config/opencode/opencode.json"

      # --- Z.AI ---
      if [[ -n "${cfg.secrets.zaiApiKeyFile or ""}" ]] && [[ -f "${cfg.secrets.zaiApiKeyFile}" ]]; then
        ZAI_KEY="$(cat "${cfg.secrets.zaiApiKeyFile}")"
        if [[ -f "$OPENCODE_CFG" ]]; then
          patch_json_file "$OPENCODE_CFG" key "$ZAI_KEY" '${helpers.opencodeZaiFilter}'
          echo "✓ Patched opencode.json with Z.AI API key"
        fi
        unset ZAI_KEY
      fi

      # --- OpenRouter ---
      if [[ -n "${cfg.secrets.openrouterApiKeyFile or ""}" ]] && [[ -f "${cfg.secrets.openrouterApiKeyFile}" ]]; then
        OPENROUTER_KEY="$(cat "${cfg.secrets.openrouterApiKeyFile}")"
        if [[ -f "$OPENCODE_CFG" ]]; then
          patch_json_file "$OPENCODE_CFG" key "$OPENROUTER_KEY" '${helpers.openrouterPlaceholderFilter}'
          echo "✓ Patched opencode.json with OpenRouter API key"
        fi
        unset OPENROUTER_KEY
      fi

      # --- Context7 ---
      if [[ -n "${cfg.secrets.context7ApiKeyFile or ""}" ]] && [[ -f "${cfg.secrets.context7ApiKeyFile}" ]]; then
        CONTEXT7_KEY="$(cat "${cfg.secrets.context7ApiKeyFile}")"
        if [[ -f "$OPENCODE_CFG" ]]; then
          patch_json_file "$OPENCODE_CFG" key "$CONTEXT7_KEY" '${helpers.context7PlaceholderFilter}'
          echo "✓ Patched opencode.json with Context7 API key"
        fi
        unset CONTEXT7_KEY
      fi

      # --- GitHub (from gh CLI) ---
      if ${pkgs.gh}/bin/gh auth status &> /dev/null; then
        GH_TOKEN="$(${pkgs.gh}/bin/gh auth token)"
        if [[ -f "$OPENCODE_CFG" ]]; then
          patch_json_file "$OPENCODE_CFG" token "$GH_TOKEN" '${helpers.githubPlaceholderFilter}'
          echo "✓ Patched opencode.json with GitHub token"
        fi
        unset GH_TOKEN
      fi

      # --- DeepSeek ---
      if [[ -n "${cfg.secrets.deepseekApiKeyFile or ""}" ]] && [[ -f "${cfg.secrets.deepseekApiKeyFile}" ]]; then
        DEEPSEEK_KEY="$(cat "${cfg.secrets.deepseekApiKeyFile}")"
        escaped="$(escape_sed_replacement "$DEEPSEEK_KEY")"
        if [[ -f "$OPENCODE_CFG" ]]; then
          ${pkgs.gnused}/bin/sed -i "s/__DEEPSEEK_API_KEY_PLACEHOLDER__/$escaped/g" "$OPENCODE_CFG"
          echo "✓ Patched opencode.json with DeepSeek key"
        fi
        unset DEEPSEEK_KEY escaped
      fi

      # --- MiMo ---
      if [[ -n "${cfg.secrets.mimoApiKeyFile or ""}" ]] && [[ -f "${cfg.secrets.mimoApiKeyFile}" ]]; then
        MIMO_KEY="$(cat "${cfg.secrets.mimoApiKeyFile}")"
        escaped="$(escape_sed_replacement "$MIMO_KEY")"
        if [[ -f "$OPENCODE_CFG" ]] && grep -q '__MIMO_API_KEY_PLACEHOLDER__' "$OPENCODE_CFG"; then
          ${pkgs.gnused}/bin/sed -i "s/__MIMO_API_KEY_PLACEHOLDER__/$escaped/g" "$OPENCODE_CFG"
          echo "✓ Patched opencode.json with MiMo key"
        fi
        unset MIMO_KEY escaped
      fi
    '';

    # ── Activation: skills installation ──────────────────────────────────
    home.activation.installAgentSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export BUN_INSTALL="$HOME/.bun"
      export PATH="${pkgs.git}/bin:${pkgs.nodejs_22}/bin:${pkgs.bun}/bin:$BUN_INSTALL/bin:$PATH"
      export SKILLS_CLONE_TIMEOUT_MS=600000

      SKILLS_BIN="$BUN_INSTALL/bin/skills"
      if [[ ! -x "$SKILLS_BIN" ]]; then
        SKILLS_BIN="$(command -v skills 2>/dev/null || true)"
      fi

      if [[ -z "$SKILLS_BIN" ]]; then
        echo "📦 Bootstrapping skills CLI..."
        if ! $DRY_RUN_CMD "${pkgs.bun}/bin/bun" add --global --cwd "$HOME" --no-summary skills; then
          echo "❌ Failed to bootstrap skills CLI"
          exit 1
        fi
        SKILLS_BIN="$BUN_INSTALL/bin/skills"
        [[ -x "$SKILLS_BIN" ]] || SKILLS_BIN="$(command -v skills 2>/dev/null || true)"
      fi

      if [[ -z "$SKILLS_BIN" ]]; then
        echo "❌ skills CLI not found after bootstrap"
        exit 1
      fi

      desired_state=$(printf '%s' '${builtins.toJSON skills}' | ${pkgs.coreutils}/bin/sha256sum | cut -d' ' -f1)
      cache_dir="$HOME/.cache/ai-agents"
      cache_file="$cache_dir/skills-state.sha256"
      lock_file="$HOME/.agents/.skill-lock.json"

      skip=0
      if [[ -f "$cache_file" ]] && [[ -f "$lock_file" ]]; then
        current="$(cat "$cache_file")"
        [[ "$current" == "$desired_state" ]] && skip=1
      fi

      if [[ "$skip" -eq 0 ]]; then
        echo "🧹 Cleaning existing skills..."
        "$SKILLS_BIN" remove --global --all --yes 2>/dev/null || true
        rm -rf "$HOME/.agents/skills"/* 2>/dev/null || true
        rm -rf "$HOME/.agents/.skill-lock.json" 2>/dev/null || true
        rm -rf "$HOME/.claude/skills"/* 2>/dev/null || true

        attempt_cmd() {
          local label="$1"; shift
          for attempt in 1 2 3; do
            if $DRY_RUN_CMD "$@"; then return 0; fi
            echo "⚠ $label failed (attempt $attempt/3)"
            sleep 1
          done
          return 1
        }

        failed=0; success=0
        echo "📦 Installing agent skills..."
        ${lib.concatStringsSep "\n" (map (skill:
          if builtins.isString skill then ''
            echo "  → ${skill}"
            if ! attempt_cmd "install ${skill}" "$SKILLS_BIN" add "${skill}" --global --yes; then
              echo "❌ Failed: ${skill}"; failed=$((failed + 1))
            else
              echo "✔ ${skill}"; success=$((success + 1))
            fi
          '' else ''
            echo "  → ${skill.repo}/${skill.skill}"
            if ! attempt_cmd "install ${skill.repo}/${skill.skill}" "$SKILLS_BIN" add "https://github.com/${skill.repo}" --skill "${skill.skill}" --global --yes; then
              echo "❌ Failed: ${skill.repo}/${skill.skill}"; failed=$((failed + 1))
            else
              echo "✔ ${skill.repo}/${skill.skill}"; success=$((success + 1))
            fi
          ''
        ) skills)}

        echo "🧠 Skills: success=$success failures=$failed"
        mkdir -p "$cache_dir"
        printf '%s' "$desired_state" > "$cache_file"
        echo "✓ Skills installation complete"
      else
        echo "✓ Skills configuration unchanged; skipping"
      fi

      # Mirror skills to OpenCode config dir
      if [[ -d "$HOME/.claude/skills" ]]; then
        target="$HOME/.config/opencode/skills"
        mkdir -p "$target"
        find "$target" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true
        for d in "$HOME/.claude/skills"/*; do
          [[ -d "$d" ]] || continue
          link="$target/$(basename "$d")"
          [[ -e "$link" ]] || ln -sfn "$d" "$link"
        done
        echo "✓ Mirrored skills to OpenCode"
      fi
    '';

    # ── Auto-update OpenCode CLI ─────────────────────────────────────────
    home.activation.updateOpenCodeCLI = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.nodejs_22}/bin:${pkgs.bun}/bin:$HOME/.bun/bin:$PATH"
      if command -v opencode &>/dev/null || [[ -x "$HOME/.bun/bin/opencode" ]]; then
        echo "📦 Updating OpenCode CLI..."
        ${pkgs.bun}/bin/bun update -g opencode-ai 2>/dev/null && echo "✔ OpenCode updated" || echo "⚠ OpenCode update skipped"
      else
        echo "📦 Installing OpenCode CLI..."
        ${pkgs.bun}/bin/bun add -g opencode-ai 2>/dev/null && echo "✔ OpenCode installed" || echo "⚠ OpenCode install failed"
      fi
    '';
    }) # end mkIf
  ]; # end mkMerge
}
