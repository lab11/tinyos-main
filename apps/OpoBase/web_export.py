import sys
import urllib2
import json

packet = {'G_ID': 2}

while True:
    line = sys.stdin.readline()
    if ":" in line:
        s = line.split(":")
        if "ID" in line:
            packet[s[0]] = int(s[1].strip(), 16)
        else:
            packet[s[0]] = int(s[1].strip())
        if "RANGE" in line:
            r = float(s[1].strip()) / 1000000.0
            packet[s[0]] = r
        if "TIME" in line:
            print "Woo"
            if len(packet) == 8:
                print packet
                data = json.dumps(packet)
                d_len = len(data)
                url = 'http://fusion.eecs.umich/raw_update'
                req = urllib2.Request(url, data, {'Content-Type': 'application/json',
                                                  'Content-Length': d_len})
                r = urllib2.urlopen(req)
                print str(r.read())
            else:
                print "Misformed Packet"
                print str(packet)
                print "--------------------"
            packet = {'G_ID': 2}
