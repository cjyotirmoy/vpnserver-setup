#!/bin/bash
clear
##Get current user name
user=$(whoami)
perm=$(sudo -v)
##Check if user has sudo permissions

source installer.sh

echo "$(tput bold) Package installation completed!$(tput sgr 0)"
read -p "Press any key to continue"
clear

##Find the adapter
net_adapter="ens4"
##We need to find someway to let the program return that instead of assigning it manually
sudo ./serversetup.sh $user $net_adapter
mkdir ~/vpnserver-wireguard/client/
echo "You can configure clients by executing client_generate.sh"
