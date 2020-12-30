with (import <nixpkgs> {}); let

node-grpc-precompiled = pkgs.fetchzip {
  name = "node-grpc-precompiled";
  url = "https://node-precompiled-binaries.grpc.io/grpc/v1.24.4/node-v72-linux-x64-glibc.tar.gz";
  sha256 = "11jknppmmp1lpdid9p3lfw2dfsydri3jn1q55zikank3dfd4lhs0";
};

node-grpc-patched = pkgs.stdenv.mkDerivation {
  name = "node-grpc";
  buildInputs = [ stdenv.cc.cc ];
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  dontUnpack = true;
  installPhase = ''
    install -D -m755 ${node-grpc-precompiled}/grpc_node.node $out/bin/grpc_node.node
  '';
};

in yarn2nix-moretea.mkYarnPackage rec {
  pname = "workadventureback";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "thecodingmachine";
    repo = "workadventure";
    rev = "284846e8a59ec0d921189ac3a46e0eb5d1e14818";
    sha256 = "1f1vi226kas7x9y8zw810q5vg1ikn4bb6ha9vnzvqk9y7jlc1n8q";
  } + "/back";

  # packageJSON = src + "/back/package.json";
  # yarnLock = src + "/back/yarn.lock";
  # NOTE: this is optional and generated dynamically if omitted
  yarnNix = ./yarn.nix;

  nativeBuildInputs = [ makeWrapper ];

  pkgConfig = {
    grpc = {
      postInstall = ''
        install -D -m755 ${node-grpc-patched}/bin/grpc_node.node src/node/extension_binary/node-v72-linux-x64-glibc/grpc_node.node
     '';
    };
  };

  buildPhase = ''
    mkdir -p $out
    pwd
    HOME=$TMPDIR yarn --offline tsc
    cp -r deps/workadventureback/dist $out/dist
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/${pname}" \
      --set NODE_PATH $out/libexec/${pname}/node_modules \
      --add-flags "$out/dist/server.js"
  '';
}
