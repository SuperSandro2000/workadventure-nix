{ stdenv
, autoPatchelfHook
, makeWrapper

, fetchzip
, fetchFromGitHub

, nodejs-14_x
, yarn2nix-moretea

, workadventure
}:

let
  node-abi = "83";

  node-grpc-precompiled = fetchzip {
    name = "node-grpc-precompiled-node-${node-abi}";
    url = "https://node-precompiled-binaries.grpc.io/grpc/v1.24.4/node-v${node-abi}-linux-x64-glibc.tar.gz";
    sha256 = "119rhhk1jpi2vwyim7byq3agacasc4q25c26wyzfmy8vk2ih6ndj";
  };

  node-grpc-patched = stdenv.mkDerivation {
    name = "node-grpc";
    buildInputs = [ stdenv.cc.cc ];
    nativeBuildInputs = [ autoPatchelfHook ];
    dontUnpack = true;
    # spams console
    dontStrip = true;
    installPhase = ''
      install -D -m755 ${node-grpc-precompiled}/grpc_node.node $out/bin/grpc_node.node
    '';
  };

in
yarn2nix-moretea.mkYarnPackage rec {
  pname = "workadventurepusher";
  version = "unstable";

  src = fetchFromGitHub
    {
      owner = "thecodingmachine";
      repo = "workadventure";
      rev = "284846e8a59ec0d921189ac3a46e0eb5d1e14818";
      sha256 = "1f1vi226kas7x9y8zw810q5vg1ikn4bb6ha9vnzvqk9y7jlc1n8q";
    } + "/pusher";

  # NOTE: this is optional and generated dynamically if omitted
  yarnNix = ./yarn.nix;

  nativeBuildInputs = [ makeWrapper ];

  pkgConfig = {
    grpc = {
      postInstall = ''
        install -D -m755 ${node-grpc-patched}/bin/grpc_node.node src/node/extension_binary/node-v${node-abi}-linux-x64-glibc/grpc_node.node
      '';
    };
  };

  dontStrip = true;

  buildPhase = ''
    mkdir -p $out
    ln -s ${workadventure.messages.outPath}/generated deps/workadventureback/src/Messages/generated
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
