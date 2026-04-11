{ pkgs, ... }:

{
  imports = [ ../../modules ];

  environment.systemPackages =
    import ../../modules/packages.nix pkgs
    ++ (with pkgs; [
      _1password-cli
      prek
    ]);

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.computerName = "K1QJWD679P";
  networking.hostName = "K1QJWD679P";
  system.defaults.smb.NetBIOSName = "K1QJWD679P";

  users.users."lou.ferrand" = {
    name = "lou.ferrand";
    home = "/Users/lou.ferrand";
  };

  system.primaryUser = "lou.ferrand";
}
