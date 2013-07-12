import sys
import urllib2
import json

packet = {'g_id': 2}

while True:
    line = sys.stdin.readline()
    if "Booted" not in line:
        s = line.split(":")
        packet[s[0]] = int(s[1].strip())
        if "Range" in line:
            r = float(s[1].strip()) / 1000000.0
            packet[s[0]] = r
        if "Hour" in line:
            data = json.dumps(packet)
            d_len = len(data)
            url = 'http://127.0.0.1:5000/raw_update'
            req = urllib2.Request(url, data, {'Content-Type': 'application/json',
                                              'Content-Length': d_len})
            r = urllib2.urlopen(req)
            print str(r.read())
