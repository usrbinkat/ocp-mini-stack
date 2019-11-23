#!/bin/bash
ip link add dev wg01 type wireguard
ip addr add dev wg01 10.10.100.1/24
ip link set wg01 up
wg set wg01 listen-port 51820 private-key /root/kingpin01.privkey 
ip a s wg01
wg show wg01
