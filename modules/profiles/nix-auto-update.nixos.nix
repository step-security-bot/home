{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.nix-auto-update;
in
{
  options = {
    profiles.nix-auto-update = {
      enable = mkOption {
        default = true;
        description = "Enable nix-auto-update profile";
        type = types.bool;
      };
      autoUpgrade = mkOption {
        default = true;
        description = "Automatically try to upgrade the system";
        type = types.bool;
      };
      dates = mkOption {
        default = "weekly";
        description = "Specification (in the format described by systemd.time(7)) of the time at which the auto-update will run. ";
        type = types.str;
      };
      version = mkOption {
        default = "20.03";
        description = "System version (NixOS)";
        type = types.str;
      };
    };
  };
  config = mkIf cfg.enable
    (
      mkMerge [
        {
          system = {
            stateVersion = cfg.version;
          };
        }
        (
          mkIf cfg.autoUpgrade {
            systemd.services.nixos-update = {
              description = "NixOS Upgrade";
              unitConfig.X-StopOnRemoval = false;
              restartIfChanged = false;
              serviceConfig.Type = "oneshot";
              environment = config.nix.envVars
                // {
                inherit (config.environment.sessionVariables) NIX_PATH;
                HOME = "/root";
              };
              path = [ pkgs.gnutar pkgs.xz pkgs.git pkgs.gnumake config.nix.package.out pkgs.commonsCompress ];
              script = ''
                export PATH=/run/current-system/sw/bin
                cd /etc/nixos/
                runuser -l vincent -c 'git pull --autostash --rebase'
                make update switch
              '';
              startAt = cfg.dates;
              onFailure = [ "status-email-root@%n.service" ];
            };
          }
        )
      ]
    );
}
