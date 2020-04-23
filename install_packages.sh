#!/bin/bash
if [[ $flag -eq 1 ]]
##Installing the wireguard package
then
    echo "Installing packages: "
    sudo apt install wireguard
elif [[ $flag -eq 2 ]]
then
    echo "Adding repository: "
    sudo add-apt-repository ppa:wireguard/wireguard
    echp "Updating packages: "
    sudo apt-get update
    echo "Installing wireguard: "
    sudo apt-get install wireguard
elif [[ $flag -eq 3 ]]
then
    echo "Installing packages:"
    sudo apt install wireguard
fi
ip link add dev wg0 type wireguard


