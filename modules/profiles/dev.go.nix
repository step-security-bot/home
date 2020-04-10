{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.go;
in
{
  options = {
    profiles.dev.go = {
      enable = mkEnableOption "Enable go development profile";
    };
  };
  config = mkIf cfg.enable (
    mkMerge [
      {
        home.sessionVariables = {
          GOPATH = "${config.home.homeDirectory}";
        };
        profiles.dev.enable = true;
        home.packages = with pkgs; [
          gcc
          go
          godef
          golangci-lint
          golint
          gopkgs
          go-outline
          go-symbols
          delve
          # vendoring tools
          dep
          nur.repos.vdemeester.dep-collector
          # misc
          protobuf
          nur.repos.vdemeester.protobuild
          nur.repos.vdemeester.ram
          nur.repos.vdemeester.sec
          nur.repos.vdemeester.goreturns
          nur.repos.vdemeester.esc
          nur.repos.vdemeester.yaspell
        ];
        xdg.configFile."nr/go" = {
          text = builtins.toJSON [
            { cmd = "pprof"; chan = "unstable"; }
            { cmd = "vndr"; chan = "unstable"; }
            { cmd = "go2nix"; }
            { cmd = "dep2nix"; }
          ];
          onChange = "${pkgs.nur.repos.vdemeester.nr}/bin/nr go";
        };
      }
      (
        mkIf config.profiles.fish.enable {
          xdg.configFile."fish/conf.d/go.fish".source = ./assets/fish/go.fish;
          programs.fish.shellAbbrs = {
            got = "go test -v";
            gob = "go build -v";
            gol = "golangci-lint run";
          };
        }
      )
    ]
  );
}
