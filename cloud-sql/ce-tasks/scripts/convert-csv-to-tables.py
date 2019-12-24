#!/usr/bin/python3

from os import path
from io import open
import sys, getopt
import csv

def get_user_name(name,userscsv):
    with open(userscsv, newline='') as csvfile:
            filereader = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            next(filereader, None)  # skip the 1st line
            for row in filereader:
                full_name = row[2] + ' ' + row[3]
                if ( name == full_name  ):
                    return row[1]

def get_status_code(status,statuscsv):
    with open(statuscsv, newline='') as csvfile:
            filereader = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            next(filereader, None)  # skip the 1st line
            for row in filereader:
                if ( status == row[1]):
                    return row[0]

def get_customer_id(customer_name,customercsv):
    with open(customercsv, newline='') as csvfile:
            filereader = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            next(filereader, None)  # skip the 1st line
            for row in filereader:
                if ( customer_name == row[1]):
                    return row[0]
            return 0

def create_customer_dictionary(inputfile):
    list_dicts = []
    with open(inputfile, newline='') as csvfile:
        filereader = csv.reader(csvfile, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        next(filereader, None)  # skip the 1st line
        next(filereader, None)  # skip the 2nd line

        index = 1

        for row in filereader:
            customer=row[3]
            if ( (customer != '') and (customer not in list_dicts)):
                dict_tmp={}
                dict_tmp['CUSTOMER_ID'] = index
                dict_tmp['CUSTOMER_DESCRIPTION'] = customer
                list_dicts.append (dict_tmp)
                index = index +1 
    return list_dicts



def main(argv,script):

    userscsv='../csv/USERS.csv'
    statuscsv='../csv/STATUS_TYPES.csv'
    requestscsv='../csv/REQUESTS.csv'
    customerscsv='../csv/CUSTOMERS.csv'

    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:",["ifile="])
    except getopt.GetoptError:
        print (script + ' -i <inputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('test.py -i <inputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
            if (not path.exists(inputfile)):
                print ('file ' + inputfile + ' does not exist')
                sys.exit(2)

    if (inputfile == ''):
        print (script + ' -i <inputfile>')
        sys.exit(2)

    lista = create_customer_dictionary(inputfile)
    print (lista)

    with open(requestscsv, 'w', newline='') as csvfileout, open(inputfile, newline='') as csvfile, open (customerscsv,'w',newline='') as custcsvfileout:
        
        # setting up the requests output file
        request_fieldnames = ['REQUEST_ID','REQUEST_INFORMATION','REQUESTOR_ID','REQUEST_OWNER','STATUS_ID','CUSTOMER_ID','OPP_ID','CREATED','LAST_UPDATE','DEAL_YEARS','OPP_SIZE']
        csv_writer = csv.DictWriter(csvfileout, fieldnames=request_fieldnames)
        csv_writer.writeheader()

        # setting up the customers output file
        customers_fieldnames = ['CUSTOMER_ID','CUSTOMER_DESCRIPTION']
        cust_csv_writer = csv.DictWriter(custcsvfileout,fieldnames=customers_fieldnames)
        cust_csv_writer.writeheader()
        cust_index = 0
        
        filereader = csv.reader(csvfile, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        next(filereader, None)  # skip the 1st line
        next(filereader, None)  # skip the 2nd line

        for row in filereader:
                
            reqline = {}
            custline = {}
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
                reqline['REQUEST_INFORMATION'] = description
                reqline['REQUESTOR_ID'] = get_user_name(fsr,userscsv)
                reqline['REQUEST_OWNER'] = get_user_name(ce_assigned,userscsv)
                reqline['STATUS_ID'] = get_status_code(status,statuscsv)
                reqline['CUSTOMER_ID'] = customer
                reqline['OPP_ID'] = sfopp
                reqline['CREATED'] = created
                csv_writer.writerow(reqline)
            
            print ('customer id: ' + str(get_customer_id(customer,customerscsv)) + ' customer: ' + customer)
            if (customer != '' and (get_customer_id(customer,customerscsv) == 0)):
                custline['CUSTOMER_ID'] = cust_index
                custline['CUSTOMER_DESCRIPTION'] = customer
                cust_index = cust_index + 1
                cust_csv_writer.writerow(custline)


if __name__ == "__main__":
   main(sys.argv[1:],sys.argv[0])