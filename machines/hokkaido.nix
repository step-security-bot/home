{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  profiles.emacs = { daemonService = false; };
  profiles.dev = {
    go.enable = true;
  };
  profiles.containers.enable = true;
  profiles.media.enable = true;
}
