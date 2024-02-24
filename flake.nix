{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sourcelib = {
      url = "github:mcarthur-alford/sourcelib";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, sourcelib, ... }:
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
      in
      {
        # Devshell to allow easy building of everything
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
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
              export SOURCELIB_ROOT="${sourcelib}"
              export PATH="$SOURCELIB_ROOT/tools:$SOURCELIB_ROOT/components/boards/nucleo-f429zi/Inc:$PATH"
              echo "SOURCELIB_ROOT set to $\{SOURCELIB_ROOT}"
              echo "Dont forget to run 'sudo usermod -aG dialout $USER', the flake cant do this for you."
          '';
        };
      }
    );
}


