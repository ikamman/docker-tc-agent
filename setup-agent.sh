#!/usr/bin/env sh

AGENT_DIR="/opt/teamcity_agent"

if [ -z "$TC_SERVER" ]; then
    echo "Fatal error: TC_SERVER is not set."
    echo "Launch this container with -e TC_SERVER=http://servername:port."
    echo
    exit
fi

if [ ! -d "$AGENT_DIR" ]; then
    echo "Setting up TeamCity Agent for the first time..."
    echo "Agent will be installed to ${AGENT_DIR}."
    
    mkdir -p $AGENT_DIR

    wget -q $TC_SERVER/update/buildAgent.zip -O /tmp/buildAgent.zip
    if [ ! -e /tmp/buildAgent.zip ]; then
        echo "The build agent package download failure"
        exit 1
    fi

    ping $TC_SERVER
    
    unzip -q -d $AGENT_DIR /tmp/buildAgent.zip
    rm /tmp/buildAgent.zip
    chmod +x $AGENT_DIR/bin/agent.sh
    AGENT_CONF=$AGENT_DIR/conf/buildAgent.properties
    touch $AGENT_CONF
    printf "\n%b\n" "serverUrl=${TC_SERVER}"  | iconv -f utf-8 -t ascii > $AGENT_CONF
    printf "\n%b\n" "name=agent_${AGENT_PORT}" >> $AGENT_CONF
    printf "\n%b\n"  "workDir=../work" >> $AGENT_CONF
    printf "\n%b\n"  "tempDir=../temp" >> $AGENT_CONF
    printf "\n%b\n"  "systemDir=../system" >> $AGENT_CONF

    if [ ! -z "$AGENT_PORT" ]; then
        echo "ownPort=${AGENT_PORT}" >> $AGENT_CONF
    fi
    export CONFIG_FILE=$AGENT_CONF
    cat $AGENT_CONF
else
    echo "Using agent at ${AGENT_DIR}."
fi
$AGENT_DIR/bin/agent.sh run