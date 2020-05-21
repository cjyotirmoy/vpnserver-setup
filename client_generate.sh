##Determine external IP address of server
ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "Your external ip address is: $ip"
read -p "Press any key to continue"
clear
server_ip=$ip
user=$(whoami)
check=$(ls ~/vpnserver-wireguard/ | grep "client_qty")
if [[ -z $check ]]
    then
        echo "$(tput bold) Environment variables within the vpnserver-wireguard directory changed since server setup or last client setup or a different user is executing this. Retrace your steps or contact us for more information! $(tput sgr 0)"
        exit
fi
##Generating client keys
workdir="/home/$user/vpnserver-wireguard/client"
cd $workdir
client=$(cat client_qty)
client_private_key=$(wg genkey)
client_public_key=$(echo $client_private_key | wg pubkey)
peer=$((client+1))
sudo wg set wg0 peer $client_public_key allowed-ips 10.200.200.$peer/32 
server_public_key=$(cat $workdir/../server_keys/server_public_key)

##Generating client configs
touch wg0-client-$peer.conf
echo "[Interface]
Address = 10.200.200.$peer/24
PrivateKey = $client_private_key
DNS = 10.200.200.1" > wg0-client-$client.conf
echo "
[Peer]
PublicKey = $server_public_key
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21" >> wg0-client-$peer.conf
echo $client > $workdir/client_qty
echo "Client configuration file generated in $workdir/wg0-client-$client.conf"