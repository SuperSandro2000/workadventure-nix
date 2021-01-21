{ system ? builtins.currentSystem, nixpkgs ? <nixpkgs> }:

let
  pkgs = import nixpkgs { inherit system; overlays = [ (import ./overlay.nix) ]; };
in {
  inherit pkgs;
  inherit (pkgs) workadventure;
}
