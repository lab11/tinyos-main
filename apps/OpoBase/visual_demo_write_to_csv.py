import csv
import sys

writer = csv.writer(open('visual.csv', 'wb'), delimiter=' ')

while True:
	line = sys.stdin.readline()
	s = line.strip()
	s = s.split()
	writer.writerow(s)