    workdir=$(pwd)
    mkdir config_backups
echo "$(tput setab 1) $(tput setaf 7)Determining the eligibility of your distro and install packages with sub-scripts $(tput sgr 0)"
    ./os_find.sh
    cd ~
echo "$(tput setab 1) $(tput setaf 7)Generating server keys $(tput sgr 0)"
    umask 077
    mkdir server_keys
    wg genkey | tee server_keys/server_private_key | wg pubkey > server_keys/server_public_key
    server_private_key=$(cat server_keys/server_private_key)
    server_public_key=$(cat server_keys/server_public_key)
echo "$(tput setab 1) $(tput setaf 7)Generating server Interface configuration $(tput sgr 0)"
    sudo touch /etc/wireguard/wg0.conf
    cd /etc/wireguard/
    sudo echo "[Interface]
    Address = 10.200.200.1/24
    SaveConfig = true
    PrivateKey = $server_private_key
    ListenPort = 51820" > wg0.conf
    cd $workdir
echo "$(tput setab 1) $(tput setaf 7)Enabling wireguard interface on the server $(tput sgr 0)"
    sudo chown -v root:root /etc/wireguard/wg0.conf
    sudo chmod -v 600 /etc/wireguard/wg0.conf
    sudo wg-quick up wg0
    sudo systemctl enable wg-quick@wg0.service
echo "$(tput setab 1) $(tput setaf 7)Enabling ipv4 packet rerouting $(tput sgr 0)"
    cp /etc/sysctl.conf config_backups/sysctl.conf
    sudo sed "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf > /etc/sysctl.conf
    sudo sysctl -p
    sudo echo 1 > /proc/sys/net/ipv4/ip_forward
echo "$(tput setab 1) $(tput setaf 7) Configuring firewall rules ... $(tput sgr 0)"
    ##Tracking VPN Connection
        sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ##Allowing forwarding of packets in VPN tunnel
        sudo iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
    ##Setting up NAT
        echo "$(tput setab 1) $(tput setaf 7)You have the following network adapters, enter the one you want to use for the tunnel: (Default first one) $(tput sgr 0) "
            ip addr show | awk '/inet.*global dynamic/{print $NF}'
            net_adapter=$(ip addr show | awk '/inet.*global dynamic/{print $NF; exit}')
            read net_adapter_user
            if [[ -z "$net_adapter_user" ]]
                then
                    net_adapter_user=$net_adapter
            fi
        sudo iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o $net_adapter_user -j MASQUERADE
    ## Reboot persistant settings
    sudo systemctl enable netfilter-persistent
    sudo netfilter-persistent save

##Setting current client list as 0
    mkdir ~/client
    cd ~/client
    echo 0 > client_list

##Optional DNS Configuration
echo "$(tput setab 1) $(tput setaf 7) Server Setup complete $(tput sgr 0)"
echo "$(tput setab 1) $(tput setaf 7)Generating client keys registering clients on the server. This will essentially return a client configuration file to use on the client when connecting the VPN. $(tput sgr 0)"
    read -p "Press any key to continue"
    