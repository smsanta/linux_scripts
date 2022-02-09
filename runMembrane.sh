#!/bin/bash
membranePath=/opt/work/membrane-service-proxy-4.8.0
membraneRunSh="$membranePath/service-proxy.sh"
membraneLogFile="$membranePath/memrouter.log"

membraneRunPid=$(sockstat -4 -l | grep :9000 | awk '{print $3}' | head -1)

if [ -z "$membraneRunPid" ]; then
    echo "Starting up membrane!"
    sh $membraneRunSh
else
    echo "Membrane is already running with pid: $membraneRunPid! catching up log."
    tail -f $membraneLogFile
fi
