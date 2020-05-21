#!/bin/bash

distro=$(cat /etc/os-release | grep -w "ID=*" | sed "s/ID=//")
version=$(cat /etc/os-release | grep -w "VERSION_ID=*" | sed "s/VERSION_ID=//" |sed  "s/\"//g" | sed "s/\.//g")
type=$(cat /etc/os-release | grep -w "ID_LIKE=*" | sed "s/ID_LIKE=//")
if [[ "$type" == "debian" ]]
then
        echo "Your distro details: "
        echo "ID_LIKE=$type"
        if [[ "$distro" == "ubuntu" ]]
        then
            echo "ID=$distro"
            if [[ $version -ge "1910" ]]
            then
                echo "Version=19.10"
                flag=1
            else 
                echo "Version is older than 19.10"
                flag=2
            fi
        else
            echo "ID=$distro"
            flag=3
        fi
else
    flag=4
    echo ""
    echo "sorry we don't support your distro: $distro"
    echo "If you would like to contribute for testing for your distro, contact us" 
    exit
fi

if [[ $flag -eq 1 ]]
##Installing the wireguard package
then
    echo "Installing packages: "
    sudo apt -y install wireguard
elif [[ $flag -eq 2 ]]
then
    echo "Adding repository: "
    sudo apt -y install software-properties-common
    sudo add-apt-repository ppa:wireguard/wireguard
    echo "$(tput bold)Updating packages: $(tput sgr 0)"
    sudo apt-get update
    echo "Installing wireguard: "
    sudo apt-get -y install wireguard
elif [[ $flag -eq 3 ]]
then
    echo "Installing packages:"
    sudo apt -y install wireguard 
fi
sudo apt install dnsutils iptables
echo "$(tput bold) Packages installed in server. Proceeding with configuration $(tput sgr 0)"
