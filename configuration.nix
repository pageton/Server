# NixOS server configuration.
{
  modulesPath,
  stateVersion,
  hostname,
  user,
  inputs,
  pkgsStable,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
    ./disk-config.nix
    ./modules/nix.nix
    ./modules/security.nix
    ./modules/ddos.nix
    ./modules/bitwarden.nix
    ./modules/nginx.nix
    ./modules/cloudflared.nix
    ./modules/tailscale.nix
    ./modules/mtproxy.nix
  ];

  networking.hostName = hostname;
  time.timeZone = "Asia/Baghdad";

  # Bootloader — GRUB UEFI GPT
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.loader = lib.mkForce {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  # User
  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 YOUR_PUBLIC_KEY_HERE"
      ];
    };
  };

  # SSH — hardened
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      AllowUsers = [ user ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  services.mtproxyAymen = {
    enable = true;
    domain = "proxy.sadiq.lol";
    # Keep this off 443 because nginx is already bound there.
    port = 8443;
    workers = 16;
    # Create this file manually with:
    # MTPROXY_SECRET=<your_secret>
    # MTPROXY_TAG=<optional_tag>
    environmentFile = "/etc/mtproxy/mtproxy.env";
  };

  system.stateVersion = stateVersion;
}
