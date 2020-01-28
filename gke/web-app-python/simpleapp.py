#!/usr/bin/python
from flask import Flask, render_template
import sys
import optparse
import time

app = Flask(__name__,template_folder='template')

start = int(round(time.time()))

@app.route("/")
def hello_world():

    #return "Hello world from Google Cloud Platform!"
    return render_template('home.html',logo='google-cloud-logo.png')

if __name__ == '__main__':
    parser = optparse.OptionParser(usage="python simpleapp.py -p ")
    parser.add_option('-p', '--port', action='store', dest='port', help='The port to listen on.')
    (args, _) = parser.parse_args()
    if args.port == None:
        print "Missing required argument: -p/--port"
        sys.exit(1)
    app.run(host='0.0.0.0', port=int(args.port), debug=True)

