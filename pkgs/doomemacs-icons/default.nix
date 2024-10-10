{ stdenv, fetchurl }:
let
  icon = fetchurl {
    url = "https://github.com/jaidetree/doom-icon/tree/e90e93ff6c05615137a0a3694f4674ba83ff00ae";
    sha256 = "";
  };
in
stdenv.mkDerivation rec {
  name = "doomemacs-icons-${version}";
  version = "2023-03-10";
  src =icon;
  installPhase = ''install -Dm644 ${icon}/{abject,cute,emacs}-doom/ $out/share/doomemacs-icons/
  rm -rf $out/share/doomemacs-icons/*/src'';
}
