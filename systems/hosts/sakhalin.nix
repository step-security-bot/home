{ pkgs, lib, ... }:

with lib;
let
  hostname = "sakhalin";
  secretPath = ../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  ip = strings.optionalString secretCondition (import secretPath).wireguard.ips."${hostname}";
  ips = lists.optionals secretCondition ([ "${ip}/24" ]);
  endpointIP = strings.optionalString secretCondition (import secretPath).wg.endpointIP;
  endpointPort = if secretCondition then (import secretPath).wg.listenPort else 0;
  endpointPublicKey = strings.optionalString secretCondition (import secretPath).wireguard.kerkouane.publicKey;

  metadata = importTOML ../../ops/hosts.toml;
in
{
  imports = [
    ../hardware/gigabyte-brix.nix
    # (import ../../nix).home-manager-stable
    # ../modules/default.stable.nix
    (import ../../users/vincent)
    (import ../../users/root)
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/92ce650d-873e-41c1-a44e-71c2b9191b9d";
    fsType = "ext4";
    options = [ "noatime" "discard" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B226-075A";
    fsType = "vfat";
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/4f614c00-d94d-42f9-8386-3ecd396aa246";
    fsType = "ext4";
    options = [ "noatime" "discard" ];
  };
  fileSystems."/mnt/gaia" = {
    device = "/dev/disk/by-uuid/88d3d686-d451-4ba9-bd6e-373601ed2683";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  fileSystems."/mnt/toshito" = {
    device = "/dev/disk/by-uuid/3c7cf84e-2486-417d-9de8-4b7757d483e4";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  swapDevices = [{ device = "/dev/disk/by-uuid/9eb067d1-b329-4fbb-ae27-38abfbe7c108"; }];

  networking = {
    hostName = hostname;
    firewall.enable = false; # we are in safe territory :D
    bridges.br1.interfaces = [ "enp0s31f6" ];
    useDHCP = false;
    interfaces.br1 = {
      useDHCP = true;
    };
  };

  modules = {
    services = {
      syncthing = {
        enable = true;
        guiAddress = "${metadata.hosts.sakhalin.wireguard.addrs.v4}:8384";
      };
      avahi.enable = true;
      ssh.enable = true;
    };
    virtualisation.libvirt = { enable = true; nested = true; listenTCP = true; };
  };

  profiles = {
    bind.enable = true;
    home = true;
    git.enable = true;
  };

  fileSystems."/export/gaia" = { device = "/mnt/gaia"; options = [ "bind" ]; };
  fileSystems."/export/toshito" = { device = "/mnt/toshito"; options = [ "bind" ]; };

  services = {
    tarsnap = {
      enable = true;
      archives = {
        documents = {
          directories = [ "/home/vincent/desktop/documents" ];
          period = "daily";
          keyfile = "/etc/nixos/assets/tarsnap.documents.key";
        };
        org = {
          directories = [ "/home/vincent/desktop/org" ];
          period = "daily";
          keyfile = "/etc/nixos/assets/tarsnap.org.key";
        };
      };
    };
    nfs.server = {
      enable = true;
      exports = ''
        /export                      192.168.1.0/24(rw,fsid=0,no_subtree_check) 10.100.0.0/24(rw,fsid=0,no_subtree_check)
        /export/gaia                 192.168.1.0/24(rw,fsid=1,no_subtree_check) 10.100.0.0/24(rw,fsid=1,no_subtree_check)
        /export/toshito              192.168.1.0/24(rw,fsid=2,no_subtree_check) 10.100.0.0/24(rw,fsid=2,no_subtree_check)
      '';
    };
    # nix-binary-cache = {
    #   enable = true;
    #   domain = "nix.cache.home";
    #   aliases = [ "cache.sakhalin.home" ];
    # };
    dockerRegistry = {
      enable = true;
      listenAddress = "0.0.0.0";
      enableGarbageCollect = true;
    };
    wireguard = {
      enable = true;
      ips = ips;
      endpoint = endpointIP;
      endpointPort = endpointPort;
      endpointPublicKey = endpointPublicKey;
    };
  };
  security.apparmor.enable = true;
  # -----------------------------------
  environment.etc."vrsync".text = ''
    /home/vincent/desktop/pictures/screenshots/ vincent@synodine.home:/volumeUSB2/usbshare/pictures/screenshots/
    /home/vincent/desktop/pictures/wallpapers/ vincent@synodine.home:/volumeUSB2/usbshare/pictures/wallpapers/
    /home/vincent/desktop/documents/ vincent@synodine.home:/volume1/documents/
    /mnt/gaia/photos/ vincent@synodine.home:/volumeUSB2/usbshare/pictures/photos/
    /mnt/gaia/music/ vincent@synodine.home:/volumeUSB2/usbshare/music/
  '';
  systemd.services.vrsync = {
    description = "vrsync - sync folders to NAS";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    unitConfig.X-StopOnRemoval = false;
    restartIfChanged = false;

    path = with pkgs; [ rsync coreutils bash openssh ];
    script = ''
      ${pkgs.vrsync}/bin/vrsync
    '';

    startAt = "hourly";
    serviceConfig = {
      Type = "oneshot";
      OnFailure = "status-email-root@%n.service";
    };
  };
  # ape – sync git mirrors
  systemd.services.ape = {
    description = "Ape - sync git mirrors";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;

    serviceConfig = {
      Type = "oneshot";
      User = "vincent";
      OnFailure = "status-email-root@%n.service";
    };

    path = with pkgs; [ git ];
    script = ''
      ${pkgs.my.ape}/bin/ape up /home/vincent/var/mirrors
    '';

    startAt = "hourly";
  };
  # mr -i u daily
  systemd.services.mr = {
    description = "Update configs daily";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;

    serviceConfig = {
      Type = "oneshot";
      User = "vincent";
      OnFailure = "status-email-root@%n.service";
    };

    path = with pkgs; [ git mr ];
    script = ''
      set -e
       cd /mnt/gaia/src/configs/
       mr -t run git reset --hard
       mr -t u
    '';

    startAt = "daily";
  };
}
