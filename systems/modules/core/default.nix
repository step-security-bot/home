{ config, lib, pkgs, ... }:
{
  imports = [
    ./boot.nix
    ./config.nix
    ./nix.nix
    ./users.nix
    ./binfmt.nix
  ];

  boot = {
    cleanTmpDir = true;
  };
  # FIXME fix tmpOnTmpfs
  systemd.additionalUpstreamSystemUnits = [ "tmp.mount" ];

  security.sudo = {
    extraConfig = ''
      Defaults env_keep += SSH_AUTH_SOCK
    '';
  };

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Clear out /tmp after a fortnight and give all normal users a ~/tmp
  # cleaned out weekly.
  systemd.tmpfiles.rules = [ "d /tmp 1777 root root 14d" ] ++
    (
      let mkTmpDir = n: u: "d ${u.home}/tmp 0700 ${n} ${u.group} 7d";
      in lib.mapAttrsToList mkTmpDir (lib.filterAttrs (_: u: u.isNormalUser) config.users.extraUsers)
    );

  systemd.services."status-email-root@" = {
    description = "status email for %i to vincent";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.my.systemd-email}/bin/systemd-email vincent@demeester.fr %i
      '';
      User = "root";
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };
}
