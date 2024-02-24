{ pkgs, modulesPath, lib, config, ... }: {
  imports = [
    "${modulesPath}/virtualisation/azure-image.nix"
  ];

  system.build.azureImage = lib.mkOverride 99
    (import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit pkgs lib config;
      partitionTableType = "efi";
      postVM = ''
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $diskImage $out/nixos.vhd
        rm $diskImage
      '';
      diskSize = config.virtualisation.azureImage.diskSize;
      format = "raw";
    });
}
