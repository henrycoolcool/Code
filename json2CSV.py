import json
import csv
from pprint import pprint
import logging
import sys
arg1 = sys.argv[1]

def jsonToCSV(file_name):
	logging.basicConfig(level=logging.INFO)
	toCsv=[]
	num_lines = sum(1 for line in open(file_name))
	print(num_lines)
	with open(file_name) as data_file:
		i = 1.
		for line in data_file:
			i=i+1
			data = json.loads(line)
			data['data'] = str(data['data'])
			toCsv.append(data)
			if i% (num_lines/100) ==0:
				logging.info('Now loading : {0:.0%}'.format(i/num_lines))

	print('finish loading')

	keys = ['created_at','data','date','device_id','id','lat','lng','log_type','parkinglot_brand_ids','parkinglot_count','parkinglot_id','radius','updated_at']
	print(toCsv[0].keys())


	with open('myCSV.csv', 'wb') as output_file:
	    dict_writer = csv.DictWriter(output_file, keys)
	    dict_writer.writeheader()
	    dict_writer.writerows(toCsv)

	print('finish writing')

if __name__ == '__main__':
    jsonToCSV(arg1)