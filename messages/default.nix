with (import <nixpkgs> { }); let
  node-protoc-precompiled = pkgs.fetchzip {
    name = "node-protoc-precompiled";
    url = "https://node-precompiled-binaries.grpc.io/grpc-tools/v1.10.0/linux-x64.tar.gz";
    sha256 = "0dl1anpw3610q58mxf7r9dcp768krwvpa4053cjxn5r8b5xfbh4l";
  };

  node-protoc-patched = pkgs.stdenv.mkDerivation {
    name = "node-protoc";
    buildInputs = [ pkgs.gcc-unwrapped.lib ];
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    dontAutoPatchelf = true;
    dontUnpack = true;
    # protoc: symbol lookup error: /nix/store/...-node-protoc/bin/protoc: undefined symbol: , version
    dontStrip = true;
    installPhase = ''
      install -D -m755 ${node-protoc-precompiled}/grpc_node_plugin $out/bin/grpc_node_plugin
      install -D -m755 ${node-protoc-precompiled}/protoc $out/bin/protoc

      autoPatchelf $out/bin/{grpc_node_plugin,protoc}
      :
    '';
  };

in
yarn2nix-moretea.mkYarnPackage rec {
  pname = "workadventuremessages";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "thecodingmachine";
    repo = "workadventure";
    rev = "284846e8a59ec0d921189ac3a46e0eb5d1e14818";
    sha256 = "1f1vi226kas7x9y8zw810q5vg1ikn4bb6ha9vnzvqk9y7jlc1n8q";
  } + "/messages";

  # NOTE: this is optional and generated dynamically if omitted
  yarnNix = ./yarn.nix;

  pkgConfig = {
    grpc-tools = {
      postInstall = ''
        install -D -m755 ${node-protoc-patched}/bin/grpc_node_plugin bin/grpc_node_plugin
        install -D -m755 ${node-protoc-patched}/bin/protoc bin/protoc
      '';
    };
  };

  dontStrip = true;

  buildPhase = ''
    mkdir -p $out
    HOME=$TMPDIR yarn --offline run proto
  '';

  distPhase = ":";

  installPhase = ''
    cp -r deps/workadventure-messages/generated $out/
    cp -r node_modules $out/
  '';
}
