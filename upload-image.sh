#!/usr/bin/env bash


####################################################
# AZ LOGIN CHECK                                   #
####################################################

# Making  sure  that  one   is  logged  in  (to  avoid
# surprises down the line).
if [ $(az account list | jq -r 'length') -eq 0 ]
then
  echo
  echo '********************************************************'
  echo '* Please log  in to  Azure by  typing "az  login", and *'
  echo '* repeat the "./upload-image.sh" command.              *'
  echo '********************************************************'
  exit 1
fi

####################################################
# HELPERS                                          #
####################################################

show_id() {
  az $1 show \
    --resource-group "${resource_group}" \
    --name "${img_name}"        \
    --query "[id]"              \
    --output tsv
}

usage() {
  echo ''
  echo 'USAGE: (Every switch requires an argument)'
  echo ''
  echo '-g --resource-group REQUIRED Created if does  not exist. Will'
  echo '                             house a new disk and the created'
  echo '                             image.'
  echo ''
  echo '-n --image-name     REQUIRED The  name of  the image  created'
  echo '                             (and also of the new disk).'
  echo ''
  echo '-l --location       Values from `az account list-locations`.'
  echo '                    Default value: "westus2".'
}

####################################################
# SWITCHES                                         #
####################################################

# https://unix.stackexchange.com/a/204927/85131
while [ $# -gt 0 ]; do
  case "$1" in
    -l|--location)
      location="$2"
      ;;
    -g|--resource-group)
      resource_group="$2"
      ;;
    -n|--image-name)
      img_name="$2"
      ;;
    -h|--help)
      usage
      exit 1
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument *\n"
      printf "***************************\n"
      usage
      exit 1
  esac
  shift
  shift
done

if [ -z "${img_name}" ] || [ -z "${resource_group}" ]
then
  printf "************************************\n"
  printf "* Error: Missing required argument *\n"
  printf "************************************\n"
  usage
  exit 1
fi

####################################################
# DEFAULTS                                         #
####################################################

location_d="${location:-"westeurope"}"

####################################################
# PUT IMAGE INTO AZURE CLOUD                       #
####################################################

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail
set -x

# build image and set img file
# we set impure cause of the ssh key file
nix build --out-link "azure" .#azure-image --impure
img_file="$(readlink -f ./azure/nixos.vhd)"

# Make resource group exists
if ! az group show --resource-group "${resource_group}" &>/dev/null
then
  az group create     \
    --name "${resource_group}" \
    --location "${location_d}"
fi

# note: the disk access token song/dance is tedious
# but allows us to upload direct to a disk image
# thereby avoid storage accounts (and naming them) entirely!
if ! az disk show -g "${resource_group}" -n "${img_name}" &>/dev/null; then
  bytes="$(stat -c %s ${img_file})"
  size="30"
  az disk create \
    --resource-group "${resource_group}" \
    --name "${img_name}" \
    --hyper-v-generation V2 \
    --upload-type Upload --upload-size-bytes "${bytes}"

  timeout=$(( 60 * 60 )) # disk access token timeout
  sasurl="$(\
    az disk grant-access \
      --access-level Write \
      --resource-group "${resource_group}" \
      --name "${img_name}" \
      --duration-in-seconds ${timeout} \
        | jq -r '.accessSas'
  )"

  azcopy copy "${img_file}" "${sasurl}" \
    --blob-type PageBlob

  az disk revoke-access \
    --resource-group "${resource_group}" \
    --name "${img_name}"
fi

if ! az image show -g "${resource_group}" -n "${img_name}" &>/dev/null; then
  diskid="$(az disk show -g "${resource_group}" -n "${img_name}" -o json | jq -r .id)"

  az image create \
    --resource-group "${resource_group}" \
    --name "${img_name}" \
    --source "${diskid}" \
    --hyper-v-generation V2 \
    --os-type "linux" >/dev/null
fi

imageid="$(az image show -g "${resource_group}" -n "${img_name}" -o json | jq -r .id)"
echo "image creation completed:"
echo "image_id: ${imageid}"

# delete the nix build link
rm -fr ./azure
