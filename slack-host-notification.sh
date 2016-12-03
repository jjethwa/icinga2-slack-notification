#!/bin/bash

ICINGA_HOSTNAME="<YOUR_ICINGAWEB2_HOSTNAME>"
SLACK_WEBHOOK_URL="<YOUR_SLACK_WEBHOOK_INTEGRATION_URL>"
SLACK_CHANNEL="#alerts"
SLACK_BOTNAME="icinga2"

#Set the message icon based on ICINGA Host state
if [ "$HOSTSTATE" = "DOWN" ]
then
    ICON=":bomb:"
elif [ "$HOSTSTATE" = "UP" ]
then
    ICON=":beer:"
else
    ICON=":white_medium_square:"
fi

#Send message to Slack
PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} HOST: <http://${ICINGA_HOSTNAME}:${ICINGA_PORT}/icingaweb2/monitoring/host/services?host=${HOSTNAME}|${HOSTDISPLAYNAME}>  STATE: ${HOSTSTATE}\n\n Additional Info: ${HOSTOUTPUT}\"}"

curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"
