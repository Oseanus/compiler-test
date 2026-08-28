{
  description = "CMake development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Build system
              cmake
              ninja
              pkg-config

              # Compiler
              gcc
              clang

              # Debugger
              gdb
              lldb

              # Dependency manager
#              conan

              # Analyzing tools
              valgrind
              rr

              # LLVM tools
              clang-tools
              llvm

              # Miscellaneous
              bear
              ccache
            ];

            shellHook = ''
              export CC=gcc
              export CXX=g++

              echo "CMake Development Environment"
              echo "GCC   : $(gcc --version | head -n1)"
              echo "Clang : $(clang --version | head -n1)"
            '';
          };
        });
    };
}
