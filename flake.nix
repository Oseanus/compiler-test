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

	      # Development tools
	      clang-tools
	      clang-analyzer

	      # Testing toold
	      gtest

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
            echo "C++ Development Environment loaded"
            echo ""
            echo "Available compilers:"
            echo "  gcc   : $(gcc --version | head -n1)"
            echo "  clang : $(clang --version | head -n1)"
            echo ""
            echo "Debuggers:"
            echo "  gdb"
            echo "  lldb"
            echo ""
            echo "GoogleTest / GoogleMock available via nixpkgs.googletest"
          '';
          };
        });
    };
}
