date=$(date +%F)
##Determine external IP address of server
ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
server_ip=$ip
user=$(whoami)
check=$(ls ~/vpnserver-wireguard/client | grep "client_qty")
if [[ -z $check ]]
    then
        echo "$(tput bold) Environment variables within the vpnserver-wireguard directory changed since server setup or last client setup or a different user is executing this. Retrace your steps or contact us for more information! $(tput sgr 0)"
        exit
fi
##Generating client keys
workdir="/home/$user/vpnserver-wireguard/client"
cd $workdir
check2=$(ls | grep "flag")
while  [[ ! -z $check2  ]
  do
    sleep 0.5
  done
touch flag
client=$(cat client_qty)
peer=$((client+1))
echo $peer > client_qty
rm -f flag
client_private_key=$(wg genkey)
client_public_key=$(echo $client_private_key | wg pubkey)
peer=$((client+1))
sudo wg set wg0 peer $client_public_key allowed-ips 10.200.200.$peer/32 
server_public_key=$(cat $workdir/../server_keys/server_public_key)

##Generating client configs
touch wg0-client-$client.conf
echo "[Interface]
Address = 10.200.200.$peer/24
PrivateKey = $client_private_key
DNS = 8.8.8.8" > wg0-client-$client.conf
echo "
[Peer]
PublicKey = $server_public_key
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21" >> wg0-client-$client.conf
mysql -u client_gen -p'password' -D vpn -e "INSERT INTO clients VALUES($client, '$email', '$client_private_key', '0.0.0.0', '$date');"
echo "Client configuration file generated in $workdir/wg0-client-$client.conf"