{
  imports = [
    ./core
    ./hardware
    ./profiles
    ./programs
    ./services
    ./virtualisation
    "${(import ../../nix/sources.nix).sops-nix}/modules/sops"
  ];
}
