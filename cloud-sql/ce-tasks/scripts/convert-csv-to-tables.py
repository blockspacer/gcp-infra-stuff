#!/usr/bin/python3

from os import path
from io import open
import sys, getopt
import csv

def get_user_name(name):
    with open('../csv/USERS.csv', newline='') as csvfile:
            filereader = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            next(filereader, None)  # skip the 1st line
            for row in filereader:
                full_name = row[2] + ' ' + row[3]
                if ( name == full_name  ):
                    return row[1]

def get_status_code(status):
    with open('../csv/STATUS_TYPES.csv', newline='') as csvfile:
            filereader = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            next(filereader, None)  # skip the 1st line
            for row in filereader:
                if ( name == row[1]):
                    return row[0]


def main(argv,script):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print (script + ' -i <inputfile> -o <outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('test.py -i <inputfile> -o <outputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
            if (not path.exists(inputfile)):
                print ('file ' + inputfile + ' does not exist')
                sys.exit(2)
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    if (inputfile == ''):
        print (script + ' -i <inputfile> -o <outputfile>')
        sys.exit(2)

    with open(outputfile, 'w', newline='') as csvfile:
        fieldnames = ['REQUEST_ID','REQUEST_INFORMATION','REQUESTOR_ID','REQUEST_OWNER','STATUS_ID','CUSTOMER_ID','OPP_ID','CREATED','LAST_UPDATE']
        csv_writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        csv_writer.writeheader()

        with open(inputfile, newline='') as csvfile:
            filereader = csv.reader(csvfile, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            next(filereader, None)  # skip the 1st line
            next(filereader, None)  # skip the 2nd line
            for row in filereader:
                
                line = {}
                skip_row = False
                
                fsr=row[0]
                sfopp=row[1]
                oppvalue=row[2]	
                customer=row[3]	
                customer_contacts=row[4]
                customer_phone=row[5]
                ce_assigned=row[6]
                task_type=row[7]
                status=row[8]
                created=row[9]
                description=row[10]
                fsr_comment=row[11]
                ce_comment=row[12]
                change_date=row[13]
                # Checking if mandatory fields exist
                if ( fsr == '' or sfopp == ''):
                    skip_row = True

                if (not skip_row ):
                    line['REQUEST_INFORMATION'] = description
                    line['REQUESTOR_ID'] = get_user_name(fsr)
                    line['REQUEST_OWNER'] = get_user_name(ce_assigned)
                    line['STATUS_ID'] = get_status_code(status)
                    line['CUSTOMER_ID'] = customer
                    line['OPP_ID'] = sfopp
                    line['CREATED'] = created
                    csv_writer.writerow(line)

if __name__ == "__main__":
   main(sys.argv[1:],sys.argv[0])