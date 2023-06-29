{ config, pkgs, lib, nixpkgs ? <nixpkgs>, ... }:

with lib;
let
  pkgs2storeContents = l: map (x: { object = x; symlink = "none"; }) l;

  ovs = pkgs.callPackage ./network/openvswitch/default.nix { };
  ovn = pkgs.callPackage ./network/ovn/default.nix { };

  nixpkgs = lib.cleanSource pkgs.path;

  channelSources = pkgs.runCommand "nixos-${config.system.nixos.version}"
    { preferLocalBuild = true; }
    ''
      mkdir -p $out
      cp -prd ${nixpkgs.outPath} $out/nixos
      chmod -R u+w $out/nixos
      if [ ! -e $out/nixos/nixpkgs ]; then
        ln -s . $out/nixos/nixpkgs
      fi
      echo -n ${config.system.nixos.version} > $out/nixos/.git-version
      echo -n ${config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
    '';

  prepare = pkgs.writeShellScriptBin "env-prepare" ''
    set -e

    mkdir -m 0755 ./bin ./etc
    mkdir -m 1777 ./tmp


    # Set system profile
    system=${config.system.build.toplevel}
    ./$system/sw/bin/nix-store --store `pwd` --load-db < ./nix-path-registration
    rm ./nix-path-registration
    ./$system/sw/bin/nix-env --store `pwd` -p ./nix/var/nix/profiles/system --set $system

    # Set channel
    mkdir -p ./nix/var/nix/profiles/per-user/root
    ./$system/sw/bin/nix-env --store `pwd` -p ./nix/var/nix/profiles/per-user/root/channels --set ${channelSources}
    mkdir -m 0700 -p ./root/.nix-defexpr
    ln -s /nix/var/nix/profiles/per-user/root/channels ./root/.nix-defexpr/channels

    # It's now a NixOS!
    touch ./etc/NIXOS

    # Copy the system configuration
    mkdir -p ./etc/nixos
  '';
in
{
  config = {
    system.build.tarball = pkgs.callPackage "${nixpkgs}/nixos/lib/make-system-tarball.nix" {
      # No contents, structure will be added by prepare script
      contents = [ ];

      storeContents = pkgs2storeContents [
        config.system.build.toplevel
        pkgs.containerd
        pkgs.stdenv
        channelSources
        ovs
        ovn
        prepare
      ];

      extraCommands = "${prepare}/bin/env-prepare";

      # Use gzip
      compressCommand = "gzip";
      compressionExtension = ".gz";
    };
  };
}
