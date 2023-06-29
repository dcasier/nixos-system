# Build with
#   nix-build -A system -A config.system.build.tarball --show-trace

import <nixpkgs/nixos> {
  configuration = {
    imports = [
      ./module.nix
      ./build-system.nix
      ./configuration.nix
    ];
  };

  system = "x86_64-linux";
}
