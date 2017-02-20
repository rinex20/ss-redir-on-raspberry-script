# raspberry pi ss-redir  all-in-one script
## consist of shadowsocks-libev, dnsmasq, isc-dhcp-server,iptables(return the chinese ips)
## require raspbian
1. connect your raspberry pi to Internet
2. get and run this script
3. have fun

##connect your raspberry pi to Internet
after you burnt raspbian in flash card, create a file named 'ssh' without content, 
insert your flash card into the raspberry pi
connect your pi to a wireless router with ethernet port
power on your pi, the pi will get a dhcp address
remote login your pi, find the ip of pi , ssh pi@your-pi-ip ,default pwd: rashpberry

##get this script
wget https://raw.githubusercontent.com/95uxin/ss-redir-on-raspberry-script/master/rashpi_ss-redir.sh

run as root
# bash rashpi_ss-redir.sh
