{ pkgs, ... }:

{
  imports = [ ../../modules ];

  environment.systemPackages = import ../../modules/packages.nix pkgs;

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.computerName = "Majula";
  networking.hostName = "Majula";
  system.defaults.smb.NetBIOSName = "Majula";

  users.users.lou = {
    name = "lou";
    home = "/Users/lou";
  };

  system.primaryUser = "lou";
}
