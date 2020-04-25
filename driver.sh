#!/bin/bash
clear
##Get current user name
user=$(whoami)
##Check if user has sudo permissions
if [[ -nz $(sudo -v) ]]
    then
    echo "User does not have sudo permissions, exitting..."
    exit
fi
source installer.sh

echo "$(tput bold) Package installation completed!$(tput sgr 0)"
read -p "Press any key to continue"
clear

##Find the adapter
net_adapter=ens4
##We need to find someway to let the program return that instead of assigning it manually
source serversetup.sh

echo "You can configure clients by executing client_generate.sh"
