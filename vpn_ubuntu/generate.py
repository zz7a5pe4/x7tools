#!/usr/bin/python

import os,stat
import pptpcfg

def writefile(name, content):
    f = open(name, "w")
    f.write(content)
    f.close()

def main():
    vpnitems = [x.strip() for x in open("vpnlist.txt") if not x.strip()[0] == r"#"]
    for i in vpnitems:
        c, s = i.split(":")
        cfgname = c.strip()
        srvaddr = s.strip()
        cfg = pptpcfg.pptpcfg(srvaddr, cfgname)
        n = os.path.join("system-connections", cfgname)
        writefile(n, cfg)
        os.chmod(n,stat.S_IREAD|stat.S_IWRITE)
        #os.chown(n,0,0)

# /etc/NetworkManager/system-connections/

if __name__ == '__main__':
    try:
        os.mkdir("system-connections")
    except OSError as e:
        pass
    main()
