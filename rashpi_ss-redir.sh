#!/bin/sh
#succeeded on raspbian 8.7 2017-1-11
#only one network interface

SERVER_ADDRESS=''
SERVER_PORT=''
SERVER_PWD=''
LOCAL_PORT=''
ENCRYPT_METHOD=''

NET_IF='eth0'


install_softwares() {
sh -c 'printf "deb http://httpredir.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list'
apt update -y
apt install  shadowsocks-libev
apt install -y apg dnsmasq isc-dhcp-server
}

config_sysctl() {
#configure sysctl.conf
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 1
EOF

sysctl -p
}

config_interface() {
cat >> /etc/dhcpcd.conf <<EOF
interface $NET_IF
static ip_address=192.168.1.2/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.2
EOF
}

setup_dnsmasq() {
#configure dnsmasq.conf
cat >> /etc/dnsmasq.conf <<EOF
server=208.67.220.220#5353
server=208.67.222.222#5353
server=208.67.220.220#443
server=208.67.222.222#443
no-resolv
conf-dir=/etc/dnsmasq.d/,*.conf
EOF


#add configs in dnsmasq.d
wget -O /etc/dnsmasq.d/accelerated-domains.china.conf --no-check-certificate https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
wget -O /etc/dnsmasq.d/bogus-nxdomain.china.conf --no-check-certificate https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/bogus-nxdomain.china.conf

}

setup_dhcp() {
#configure interface #only a interface
cat > /etc/default/isc-dhcp-server <<EOF
INTERFACES='$NET_IF'
EOF
#configure subnet
cat >> /etc/dhcp/dhcpd.conf <<EOF
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.60 192.168.1.240;
    default-lease-time 86400;
    max-lease-time 86400;
    option routers 192.168.1.2;
    option ip-forwarding off;
    option broadcast-address 192.168.1.255;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 192.168.1.2;
}
EOF
}

setup_iptables() {
#add iptables
iptables -t nat -N SHADOWSOCKS

iptables -t nat -A POSTROUTING -j SNAT --to-source 192.168.1.2
iptables -t nat -A SHADOWSOCKS -d $SERVER_ADDRESS -j RETURN

iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

iptables -t nat -A SHADOWSOCKS -d 8.8.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/254.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 14.0.0.0/255.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 14.0.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 14.0.12.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 14.1.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 14.192.60.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 14.192.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.0.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.50.40.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.98.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.98.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.99.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.102.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.106.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.106.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.109.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.112.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.112.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.113.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.115.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.116.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.121.64.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.121.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.128.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.131.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.144.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.160.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.192.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 27.224.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 36.0.0.0/255.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 39.0.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 39.64.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 39.128.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 42.0.0.0/255.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.0.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.128.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.140.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.152.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.208.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.216.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.232.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.239.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.239.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 49.244.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 54.222.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.14.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.16.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.32.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.65.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.66.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.68.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.82.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.87.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.99.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.100.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.116.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.128.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.144.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.154.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 58.192.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.0.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.151.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.154.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.172.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.191.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.191.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 59.192.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 60.0.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 60.48.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 60.63.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 60.160.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 60.192.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.4.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.4.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.8.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.28.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.45.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.45.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.47.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.48.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.87.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.128.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.232.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.236.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 61.240.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 91.234.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.0.0.0/255.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.0.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.1.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.50.56.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.53.100.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.55.224.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 101.110.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.1.8.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.1.20.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.1.24.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.1.72.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.1.80.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.1.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.2.104.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.2.144.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.2.164.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.2.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.3.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.3.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.4.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.4.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.5.32.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.5.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.5.252.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.6.72.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.6.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.7.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.7.24.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.7.212.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.7.216.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.52.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.200.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.8.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.9.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.9.248.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.10.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.10.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.10.80.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.10.110.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.10.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.11.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.12.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.12.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.12.136.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.12.184.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.12.232.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.13.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.13.144.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.13.196.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.13.240.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.14.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.14.112.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.14.128.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.14.156.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.14.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.15.4.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.15.8.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.15.16.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.15.96.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.15.200.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.16.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.16.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.17.40.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.17.120.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.17.160.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.17.200.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.17.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.18.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.18.224.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.19.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.19.40.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.19.64.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.19.232.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.20.12.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.20.32.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.20.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.20.128.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.20.160.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.20.248.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.21.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.21.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.21.208.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.21.240.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.22.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.22.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.22.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.23.8.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.23.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.23.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.23.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.128.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.144.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.220.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.228.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.24.240.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.25.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.25.64.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.25.148.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.25.152.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.25.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.26.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.26.64.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.26.156.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.26.160.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.26.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.27.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.27.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.27.96.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.27.176.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.27.208.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.27.240.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.28.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.28.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.29.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.29.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.29.136.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.30.20.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.30.96.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.30.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.30.200.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.30.216.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.30.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.64.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.72.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.144.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.160.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.31.200.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.16.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.32.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.72.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.84.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.124.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.152.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.160.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.240.240.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.72.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.88.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.96.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.160.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.241.216.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.242.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.242.64.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.242.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.242.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.242.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.242.240.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.243.24.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.243.136.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.243.248.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.16.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.56.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.64.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.80.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.144.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.232.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.244.240.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.245.20.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.245.48.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.245.60.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.245.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.245.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.246.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.246.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.246.128.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.246.152.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.247.168.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.247.176.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.247.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.64.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.96.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.152.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.160.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.192.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.208.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.248.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.249.12.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.249.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.249.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.249.192.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.249.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.250.32.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.250.104.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.250.124.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.250.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.250.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.32.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.80.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.96.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.120.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.160.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.200.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.251.240.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.252.24.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.252.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.252.64.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.252.96.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 103.252.168.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 106.0.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 106.192.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 110.0.0.0/254.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 110.93.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 110.232.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.66.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.67.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.68.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.91.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.235.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.235.156.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 111.235.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 112.0.0.0/248.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 112.137.48.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 113.52.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 114.198.240.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 115.124.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 115.166.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 116.66.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 116.89.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 116.90.80.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 116.90.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 116.95.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 117.104.160.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 118.102.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 118.102.32.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 119.63.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 119.82.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 119.232.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 119.235.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 120.0.0.0/252.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 120.88.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 120.136.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 120.137.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 121.0.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 121.100.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 121.101.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 121.101.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 121.200.192.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.102.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.102.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.128.120.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.200.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.201.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.248.24.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.248.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 122.255.64.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 123.108.128.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 123.108.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.0.0.0/255.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.40.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.40.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.42.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.47.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.108.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.108.40.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.109.96.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 124.147.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.31.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.32.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.58.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.60.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.62.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.64.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.168.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.171.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.208.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 125.254.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 134.196.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.0.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.128.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.148.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.155.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.156.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.170.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.176.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.183.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.186.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.188.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.192.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.224.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 139.226.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.75.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.143.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.205.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.206.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.210.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.224.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.237.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.240.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.243.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.246.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.249.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.250.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 140.255.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 144.0.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 144.6.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 144.12.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 144.52.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 144.122.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 144.255.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.0.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.115.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.121.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.122.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.138.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.223.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 150.254.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.0.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.3.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.34.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.36.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.96.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.100.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 153.118.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.0.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.18.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.61.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.122.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.148.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.156.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 157.255.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 159.226.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 161.207.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 162.105.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 163.0.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 163.125.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 163.142.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 163.177.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 163.178.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 163.204.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 166.110.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 167.139.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 168.160.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 171.8.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 171.32.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 171.80.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 171.96.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 171.208.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 175.0.0.0/255.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 175.102.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 175.106.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.64.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.128.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.148.16.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.148.152.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.148.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.148.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.149.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.150.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.189.144.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.200.252.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.201.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.202.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.208.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.210.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.212.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.222.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.223.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.233.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.233.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 180.235.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 182.0.0.0/254.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 182.23.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 182.23.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 182.160.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 182.174.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 183.78.176.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 183.182.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.124.154.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.188.168.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.0.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.0.176.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.3.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.4.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.4.252.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.6.4.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.6.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.6.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.8.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.8.24.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.8.64.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.8.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.8.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.9.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.10.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.12.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.12.16.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.12.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.14.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.20.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.20.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.21.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.22.248.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.27.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.36.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.15.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.135.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.136.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.140.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.143.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.144.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.150.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.155.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.156.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.158.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.40.162.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.41.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.43.72.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.43.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.44.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.45.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.45.15.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.45.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.46.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.47.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.47.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.57.240.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.58.0.0/255.255.255.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.59.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.59.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.59.232.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.59.236.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.60.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.60.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.60.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.62.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.62.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.63.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.63.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.63.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.65.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.67.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.69.4.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.69.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.70.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.70.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.72.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.72.80.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.73.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.74.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.74.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.74.254.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.75.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.75.240.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.76.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.77.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.78.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.79.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.79.248.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.80.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.81.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.83.248.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.84.4.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.84.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.84.24.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.85.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.86.248.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.87.80.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.89.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.90.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.90.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.90.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.90.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.91.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.91.96.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.91.128.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.91.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.91.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.92.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.92.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.93.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.93.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.94.92.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.95.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.95.240.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.95.252.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.96.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.112.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.120.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.122.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.122.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.122.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.122.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.122.128.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.123.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.124.16.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.124.24.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.125.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.125.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.127.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.130.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.130.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.131.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.131.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.131.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.133.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.134.56.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.134.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.136.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.137.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.141.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.142.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.143.4.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.143.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.143.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.146.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.146.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.147.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.148.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.152.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.153.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.153.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.157.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.158.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.160.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.162.64.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.164.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.164.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.165.96.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.165.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.165.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.166.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.168.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.170.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.170.216.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.170.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.171.216.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.171.232.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.172.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.173.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.173.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.173.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.174.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.176.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.179.240.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.180.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.180.208.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.181.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.182.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.182.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.189.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.189.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.189.184.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.191.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.191.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 202.192.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.0.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.76.160.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.76.168.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.77.176.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.78.48.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.79.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.79.32.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.80.4.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.80.32.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.80.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.81.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.81.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.82.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.82.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.83.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.83.224.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.86.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.86.254.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.88.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.99.8.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.99.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.99.80.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.100.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.100.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.104.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.105.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.105.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.106.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.110.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.110.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.110.232.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.114.240.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.116.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.128.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.129.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.130.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.132.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.134.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.135.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.135.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.142.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.144.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.145.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.148.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.148.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.149.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.152.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.152.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.153.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.156.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.160.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.160.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.161.0.0/255.255.252.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.161.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.161.192.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.166.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.168.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.170.56.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.171.0.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.171.224.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.174.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.174.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.175.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.176.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.176.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.176.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.184.64.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.187.160.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.189.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.189.112.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.189.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.190.96.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.190.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.191.0.0/255.255.254.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.191.16.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.191.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.191.144.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.192.0.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.193.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.194.96.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.195.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.196.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.202.232.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.204.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.208.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.209.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.212.0.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.212.64.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.215.232.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.222.192.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.223.0.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 203.223.16.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.0.0.0/255.192.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.2.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.5.0.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.5.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.56.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.64.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.82.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.87.128.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.185.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 210.192.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 211.64.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 211.96.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 211.128.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 218.0.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 218.185.192.0/255.255.192.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 218.192.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 218.240.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 218.248.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 219.72.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 219.80.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 219.128.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 219.216.0.0/255.248.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 219.224.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.101.0.0/255.255.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.112.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.152.128.0/255.255.128.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.154.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.160.0.0/255.224.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.192.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.224.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.242.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.247.128.0/255.255.224.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.248.0.0/255.252.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 220.252.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 221.0.0.0/255.240.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 221.122.0.0/255.254.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 221.128.0.0/255.128.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 222.0.0.0/254.0.0.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 223.27.184.0/255.255.248.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 223.223.176.0/255.255.240.0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 223.223.192.0/255.255.240.0 -j RETURN

iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports $LOCAL_PORT

iptables -t nat -A PREROUTING  -p tcp -j SHADOWSOCKS
#store iptables
iptables-save > /etc/iptables.rules

#auto start
cat > /etc/network/if-pre-up.d/iptablesload <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.rules
exit 0
EOF

chmod +x /etc/network/if-pre-up.d/iptablesload
}

enable_ss-redir_service() {

#create config file
cat > /etc/ss-redir.json <<EOF
{
    "server":"$SERVER_ADDRESS",
    "server_port":$SERVER_PORT,
    "local_address":"0.0.0.0",
    "local_port":$LOCAL_PORT,
    "password":"$SERVER_PWD",
    "method":"$ENCRYPT_METHOD",
    "timeout":30
}
EOF


#create service file
cat >> /etc/systemd/system/ss-redir.service <<EOF
#  This file is part of shadowsocks-libev.
#
#  Shadowsocks-libev is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This file is default for Debian packaging. See also
#  /etc/default/shadowsocks-libev for environment variables.

[Unit]
Description=Shadowsocks-libev Default Server Service
Documentation=man:shadowsocks-libev(8)
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/default/shadowsocks-libev
User=root
#LimitNOFILE=32768
ExecStart=/usr/bin/ss-redir -u -c /etc/ss-redir.json

[Install]
WantedBy=multi-user.target

EOF

#disable built-in service
#enable
systemctl enable ss-redir
}

enable_services() {
#enable and start ss-redir isc-dhcp-server ss-redir dnsmasq
enable_ss-redir_service
systemctl enable isc-dhcp-server dnsmasq
systemctl restart isc-dhcp-server dnsmasq ss-redir

cat > /etc/rc.local <<EOF
#!/bin/sh
systemctl restart dnsmasq
exit 0
EOF

}

install_softwares
config_sysctl
config_interface
setup_dnsmasq
setup_dhcp
setup_iptables
setup_ss-redir
enable_services

cat << EOF
##################################
## You Will Never See this! ###
##################################
EOF


