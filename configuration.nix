{username}: {
  _class,
  config,
  lib,
  modulesPath,
  options,
  pkgs,
  specialArgs,
}: {
  imports = [
    "${modulesPath}/virtualisation/azure-image.nix"
  ];

  image.fileName = "nixos.vhd";
  virtualisation.azureImage.vmGeneration = "v2";
  virtualisation.diskSize = 32000;

  system.stateVersion = "25.05";
  i18n.defaultLocale = "en_US.UTF-8";

  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  users.users."${username}" = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [(builtins.readFile ~/.ssh/id_ed25519.pub)];
    shell = pkgs.zsh;
  };

  nix.settings = {
    warn-dirty = false;
    experimental-features = ["nix-command" "flakes"];
    trusted-users = [username];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  environment.systemPackages = with pkgs; [
    curl
    ghostty
    git
    vim
  ];

  programs.zsh.enable = true;
}
