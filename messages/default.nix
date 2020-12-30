with (import <nixpkgs> {}); let

in yarn2nix-moretea.mkYarnPackage rec {
  pname = "workadventuremessages";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "thecodingmachine";
    repo = "workadventure";
    rev = "284846e8a59ec0d921189ac3a46e0eb5d1e14818";
    sha256 = "1f1vi226kas7x9y8zw810q5vg1ikn4bb6ha9vnzvqk9y7jlc1n8q";
  } + "/messages";

  # packageJSON = src + "/back/package.json";
  # yarnLock = src + "/back/yarn.lock";
  # NOTE: this is optional and generated dynamically if omitted
  yarnNix = ./yarn.nix;

  # pkgConfig = {
  #   grpc = {
  #     postInstall = ''
  #       install -D -m755 ${node-grpc-patched}/bin/grpc_node.node src/node/extension_binary/node-v72-linux-x64-glibc/grpc_node.node
  #    '';
  #   };
  # };

  buildPhase = ''
    mkdir -p $out
    HOME=$TMPDIR yarn --offline proto
    find
  '';
}
