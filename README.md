# IPSec Forwarder

Expose servers behind a VPN connection to a local Docker network

# Setup

```mermaid
graph TB
a[<b>your docker container</b><br>wants to access <i>192.168.123.42:80</i>, therefore requests <i>ipsec-forwarder:9000</i>]
b["<b>ipsec-forwarder (docker container)</b><br>listens on port <i>9000</i> and forwards requests to <i>192.168.123.42:80</i>"]
c[<b>Target Host</b><br>IP: <i>192.168.123.42</i>, provides a service on port <i>80</i>]

a-->|docker network| b
b-->|IPSec Tunnel| c
```

# Deployment

```yaml
version: '3.9'

services:

  ipsec-forwarder:
    image: knrdl/ipsec-forwarder
    hostname: ipsec-forwarder
    restart: always
    environment:
      VPNC_GATEWAY: IP or qualified name of the IPSec gateway
      VPNC_ID: Group name
      VPNC_SECRET: Group password
      VPNC_USERNAME: XAUTH username
      VPNC_PASSWORD: XAUTH password
      FORWARDS: 9000:192.168.123.42:80,9001:192.168.123.42:81 # example with 2 forwards
    networks:
      - vpn_net
    cap_add:
      - NET_ADMIN  # necessary to create tunneling device

  your-container:
    image: curlimages/curl
    command: "sh -c 'sleep 10 && curl ipsec-forwarder:9000'"
    restart: always
    networks:
      - vpn_net

networks:
  vpn_net:
```
