{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.desktop;

  dim-screen = pkgs.writeScript "dim-sreen.sh" ''
#!${pkgs.stdenv.shell}
export PATH=${lib.getBin pkgs.xlibs.xbacklight}/bin:$PATH
trap "exit 0" INT TERM
trap "kill \$(jobs -p); xbacklight -steps 1 -set $(xbacklight -get);" EXIT
xbacklight -time 5000 -steps 400 -set 0 &
sleep 2147483647 &
wait
  '';
in
{
  options = {
    profiles.desktop = {
      enable = mkOption {
        default = false;
        description = "Enable desktop profile";
        type = types.bool;
      };
      lockCmd = mkOption {
        default = "${pkgs.slim}/bin/slimlock";
        description = "Lock command to use";
        type = types.str;
      };
      xsession = {
        enable = mkOption {
          default = true;
          description = "Enable xsession managed";
          type = types.bool;
        };
        i3 = mkOption {
           default = true;
           description = "Enable i3 managed window manager";
           type = types.bool;
        };
      };
    };
  };
  config = mkIf cfg.enable {
    profiles.gpg.enable = true;
    xsession = mkIf cfg.xsession.enable {
      enable = true;
      initExtra = ''
        ${pkgs.xlibs.xmodmap}/bin/xmodmap ${config.home.homeDirectory}.Xmodmap &
      '';
      pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
      };
    };
    home.keyboard = mkIf cfg.xsession.enable {
      layout = "fr(bepo),fr";
      variant = "oss";
      options = ["grp:menu_toggle" "grp_led:caps" "compose:caps"];
    };
    gtk = {
      enable = true;
      iconTheme = {
        name = "Arc";
        package = pkgs.arc-icon-theme;
      };
      theme = {
        name = "Arc";
        package = pkgs.arc-theme;
      };
    };
    services = {
      redshift = {
        enable = true;
        brightness = { day = "1"; night = "0.9"; };
        latitude = "48.3";
        longitude = "7.5";
        tray = true;
      };
      screen-locker = {
        enable = true;
        xssLockExtraOptions = [ "-n ${dim-screen}" ];
        lockCmd = cfg.lockCmd;
        inactiveInterval = 15;
      };
    };
    home.file.".XCompose".source = ./assets/xorg/XCompose;
    home.file.".Xmodmap".source = ./assets/xorg/Xmodmap;
    xdg.configFile."xorg/emoji.compose".source = ./assets/xorg/emoji.compose;
    xdg.configFile."xorg/parens.compose".source = ./assets/xorg/parens.compose;
    xdg.configFile."xorg/modletters.compose".source = ./assets/xorg/modletters.compose;
    xdg.configFile."user-dirs.dirs".source = ./assets/xorg/user-dirs.dirs;
    xdg.configFile."nr/desktop" = {
      text = builtins.toJSON [
        {cmd = "surf";} {cmd = "dmenu";} {cmd = "sxiv";}
        {cmd = "virt-manager"; pkg = "virtmanager";}
        {cmd = "update-desktop-database"; pkg = "desktop-file-utils"; chan = "unstable";}
        {cmd = "lgogdownloader"; chan = "unstable";}
      ];
      onChange = "${pkgs.nur.repos.vdemeester.nr}/bin/nr desktop";
    };
    programs = {
      firefox.enable = true;
    };
    profiles.i3.enable = cfg.xsession.i3;
    home.packages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.fr
      #etBook
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
      keybase
      mpv
      peco
      pass
      xdg-user-dirs
      xdg_utils
      xsel
    ];
  };
}
