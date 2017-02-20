# Shadowsocks-libev Proxy gateway on Raspberry Pi Auto Setup Script

## Table of Contents

# Requirements

* A Raspberry Pi 3

* [Raspbian JESSIE](https://www.raspberrypi.org/downloads/raspbian/)

# Features

# Quick Start

* Download the script

```
# wget https://raw.githubusercontent.com/95uxin/ss-redir-on-raspberry-script/master/rashpi_ss-redir.sh
```

* Edit the script and insert your server info

```
SERVER_ADDRESS='your shadowsocks server ip/Domain'
SERVER_PORT='your ss server port'
SERVER_PWD='your ss server password'
ENCRYPT_METHOD='your ss server encrypt method like aes-256-cfb'
LOCAL_PORT='your ss-redir local port like 1080'
```

* Run as root
```
# bash rashpi_ss-redir.sh
```

* Press 'Y' to confirm software installation manually

* Restart or re-power your Pi when the script finished or lose the remote connection

* **Disable** your wireless router **DHCP** and ensure the router ip is 192.168.1.1

* (optional) restart your wireless router

* Test and Have Fun!

# No monitor Help!

## remote control your Pi

## connect your Pi to Internet
