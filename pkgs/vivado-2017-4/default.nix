{ stdenv
, lib
, bash
, coreutils
, writeScript
, gnutar
, gzip
, requireFile
, patchelf
, procps
, makeWrapper
, ncurses
, zlib
, libX11
, libXrender
, libxcb
, libXext
, libXtst
, libXi
, libxcrypt
, glib
, freetype
, gtk2
, buildFHSUserEnv
, gcc
, ncurses5
, glibc
, gperftools
, fontconfig
, liberation_ttf
}:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2017.4_extracted_setup";

    src = requireFile rec {
      name = "Xilinx_Vivado_SDK_2017.4_1216_1.tar.gz";
      url = "https://www.xilinx.com/member/forms/download/xef-vivado.html?filename=Xilinx_Vivado_SDK_2017.4_1216_1.tar.gz";
      sha256 = "0p7bafc5jdmawcw6vvs7wniar5z6pvcbzjqwniwa2dzyz04pqama";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (35.51GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf procps ncurses makeWrapper ];

    builder = writeScript "${name}-builder" ''
      #! ${bash}/bin/bash
      source $stdenv/setup

      mkdir -p $out/
      tar -xvf $src --strip-components=1 -C $out/ Xilinx_Vivado_SDK_2017.4_1216_1/

      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2017.4";

    nativeBuildInputs = [ zlib ];
    buildInputs = [ patchelf procps ncurses makeWrapper ];

    extracted = "${extractedSource}";

    builder = ./vivado_builder-2017_4.sh;
    inherit ncurses;

    libPath = lib.makeLibraryPath [
      stdenv.cc.cc
      ncurses
      zlib
      libX11
      libXrender
      libxcb
      libXext
      libXtst
      libXi
      freetype
      gtk2
      glib
      libxcrypt
      gperftools
      glibc.dev
      fontconfig
      liberation_ttf
    ];

    meta = {
      description = "Xilinx Vivado WebPack Edition";
      homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
      license = lib.licenses.unfree;
      mainProgram = "vivado";
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };

in
buildFHSUserEnv {
  name = "vivado";
  targetPkgs = _pkgs: [
    vivadoPackage
  ];
  multiPkgs = pkgs: [
    coreutils
    gcc
    ncurses5
    zlib
    glibc.dev
  ];
  runScript = "vivado";
}
