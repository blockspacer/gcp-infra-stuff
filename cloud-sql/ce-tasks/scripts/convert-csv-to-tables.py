#!/usr/bin/python3

from os import path
from io import open
import sys, getopt
import csv

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

    with open(inputfile, newline='') as csvfile:
        filereader = csv.reader(csvfile, delimiter='\t', quotechar='|')
        next(filereader, None)  # skip the headers
        next(filereader, None)  # skip the headers
        for row in filereader:
            print(row[0])
            print ('\n')

    exit()

    file = open(inputfile,'r')
    for i in file.readlines():
        print (i + '\n')

if __name__ == "__main__":
   main(sys.argv[1:],sys.argv[0])