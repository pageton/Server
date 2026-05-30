# Zsh config for Server — keybindings and basic setup.
{ ... }:
{
  programs.zsh = {
    enable = true;
    initExtraFirst = ''
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
