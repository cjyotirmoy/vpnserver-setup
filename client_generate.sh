##Generating client keys
cd ~/client
mkdir client_keys
client=$(cat client_list)
client=$((client+1))
mkdir $client
cd $client
client_private_key=$(wg genkey)
client_public_key=$(echo $client_private_key | wg pubkey)
peer=$((client+1))
sudo wg set wg0 peer $client_public_key allowed-ips 10.200.200.$peer/32 
 server_public_key=$(cat ~/server_keys/server_public_key)
##Generating client configs
echo "[Interface]
Address = 10.200.200.1/24
PrivateKey = $client_private_key
DNS = 10.200.200.1" > wg0-client-$client.conf

echo "Enter Server's external IP address: "
    read server_ip

echo "
[Peer]
PublicKey = $server_public_key
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21" >> wg0-client-$client.conf

echo "Client configuration file generated in ~/client/wg0-client-$client.conf"
