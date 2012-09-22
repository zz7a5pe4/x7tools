#!/usr/bin/python

import uuid
from string import Template
import sys

contpl = """
[connection]
id=$CONFID
uuid=$CONFUUID
type=vpn
autoconnect=false

[vpn]
service-type=org.freedesktop.NetworkManager.pptp
gateway=$CONFSERVERADDR
user=$CONFUSER
password-flags=0

[vpn-secrets]
password=$CONFPASS

[ipv4]
method=auto
"""

def main():
    print  pptpcfg("77.247.180.159", "hello")

def pptpcfg(saddr, sid, name="admin",pw="admin"):
    if not saddr:
        return None;
    cuuid=str(uuid.uuid5(uuid.NAMESPACE_DNS, saddr))
    cfg = dict(CONFID=sid,
               CONFUUID=cuuid,
               CONFSERVERADDR=saddr,
               CONFUSER=name,
               CONFPASS=pw)
    return Template(contpl).substitute(cfg)

if __name__ == '__main__':
    main()
