#!/bin/bash

##
# created by bastelfreak
# based on a script by Bluewind
##

config_build='config_build.sh'

if [ -n "$config_build" ] && [ -e "$config_build" ]; then
  . $config_build.sh
else
  echo "Error: ${config_build} file isn't available"
  exit 1
fi

# we need to place the set under the exit
# it would ignore it because it's in an if/fi statement
set -e
umask 022

# copy the config because we need it later during build inside of the ISO
cp "$config_build" airootfs/root/

mkdir -p airootfs/usr/local/bin/
rsync -a ext_scripts/ scripts/ airootfs/usr/local/bin/

# clean builddir, build the ISO, clean it again
rm -rf work
./build.sh -v
rm -rf work

# determine the name of the latest ISO
unset -v latest
for file in out/archlinux-*.iso; do
	[[ $file -nt $latest ]] && latest=$file
done

# copy and extract the ISO
rsync -tP "$latest" -e ssh "${DHCP_USER}@${DHCP_SERVER}:${DHCP_PATH}"
ssh "${DHCP_USER}@${DHCP_SERVER}" "${DHCP_EXTRACT} ${DHCP_PATH}${latest##*/}"
