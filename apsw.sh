#!/bin/bash

ssid="VSWITCH"
pass="12345678"

if [[ -n "$1" ]]; then
    ssid=$1
fi

if [[ -n "$2" ]]; then
    pass=$2
fi

sudo ifconfig br0 down
sudo brctl delbr br0
sudo brctl addbr br0

sudo echo "
interface=wlp2s0
bridge=br0
driver=nl80211
auth_algs=1
ignore_broadcast_ssid=0
logger_syslog=-1
logger_syslog_level=0
hw_mode=g
ssid=$ssid
channel=11
macaddr_acl=0
wpa=2
wpa_passphrase=$pass
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" >> ./hostapd.conf

sudo mv ./hostapd.conf /etc/hostapd/hostapd.conf

sudo echo "
iface lo inet loopback

pre-up ip addr flush dev wlp2s0


auto br0
  iface br0 inet dhcp
  bridge-ports enp1s0 wlp2s0

auto enp1s0
  allow-hotplug enp1s0
  iface enp1s0 inet dhcp" >> ./interfaces

sudo mv ./interfaces /etc/network/interfaces

sudo systemctl restart hostapd
sudo systemctl restart networking
