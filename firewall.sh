#!/bin/sh



EXTERNAL_IF=ens18
EXTERNAL_IP=10.100.0.153
EXTERNAL_SUBNET=10.100.0.0/24

INTERNAL_IF=ens19
INTERNAL_IP=192.168.5.1
INTERNAL_SUBNET=192.168.5.0/24

DNS_IP=192.168.5.3
WEBSERVER_IP=192.168.5.2
MAILSERVER_IP=192.168.5.4
# Empty all rules
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X


# PAT Overloading
sudo iptables -t nat -A POSTROUTING ! -d $INTERNAL_SUBNET -o $EXTERNAL_IF -j SNAT --to-source $EXTERNAL_IP



# Forward port 80 to webserver
sudo iptables -t nat -A PREROUTING -d 10.100.0.153 -p tcp --dport 80 -j DNAT --to-destination $WEBSERVER_IP:80
sudo iptables -t nat -A PREROUTING -d 10.100.0.153 -p tcp --dport 25 -j DNAT --to-destination $MAILSERVER_IP:25
sudo iptables -t nat -A PREROUTING -d 10.100.0.153 -p tcp --dport 143 -j DNAT --to-destination $MAILSERVER_IP:143


# Block everything by default
sudo iptables -t filter -P INPUT DROP
sudo iptables -t filter -P FORWARD DROP
sudo iptables -t filter -P OUTPUT DROP

# Allow loopback traffic
sudo iptables -t filter -A INPUT -i lo -j ACCEPT
sudo iptables -t filter -A OUTPUT -o lo -j ACCEPT



# SSH
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --sport 22 --j ACCEPT


# Authorize already established connections
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT




# ICMP
sudo iptables -t filter -A INPUT -p icmp -j ACCEPT
sudo iptables -t filter -A FORWARD -p icmp -j ACCEPT
sudo iptables -t filter -A OUTPUT -p icmp -j ACCEPT


# DNS
sudo iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -t filter -A FORWARD -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A FORWARD -p udp --dport 53 -j ACCEPT


# HTTP
sudo iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -t filter -A FORWARD -p tcp --dport 80 -j ACCEPT



# HTTPS
sudo iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -t filter -A FORWARD -p tcp --dport 443 -j ACCEPT

# SMPT/IMAP
sudo iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
sudo iptables -t filter -A FORWARD -p tcp --dport 25 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
sudo iptables -t filter -A FORWARD -p tcp --dport 143 -j ACCEPT
