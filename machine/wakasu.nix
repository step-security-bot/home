{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ../hardware-configuration.nix
    ../profiles/laptop.nix
    ../profiles/ssh.nix
    ../profiles/yubikey.nix
    ../profiles/dev.nix
    ../profiles/containerd.nix
    ../profiles/dockerization.nix
    ../profiles/virtualization.nix
    ../location/docker.nix
    ../location/home.nix
    ../hardware/thinkpad-t460s.nix
  ];

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "99"; }
    { domain = "@audio"; item = "nofile";  type = "-"; value = "99999"; }
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/e511e87f-a3b1-472a-bebb-c6cdd5154a16";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.trackpoint.enable = false;

  networking.firewall.allowedTCPPorts = [ 5900 ];

  time.timeZone = "Europe/Paris";

  services.xserver.displayManager.slim.theme = pkgs.fetchurl {
    url = "https://github.com/vdemeester/slim-themes/raw/master/docker-key-theme-0.1.tar.xz";
    sha256 = "127893l1nzqya0g68k8841g5lm3hlnx7b3b3h06axvplc54a1jd8";
  };
}
