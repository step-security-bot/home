{ config, pkgs, ... }: {
  imports = [
    ../hardware-configuration.nix
    ../profiles/server.nix
    ../profiles/gitconfig.nix
    ../profiles/users.nix
  ];

  boot.cleanTmpDir = true;
  networking.firewall.allowPing = true;
  services.openssh.enable = true;
  programs.fish.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGR4dqXwHwPpYgyk6yl9+9LRL3qrBZp3ZWdyKaTiXp0p vincent@shikoku"
  ];
  time.timeZone = "Europe/Paris";

  services = {
    logind.extraConfig = "HandleLidSwitch=ignore";
  };
  
  services.wireguard = with import ../assets/machines.nix; {
    enable = true;
    ips = [ "${wireguard.ips.massimo}/24" ];
    endpoint = wg.endpointIP;
    endpointPort = wg.listenPort;
    endpointPublicKey = wireguard.kerkouane.publicKey;
  };
}
