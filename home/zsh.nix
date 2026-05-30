# Zsh config for Server — PATH, keybindings, env vars.
{ config, lib, ... }:
let
  sopsSecrets = config.sops.secrets;
in
{
  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
  ];

  home.sessionVariables = {
    BUN_INSTALL = "${config.home.homeDirectory}/.bun";
  };

  programs.zsh = {
    enable = true;
    initContent = lib.mkBefore ''
      # Ctrl+Arrow word navigation
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # Home/End
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line

      # Delete word (Ctrl+Backspace)
      bindkey "^H" backward-kill-word
    '';
  };
}
