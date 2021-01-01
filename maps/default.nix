{ stdenv
, fetchFromGitHub
, makeWrapper
, yarn2nix-moretea
, ... }:

yarn2nix-moretea.mkYarnPackage rec {
  pname = "workadventuremaps";
  version = "unstable";

  src = fetchFromGitHub
    {
      owner = "thecodingmachine";
      repo = "workadventure";
      rev = "284846e8a59ec0d921189ac3a46e0eb5d1e14818";
      sha256 = "1f1vi226kas7x9y8zw810q5vg1ikn4bb6ha9vnzvqk9y7jlc1n8q";
    } + "/maps";

  # NOTE: this is optional and generated dynamically if omitted
  yarnNix = ./yarn.nix;

  nativeBuildInputs = [ makeWrapper ];

  dontStrip = true;

  buildPhase = ''
    mkdir -p $out
    HOME=$TMPDIR yarn --offline run tsc
    cp -r deps/${pname} $out
  '';
}
