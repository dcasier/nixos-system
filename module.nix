{ lib, pkgs, config, modulesPath, ... }:
with lib;

{
  imports = [ "${modulesPath}/profiles/minimal.nix" ./build-system.nix ];

  config = {
    system.stateVersion = "23.05";
    boot.isContainer = false;
    # cpu-freq
    boot.initrd.enable = false;
    boot.loader.grub.enable = false;
    boot.kernel.enable = false;
    documentation.man.enable = false;

    environment.etc.hosts.enable = false;
    environment.etc."resolv.conf".enable = false;
    hardware.enableAllFirmware = false;
    hardware.enableRedistributableFirmware = false;

    # environment.etc.hosts.enable = false;
    # environment.etc."resolv.conf".enable = false;
    # systemd.services."serial-getty@ttyS0".enable = false;
    # systemd.services."serial-getty@hvc0".enable = false;
    networking.dhcpcd.enable = false;
    networking.firewall.enable = false;
    networking.wireless.enable = false;
    networking.nftables.enable = true;

    # services.timesyncd = !config.boot.isContainer;

    # systemd.services."getty@tty1".enable = false;
    # systemd.services."autovt@".enable = false;
    # systemd.enableEmergencyMode = false;

    systemd.services.firewall.enable = false;
    systemd.services.systemd-resolved.enable = false;
    # systemd.services.systemd-udevd.enable = false;

  };
}
