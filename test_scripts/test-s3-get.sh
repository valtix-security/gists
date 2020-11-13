#!/bin/bash
echo 'Downloading customer A file from PII bucket'
aws s3 cp s3://valtix-sedemo-piidata/customer_A_priv.csv .
