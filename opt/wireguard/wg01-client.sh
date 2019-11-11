wg set wg01 \
  listen-port 51820 \
  private-key /root/rhev01-wg.privkey \
  peer cxZGijR32N2cMszCUwLe/Z1vfh1HDLuXgcxqej3yul0= \
  endpoint 167.71.155.65:51820 \
  persistent-keepalive 25 \
  allowed-ips 10.10.100.2,10.10.0.0/16,10.10.91.0/24
