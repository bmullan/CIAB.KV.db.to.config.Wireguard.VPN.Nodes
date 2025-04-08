#!/bin/bash 

source /usr/bin/kv-bash.sh

# Prompt the user for the VPN name
read -p "Enter the VPN name: " vpnname

# Prompt the user for the maximum number of nodes
read -p "Enter the maximum number of nodes: " maxnodes

# Define the IPv4 and IPv6 pools
ipv4pool="172.20.10.0/22"
ipv6pool="2001:db8:42::/64"

# Add the VPN
vwgen add "$vpnname"

# Set the IPv4 and IPv6 pools for the VPN
vwgen set "$vpnname" pool-ipv4 "$ipv4pool"
vwgen set "$vpnname" pool-ipv6 "$ipv6pool"

# Add nodes to the VPN
nodenumber=1
#while [ "$nodenumber" -le "$maxnodes" ]; do
while [ $nodenumber -le $maxnodes ]; do
  # Format the node number with leading zeros
  formatted_nodenumber=$(printf "%03d" $nodenumber)
  vwgen add "$vpnname" "node$formatted_nodenumber"
  nodenumber=$((nodenumber + 1))
done

# Set the endpoint and listen port for each node
portnumber=50000
nodenumber=1
#while [ "$nodenumber" -le "$maxnodes" ]; do
while [ $nodenumber -le $maxnodes ]; do
  # Format the node number with leading zeros
  formatted_nodenumber=$(printf "%03d" "$nodenumber")
  # Calculate the IPv4 address for the node
  ipv4_last_octet=$((10 + nodenumber))
  ipv4addr="172.20.10.$ipv4_last_octet"
  vwgen set "$vpnname" node "node$formatted_nodenumber" endpoint "$ipv4addr:$portnumber" listen-port "$portnumber"
  nodenumber=$((nodenumber + 1))
  portnumber=$((portnumber + 1)) # Increment port number for each node
done

#"============================================================================"
#" Now that we have the Master VXLan Wireguard Config file we need to"
#" populate our KV database with each entry using NODEXXX as the KEY"
#" and the Value being that NODEXXX's config extracted from the Master"
#"============================================================================"

# Define the input and output file names
nodecfg_file="$vpnname".conf
output_file="results.txt"

# Check if the input file exists
if [ ! -f "$nodecfg_file" ]; then
  echo "Error: Configuration file '$config_file' not found."
  exit 1
fi

nodenumber=1
while [ $nodenumber -le $maxnodes ]; do
  value=""
  # Format the node number with leading zeros
  formatted_nodenumber=$(printf "%03d" "$nodenumber")
  currentnode="node$formatted_nodenumber"

  vwgen showconf $vpnname $currentnode > ./node.conf
  while IFS= read -r line; do
    value+="$line"$'\n'
  done < "./node.conf"

  kvset $currentnode "$value"
  rm ./node.conf
  nodenumber=$((nodenumber + 1))
done


