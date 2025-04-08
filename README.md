# CIAB.KV.db.to.config.Wireguard.VPN.Nodes   
Pre-req:   
- requires build/installation of VxWireguard-Generator tool ***vwgen***   
- execution of vmgen to create a Master VxLAN/Wireguard node configuration database   
    
This Bash script creates a Key/Value db of generated Wireguard VPN Node configurations   
using the Master VxLAN/WIreguard node configuration database   
where:   
   
> **KEY = the A VPN *"Node Name"* in the format of "nodeXXX"**   
> **Value = the Wireguard Node configuration for "nodeXXX"**

