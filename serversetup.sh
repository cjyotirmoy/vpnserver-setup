#!/bin/bash
mkdir /home/$user/vpnserver-wireguard/
workdir="/home/$user/vpnserver-wireguard/"
cd $workdir
mkdir server_keys
mkdir config_backups
touch logs
wg genkey | tee server_keys/server_private_key | wg pubkey > server_keys/server_public_key
server_private_key=$(cat server_keys/server_private_key)
touch /etc/wireguard/wg0.conf
echo "$(tput bold)Generating server interface configurations... $(tput sgr 0)"
echo "[Interface]
Address = 10.200.200.1/24
SaveConfig = true
PrivateKey = $server_private_key
ListenPort = 51820" > /etc/wireguard/wg0.conf 
chown -v root:root /etc/wireguard/wg0.conf >> logs
chmod -v 600 /etc/wireguard/wg0.conf >> logs
wg-quick up wg0 >> logs
##Setting wireguard service to automatically turn on whenever server is restarted
systemctl enable wg-quick@wg0.service >> logs
cp /etc/sysctl.conf config_backups/sysctl.conf >> logs

##Enabling ip forwaring rules
cat >> /etc/sysctl.conf<<EOF
##Configurations by wireguard-vpnserver-script
net.ipv4.ip_forward=1
EOF

##Configuring firewall rules
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT >> logs
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT >> logs
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT >> logs

##NAT rules
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o $enet_adapter -j MASQUERADE >> logs

##persistant ip settings after reboot
apt install iptables-persistent
systemctl enable netfilter-persistent
netfilter-persistent save

##Initialising client list as 0
mkdir $workdir/client
mkdir $workdir/client/client_keys
cd $workdir/client
touch client_qty
echo 0 > client_qty

echo "$(tput bold) Server configured $(tput sgr 0)"
