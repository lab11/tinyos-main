import csv
import sys
import time

m_file = open('visual.csv', 'wb')
writer = csv.writer(m_file, delimiter=' ')
throwaway = sys.stdin.readline()

while True:
	line = sys.stdin.readline()
	current_time = time.mktime(time.gmtime())
	s = line.strip()
	s = s.split()
	s.append(current_time)
	writer.writerow(s)
	m_file.flush()