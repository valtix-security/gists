#!/bin/bash
if [[ $# -eq 0 ]]
  then
    echo "No argument supplied.  Run ./test-s3-put.sh <testfile>"
    exit 1
fi
echo "Writing file to PII bucket:" $1
aws s3 cp $1 s3://valtix-sedemo-piidata
