{ config, pkgs, ... }:

with import ../assets/machines.nix; {
  imports = [ ../networking.nix ];
  time.timeZone = "Europe/Paris";
  boot = {
    cleanTmpDir = true;
    loader.grub.enable = true;
  };
  profiles = {
    git.enable = true;
    nix-config.localCaches = [];
    nix-config.buildCores = 1;
    ssh.enable = true;
    syncthing.enable = true;
    wireguard.server.enable = true;
  };
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security = {
    acme.certs = {
      "sbr.pm".email = "vincent@sbr.pm";
    };
  };
  services = {
    govanityurl = {
      enable = true;
      user = "nginx";
      host = "go.sbr.pm";
      config = ''
        paths:
          /ape:
            repo: https://github.com/vdemeester/ape
          /nr:
            repo: https://github.com/vdemeester/nr
          /ram:
            repo: https://github.com/vdemeester/ram
          /sec:
            repo: https://github.com/vdemeester/sec
      '';
    };
    nginx = {
      enable = true;
      virtualHosts."dl.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/dl.sbr.pm";
        locations."/" = {
          index = "index.html";
        };
      };
      virtualHosts."paste.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/paste.sbr.pm";
        locations."/" = {
          index = "index.html";
        };
      };
      virtualHosts."go.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = { proxyPass = "http://127.0.0.1:8080"; };
      };
      virtualHosts."sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/sbr.pm";
        locations."/" = {
          index = "index.html";
        };
      };
      virtualHosts."vincent.demeester.fr" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/vincent.demeester.fr";
        locations."/" = {
          index = "index.html";
        };
      };
    };
    openssh.ports = [ ssh.kerkouane.port ];
    openssh.permitRootLogin = "without-password";
    syncthing.guiAddress = "127.0.0.1:8384";
  };
}
