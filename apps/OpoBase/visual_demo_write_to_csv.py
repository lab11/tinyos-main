import csv
import sys
import time

writer = csv.writer(open('visual.csv', 'wb'), delimiter=' ')
throwaway = sys.stdin.readline()

while True:
	line = sys.stdin.readline()
	current_time = time.mktime(time.gmtime())
	s = line.strip()
	s = s.split()
	s.append(current_time)
	writer.writerow(s)