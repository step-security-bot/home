{ pkgs, config, lib, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = import ./aliases.nix;
    shellInit = ''
    eval (${pkgs.direnv}/bin/direnv hook fish)
    '';
  };
  xdg.configFile."fish/conf.d/a_nix_run.fish".source = ./fish/a_nix_run.fish;
  xdg.configFile."fish/conf.d/nix-aliases.fish".source = ./fish/nix-aliases.fish;
  xdg.configFile."fish/conf.d/sudope.fish".source = ./fish/sudope.fish;
  xdg.configFile."fish/functions/sudope.fish".source = ./fish/sudope.function.fish;
  xdg.configFile."fish/functions/fish_prompt.fish".source = ./fish/fish_prompt.fish;
  xdg.configFile."fish/functions/fish_right_prompt.fish".source = ./fish/fish_right_prompt.fish;
}
