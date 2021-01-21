self: super:

let
  inherit (self) callPackage;
in {
  workadventure = {
    back = callPackage ./back {};
    pusher = callPackage ./pusher {};
    messages = callPackage ./messages {};
    front = callPackage ./front {};
    uploader = callPackage ./uploader {};
    maps = callPackage ./maps {};
  };
}
