#!/usr/bin/env sh
sudo cp ${BASEDIR}/nftables/inet-filter.nft /etc/nftables
sudo chmod +x /etc/nftables/inet-filter.nft
sudo sed -i 's|# include "/etc/nftables/inet-filter.nft"|include "/etc/nftables/inet-filter.nft"|g' /etc/sysconfig/nftables.conf
sudo systemctl enable --now nftables
