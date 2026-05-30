# Zsh config for Server — keybindings and basic setup.
{ lib, ... }:
{
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
