#!/bin/bash

ICINGA_HOSTNAME="<YOUR_ICINGAWEB2_HOSTNAME>"
SLACK_WEBHOOK_URL="<YOUR_SLACK_WEBHOOK_INTEGRATION_URL>"
SLACK_CHANNEL="#alerts"
SLACK_BOTNAME="icinga2"

#Set the message icon based on ICINGA service state
if [ "$SERVICESTATE" = "CRITICAL" ]
then
    COLOR="danger"
elif [ "$SERVICESTATE" = "WARNING" ]
then
    COLOR="warning"
elif [ "$SERVICESTATE" = "OK" ]
then
    COLOR="good"
elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
    COLOR="#800080"
else
    COLOR=""
fi

#Send message to Slack
read -d '' PAYLOAD << EOF
{
  "channel": "${SLACK_CHANNEL}",
  "username": "${SLACK_BOTNAME}",
  "attachments": [
    {
      "fallback": "${SERVICESTATE}: ${HOSTDISPLAYNAME} - ${SERVICEDISPLAYNAME}",
      "color": "${COLOR}",
      "fields": [
        {
          "title": "Service output",
          "value": "${SERVICEOUTPUT}",
          "short": false
        },
        {
          "title": "Host",
          "value": "<${ICINGA_HOSTNAME}/monitoring/host/services?host=${HOSTNAME}|${HOSTDISPLAYNAME}>",
          "short": true
        },
        {
          "title": "Service",
          "value": "<${ICINGA_HOSTNAME}/monitoring/service/show?host=${HOSTNAME}&service=${SERVICEDESC}|${SERVICEDISPLAYNAME}>",
          "short": true
        },
        {
          "title": "State",
          "value": "${SERVICESTATE}",
          "short": true
        }
      ]
    }
  ]
}
EOF

curl --connect-timeout 30 --max-time 60 -s -S -X POST -H 'Content-type: application/json' --data "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"
