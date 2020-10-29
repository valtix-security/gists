#!/bin/bash
#
# This triggers EICAR test malware for egress test
#
echo 'Attempting to trigger malware detection'
wget https://www.eicar.org/gateway.php --method=POST --body-data=TklPTiBBTEwgU0VMRUNU
