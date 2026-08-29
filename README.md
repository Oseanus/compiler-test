# Compiler Test

The purpose of this repository is to have a fun little testbed for building a compiler.
It may progress in several iterations.
There is no formal planning but the idea is to stick to a basic development iteration, like depicted below:

1. Document syntax of a set of features
2. Define the semantics
3. Define unit tests
4. Implement the feature

The documentation may be found [here](doc/compiler.md).

# Requirements

This project uses C++ 20. In the future it may be migrating to a newer version.
Except from this, the project is so far build with NixOS using GCC and CLANG.
The following list shows the dependencies used:

- CMake
- Ninja
- Google Test Suit

# How to build

The project has been built using the Nix Flakes so far.
To enter a development environment enter following command:

```sh
nix develop
```

For other Linux systems or platforms you might need to consult proper documentation.
Note, that [Conan](https://conan.io/) may be a dependency management tool that is system agnostic to a degree.