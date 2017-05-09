{ config, pkgs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
			../hardware-configuration.nix
			../configuration/custom-packages.nix
			../configuration/common.nix
			../profiles/ssh.nix
			../profiles/laptop.nix
			../profiles/virtualization.nix
			../profiles/dockerization.nix
			../profiles/office.nix
			../location/home.nix
			../hardware/dell-latitude-e6540.nix
			../service/ssh-tunnel.nix
		];
	
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
    configFile = pkgs.writeText "default.pa" ''
        load-module module-udev-detect
        load-module module-jackdbus-detect channels=2
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
        load-module module-esound-protocol-unix
        load-module module-native-protocol-unix
        load-module module-always-sink
        load-module module-console-kit
        load-module module-systemd-login
        load-module module-intended-roles
        load-module module-position-event-sounds
        load-module module-filter-heuristics
        load-module module-filter-apply
        load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
      '';
  };

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "99"; }
    { domain = "@audio"; item = "nofile";  type = "-"; value = "99999"; }
];
	hardware.bluetooth.enable = true;
#boot.blacklistedKernelModules = [ "radeon" ];
#boot.kernelParams = [ "nomodeset" "video=vesafb:off" "modprobe.blacklist=radeon" ];

# environment.systemPackages = with pkgs; [
#  	linuxPackages_4_1.ati_drivers_x11
#]; 
#  system.activationScripts.drifix = ''
#    mkdir -p /usr/lib/dri
#    ln -sf /run/opengl-driver/lib/dri/fglrx_dri.so /usr/lib/dri/fglrx_dri.so
#  '';
	services = {
	ssh-tunnel = {
		enable = true;
		localUser = "vincent";
		remoteHostname = "95.85.58.158";
		remotePort = 22;
		remoteUser = "vincent";
		bindPort = 2224;
	};
	printing = {
		enable = true;
		drivers = [ pkgs.gutenprint ];
	};
		xserver = {
			enable = true;
			videoDrivers = [ "intel" ];
			exportConfiguration = true;
			displayManager.slim.theme = pkgs.fetchurl {
						url = "https://github.com/vdemeester/slim-themes/raw/master/docker-penguins-theme-0.1.tar.xz";
						sha256 = "1s0cfj1l9ay7y0ib68dnpdfkr1zwgr0b1s990ch786lxlajwwxpq";
						};

		};
};
}
