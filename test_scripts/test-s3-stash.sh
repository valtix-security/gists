#!/bin/bash
echo 'Attempting to copy file from PII S3 bucket to alternate S3 bucket'
aws s3 cp s3://valtix-sedemo-piidata/customer_A_priv.csv s3://eddie-stash
