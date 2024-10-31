#!/bin/bash

# Check if the nncea parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <nncea_value>"
    exit 1
fi

# Set the value of nncea variable
NNCEA="$1"

curl "http://localhost:8983/solr/blacklight-core/update?commit=true" -d "<delete><query>id:${NNCEA}_*</query></delete>"
# Create the log file if it doesn't exist
touch /home/deploy/ArclightEmpireADC/empireadc_index_logs/${NNCEA}-index.log

# Run find command with parallel   make j+0 for noral use
/usr/bin/find /home/deploy/eads/$NNCEA -name '*.xml' | parallel -j8 --eta FILE={.}.xml REPOSITORY_ID=$NNCEA bundle exec rake arclight:index 2>&1 | tee  /home/deploy/ArclightEmpireADC/empireadc_index_logs/${NNCEA}-index.log
