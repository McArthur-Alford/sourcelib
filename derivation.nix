{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
  pname = "sourceLib";
  version = "0.1.0";

  phases = ["unpackPhase" "installPhase"];

  src = pkgs.fetchFromGitHub {
    owner = "mcarthur-alford";
    repo = "sourcelib";
    rev = "main";
    sha256 = "sha256-neykOieVzFds0HrRXelDDLEYrO1S6+FQQk3SOjCqeRQ=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/include
    cp -r $src/components/boards/nucleo-f429zi/Inc/* $out/include/
    cp -r $src/tools/* $out/include/
    # Add more directories as needed
  '';

  # Optionally, set environment variables if needed for development
  passthru = {
    propagatedBuildInputs = with pkgs; [
      gcc-arm-embedded-12
      # Add other dependencies as needed
    ];

    # Example for setting environment variables
    setupHook = pkgs.writeShellScriptBin "setupHook" ''
      export CPATH=\''${CPATH}':$out/include
      # Set other environment variables as needed
    '';
  };

  buildInputs = [ pkgs.makeWrapper ];
}
