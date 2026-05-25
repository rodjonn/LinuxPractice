#!/bin/bash
# IP Forwarding — enable kernel packet forwarding between interfaces
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Allow NEW connections from clientnet (enp0s9) to servernet (enp0s8) only on port 5000
iptables -A FORWARD -i enp0s9 -o enp0s8 -p tcp --syn --dport 5000 -m conntrack --ctstate NEW -j ACCEPT

# Allow established/related packets in both directions
iptables -A FORWARD -i enp0s9 -o enp0s8 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s9 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Drop everything else in FORWARD chain
iptables -P FORWARD DROP

# NAT: masquerade packets going from clientnet to servernet
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Save rules so they persist after reboot
apt-get install -y iptables-persistent
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo "iptables rules applied and saved."
