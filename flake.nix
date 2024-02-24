{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true; # Make sure you actually accept this
        };

        customJLink = pkgs.segger-jlink.overrideAttrs (_oldAttrs: rec {
          version = "V794j"; # TODO this doesnt actually work, but does it matter really??? Only time will tell.
        });

        sourceLibRepo = pkgs.fetchFromGitHub {
          owner = "mcarthur-alford";
          repo = "sourcelib";
          rev = "main";
          sha256 = "sha256-neykOieVzFds0HrRXelDDLEYrO1S6+FQQk3SOjCqeRQ=";
        };

        sourceLib = pkgs.symlinkJoin {
          name = "sourcelib";
          paths = [
            sourceLibRepo
            (sourceLibRepo + "/tools")
            (sourceLibRepo + "/components/boards/nucleo-f429zi/Inc")
          ];
        };
      in
      {
        # package this repo so we can use it as a dependency in the devshell
        package.sourceLib = sourceLib;

        # Devshell to allow easy building of everything
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            sourceLib
            gcc-arm-embedded-12
            glibc_multi.dev
            gdb
            newlib
            screen
            python311Packages.pip
            python311Packages.pylink-square
            customJLink # note: reason for Unfree and Insecure
            clang-tools
            bear
            lldb_17
          ];

          shellHook = ''
            # export PATH="${sourceLib}/tools:${sourceLib}/components/boards/nucleo-f429zi/Inc:$PATH"
          
              echo "Dont forget to run 'sudo usermod -aG dialout $USER', the flake cant do this for you."
          '';
        };
      }
    );
}


