#!/bin/bash
user=$1
net_adapter=$2
mkdir /home/$user/vpnserver-wireguard/
workdir="/home/$user/vpnserver-wireguard"
cd $workdir
mkdir server_keys
mkdir config_backups
touch logs
Umask 077
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
sysctl -p
echo 1 > /proc/sys/net/ipv4/ip_forward
##Configuring firewall rules

#Tracking VPN connection
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT >> logs
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT >> logs

#Allowing incoming VPN traffic on the listening port
iptables -A INPUT -p udp -m udp --dport 51820 -m conntrack --ctstate NEW -j ACCEPT >> logs

##Allowing both TCP and UDP recursive DNS traffic
iptables -A INPUT -s 10.200.200.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT >> logs
iptables -A INPUT -s 10.200.200.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT >> logs

##Allowing 
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT >> logs 

##NAT rules
echo $net_adapter
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o $net_adapter -j MASQUERADE >> logs

##persistant ip settings after reboot
apt install iptables-persistent
systemctl enable --now netfilter-persistent >> logs
netfilter-persistent save

##Initialising client list as 0

touch $workdir/client/client_qty
echo 0 > $wokrdir/client/client_qty
chmod 777 $workdir/client/client_qty
chmod 777 server_keys/server_public_key
##Setting permissions
echo "$(tput bold) Server configured $(tput sgr 0)"
