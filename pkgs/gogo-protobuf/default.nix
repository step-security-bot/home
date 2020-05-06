# This file was generated by https://github.com/kamilchm/go2nix v1.2.1
{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "gogo-protobuf-unstable-${version}";
  version = "2018-09-14";
  rev = "e14cafb6a2c249986e51c4b65c3206bf18578715";

  goPackagePath = "github.com/gogo/protobuf";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/gogo/protobuf";
    sha256 = "1q00r1s462xsmw8qc6incvp6m3f39jibjj8syw23jvwiy3vp75a8";
  };

  goDeps = ./deps.nix;
  subPackages = [
    "protoc-gen-combo" "protoc-gen-gofast" "protoc-gen-gogo"
    "protoc-gen-gogofast" "protoc-gen-gogofaster" "protoc-gen-gogoslick"
    "protoc-gen-gogotypes" "protoc-gen-gostring" "protoc-min-version"
  ];

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}