#!/bin/bash

# Set the script name and author
SCRIPT_NAME="Rsae63's Clean IP Finder"
AUTHOR="Rsae63"

# Function to check if an IP is clean
check_ip_clean() {
  IP=$1
  RESPONSE=$(curl -s -m 10 "https://ipapi.co/${IP}/json")
  if echo "$RESPONSE" | grep -q '"asn":'; then
    echo "IP ${IP} is clean"
  else
    echo "IP ${IP} is not clean"
  fi
}

# Function to configure WireGuard
configure_wireguard() {
  IP=$1
  PORT=51820
  PRIVATE_KEY=$(wg genkey)
  PUBLIC_KEY=$(wg pubkey <<< "$PRIVATE_KEY")
  echo "[Interface]
  Address = ${IP}/24
  ListenPort = ${PORT}
  PrivateKey = ${PRIVATE_KEY}

[Peer]
  PublicKey = ${PUBLIC_KEY}
  Endpoint = ${IP}:${PORT}
  AllowedIPs = 0.0.0.0/0,::/0" > wireguard.conf
}

# Main script
echo "Welcome to ${SCRIPT_NAME} by ${AUTHOR}"

# Ask user for input
read -p "Enter the number of IP addresses to scan: " NUM_IPS

# Scan for clean IP addresses
for ((i=0; i<NUM_IPS; i++)); do
  IP=$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1)
  check_ip_clean $IP
  if [ $? -eq 0 ]; then
    echo "Configuring WireGuard for IP ${IP}"
    configure_wireguard $IP
    break
  fi
done