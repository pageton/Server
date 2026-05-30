# Home-Manager entry point for Server — OpenCode, git, gh.
{ pkgs, ... }:
{
  home = {
    username = "sadiq";
    homeDirectory = "/home/sadiq";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  home.enableNixpkgsReleaseCheck = false;

  imports = [
    ./ai-agents/default.nix
    ./git.nix
    ./gh.nix
    ./zsh.nix
  ];
}
