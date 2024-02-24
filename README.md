# NixOS on Azure
Run NixOS on an Azure Gen 2 VM

---

## Preparation

1. Set your username in the `flake.nix` file
2. use [direnv](https://github.com/nix-community/nix-direnv) or run `nix develop`
3. run `az login` and login with your Azure credentials
4. Create an RSA SSH key pair (id_rsa) - [ed25519 keys are not supported by Azure](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/ed25519-ssh-keys)

## Upload image

it can take a while to upload the `.vhd` (for me it is +/- 50 min), <br>
if the upload time-out; you may want to change the token duration. <br>
also don't look at the azcopy log file, it spams 500 errors but these can be ignored..

```sh
./upload-image.sh --resource-group images --image-name nixos-gen2
```
## Create VM

```sh
./boot-vm.sh --resource-group vms --image nixos-gen2 --vm-name nixos
```

## Build image (only)

```sh
nix build .#azure-image --impure
```

## SSH into server

```sh
ssh -i ~/.ssh/id_rsa <username>@<public_ip>
```

>
> - username you have set in the `flake.nix` file
> - public IP will be printed with running the `boot-vm.sh` script
