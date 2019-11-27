{ config, pkgs, ... }:

with import ../assets/machines.nix; {
  imports = [ ../hardware/lenovo-p50.nix ./home.nix ];
  boot = {
    kernelModules = [ "kvm_intel" ];
    kernelParams = [ "kvm_intel.nested=1" ];
    kernel.sysctl = {
      "net.bridge.bridge-nf-call-arptables" = 0;
      "net.bridge.bridge-nf-call-iptables" = 0;
      "net.bridge.bridge-nf-call-ip6tables" = 0;
    };
  };
  networking = {
    firewall.enable = false; # we are in safe territory :D
    bridges.br1.interfaces = [ "enp0s31f6" ];
    interfaces.enp0s31f6 = {
      useDHCP = true;
    };
    hosts = {
      "${home.ips.honshu}" = [ "honshu.home" ];
      "${wireguard.ips.honshu}" = [ "honshu.vpn" ];
      "${home.ips.shikoku}" = [ "shikoku.home" ];
      "${wireguard.ips.shikoku}" = [ "shikoku.vpn" ];
      "${home.ips.wakasu}" = [ "wakasu.home" ];
      "${wireguard.ips.wakasu}" = [ "wakasu.vpn" ];
      "${home.ips.hokkaido}" = [ "hokkaido.home" ];
      "${wireguard.ips.hokkaido}" = [ "hokkaido.vpn" ];
      "${home.ips.kobe}" = [ "kobe.home" ];
      "${wireguard.ips.kobe}" = [ "kobe.vpn" ];
      "${wireguard.ips.massimo}" = [ "massimo.vpn" ];
      "${home.ips.synodine}" = [ "synodine.home" ];
      "${home.ips.okinawa}" = [ "okinawa.home" "cache.home" "svc.home" "nix.cache.home" "go.cache.home" ];
      "${wireguard.ips.carthage}" = [ "carthage.vpn" ];
      "${wireguard.ips.kerkouane}" = [ "kerkouane.vpn" ];
    };
  };
  profiles = {
    dev.enable = true;
    laptop.enable = true;
    desktop.networkmanager = false;
    desktop.autoLogin = true;
    docker.enable = true;
    nix-config.buildCores = 4;
    #qemu-user = { arm = true; aarch64 = true; };
    ssh = {
      enable = true;
      forwardX11 = true;
    };
    virtualization = {
      enable = true;
      nested = true;
      listenTCP = true;
    };
    yubikey.enable = true;
  };
  programs = {
    podman.enable = true;
  };
  services = {
    logind.extraConfig = ''
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      HandleLidSwitchDocked=ignore
    '';
    syncthing.guiAddress = "${wireguard.ips.wakasu}:8384";
    smartd = {
      enable = true;
      devices = [ { device = "/dev/nvme0n1"; } ];
    };
    wireguard = {
      enable = true;
      ips = [ "${wireguard.ips.wakasu}/24" ];
      endpoint = wg.endpointIP;
      endpointPort = wg.listenPort;
      endpointPublicKey = wireguard.kerkouane.publicKey;
    };
    xserver = {
      videoDrivers = [ "nvidia" ];
      dpi = 96;
      serverFlagsSection = ''
          Option "BlankTime" "0"
          Option "StandbyTime" "0"
          Option "SuspendTime" "0"
          Option "OffTime" "0"
      '';
    };
  };
}
