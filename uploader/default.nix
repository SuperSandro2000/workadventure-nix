{ stdenv
, fetchFromGitHub
, makeWrapper
, mkYarnPackage
, nodejs-14_x
, workadventure-messages
, yarn2nix-moretea
, ... }:

yarn2nix-moretea.mkYarnPackage rec {
  pname = "workadventureuploader";
  version = "unstable";

  src = fetchFromGitHub
    {
      owner = "thecodingmachine";
      repo = "workadventure";
      rev = "284846e8a59ec0d921189ac3a46e0eb5d1e14818";
      sha256 = "1f1vi226kas7x9y8zw810q5vg1ikn4bb6ha9vnzvqk9y7jlc1n8q";
    } + "/uploader";

  # NOTE: this is optional and generated dynamically if omitted
  yarnNix = ./yarn.nix;

  nativeBuildInputs = [ makeWrapper ];

  dontStrip = true;

  buildPhase = ''
    mkdir -p $out
    # ln -s ${workadventure-messages.outPath}/generated deps/workadventureback/src/Messages/generated
    HOME=$TMPDIR yarn --offline run tsc
    cp -r deps/workadventureback/dist $out/dist
  '';

  postInstall = ''
    # node-abi needs to the abi of the node here
    makeWrapper '${nodejs-14_x}/bin/node' "$out/bin/${pname}" \
      --set NODE_PATH $out/libexec/workadventureback/node_modules \
      --add-flags "$out/dist/server.js"
  '';
}
