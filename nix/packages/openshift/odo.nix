{ stdenv, lib, fetchurl }:

with lib;
rec {
  odoGen =
    { version
    , sha256
    }:

    stdenv.mkDerivation rec {
      pname = "odo";
      name = "${pname}-${version}";

      src = fetchurl {
        url = "https://mirror.openshift.com/pub/openshift-v4/clients/odo/v${version}/odo-linux-amd64.tar.gz";
        sha256 = "${sha256}";
      };

      phases = " unpackPhase installPhase fixupPhase ";

      unpackPhase = ''
        runHook preUnpack
        mkdir ${name}
        tar -C ${name} -xzf $src
      '';

      installPhase = ''
        runHook preInstall
        install -D ${name}/odo $out/bin/odo
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          $out/bin/odo
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/odo utils terminal bash > $out/share/bash-completion/completions/odo
        mkdir -p $out/share/zsh/site-functions
        $out/bin/odo utils terminal zsh > $out/share/zsh/site-functions/_odo
      '';
    };

  odo = odo_2_3;
  odo_2_3 = makeOverridable odoGen {
    version = "2.3.1";
    sha256 = "13frxa5mf52j08mica4j9v6zdrqxhccx0injz860fywbcsz0x67p";
  };
  odo_2_2 = makeOverridable odoGen {
    version = "2.2.4";
    sha256 = "1ma0q79s85dy23b4ygjm67dm05i7clm39h5p86sdz4wz63amiqcg";
  };
  odo_2_1 = makeOverridable odoGen {
    version = "2.1.0";
    sha256 = "1jy79wg7war7i1hnlnzxcs2nj81r5zyk9sr2vc6knwxjg5cllis6";
  };
  odo_2_0 = makeOverridable odoGen {
    version = "2.0.7";
    sha256 = "05mxdxy8llava10sq9b111xq2bd5ywlw80s3zkwk8nzikhjjfvg3";
  };
  odo_1_2 = makeOverridable odoGen {
    version = "1.2.6";
    sha256 = "0dhnc413sgymwy8df27diz7bkpkckgm6jws88na4mg82jffnyn1w";
  };
}