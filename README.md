# NixOS on Azure
Run NixOS on an Azure Gen 2 VM

---

## Preparation

1. Set your username in the `flake.nix` file
2. `nix develop`
3. run `az login` and login with your Azure credentials
4. Create an ed25519 SSH key pair

## Upload image and boot NixOS VM

```sh
./upload-image.sh --resource-group images --image-name nixos-gen2
```
## Create VM

```sh
./boot-vm.sh --resource-group vms --image nixos-gen2 --vm-name nixos
```

## SSH into server

```sh
ssh <username>@<public_ip>
```

>
> - username you have set in the `flake.nix` file
> - public IP will be printed with running the `boot-vm.sh` script

---

```
> neofetch
          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖            rudesome@nixos
          ▜███▙       ▜███▙  ▟███▛            --------------
           ▜███▙       ▜███▙▟███▛             OS: NixOS 25.11pre-git (Xantusia) x86_64
            ▜███▙       ▜██████▛              Host: Microsoft Corporation Virtual Machine
     ▟█████████████████▙ ▜████▛     ▟▙        Kernel: 6.12.30
    ▟███████████████████▙ ▜███▙    ▟██▙       Uptime: 1 min
           ▄▄▄▄▖           ▜███▙  ▟███▛       Packages: 348 (nix-system), 330 (nix-user)
          ▟███▛             ▜██▛ ▟███▛        Shell: zsh 5.9
         ▟███▛               ▜▛ ▟███▛         Resolution: 1024x768
▟███████████▛                  ▟██████████▙   Terminal: /dev/pts/0
▜██████████▛                  ▟███████████▛   CPU: Intel Xeon Platinum 8272CL (1) @ 2.593GHz
      ▟███▛ ▟▙               ▟███▛            Memory: 629MiB / 3415MiB
     ▟███▛ ▟██▙             ▟███▛
    ▟███▛  ▜███▙           ▝▀▀▀▀
    ▜██▛    ▜███▙ ▜██████████████████▛
     ▜▛     ▟████▙ ▜████████████████▛
           ▟██████▙       ▜███▙
          ▟███▛▜███▙       ▜███▙
         ▟███▛  ▜███▙       ▜███▙
         ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘
```

# Credits

### [Society for the Blind](https://github.com/society-for-the-blind/nixos-azure-deploy)
### [Plommonsorbet](https://github.com/Plommonsorbet/nixos-azure-gen-2-vm-example)
