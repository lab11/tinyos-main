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
            packet['RANGE'] = r
        if "TIME" in line:
            if len(packet) == 8:
                print packet
                data = json.dumps(packet)
                d_len = len(data)
                url = 'http://fusion.eecs.umich.edu/raw_update'
                req = urllib2.Request(url, data, {'Content-Type': 'application/json',
                                                  'Content-Length': d_len})
                try:
                    r = urllib2.urlopen(req)
                except urllib2.HTTPError, e:
                    print "HTTP ERROR"
                    print "Code: " + str(e.code)
                    print "Msg: " + str(e.msg)
                    print "Hdrs: " + str(e.hdrs)
                    print "fp: " + str(e.fp)
                print "Correct Packet"
                print str(r.read())
            else:
                print "Misformed Packet"
                print str(packet)
                print "--------------------"
            packet = {'G_ID': 2}
