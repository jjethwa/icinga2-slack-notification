#!/bin/bash

ICINGA_HOSTNAME="<YOUR_ICINGAWEB2_HOSTNAME>"
SLACK_WEBHOOK_URL="<YOUR_SLACK_WEBHOOK_INTEGRATION_URL>"
SLACK_CHANNEL="#alerts"
SLACK_BOTNAME="icinga2"

# Set the color based on host state
if [ "$HOSTSTATE" = "DOWN" ]
then
    COLOR="#FF5566"
elif [ "$HOSTSTATE" = "UP" ]
then
    COLOR="#44BB77"
else
    COLOR=""
fi

# Overwrite color for informational notification types
if [ "$NOTIFICATIONTYPE" = "ACKNOWLEDGEMENT" ] || [ "$NOTIFICATIONTYPE" = "DOWNTIMESTART" ] || [ "$NOTIFICATIONTYPE" = "DOWNTIMEEND" ]
then
  COLOR="#7F7F7F"
fi

# Determine information to display
if [ -z "$NOTIFICATIONCOMMENT" ]
then
  INFORMATION="${HOSTOUTPUT}"
else
  INFORMATION="${NOTIFICATIONCOMMENT}"
fi

# Send message to Slack
read -d '' PAYLOAD << EOF
{
  "channel": "${SLACK_CHANNEL}",
  "username": "${SLACK_BOTNAME}",
  "attachments": [
    {
      "fallback": "${NOTIFICATIONTYPE} - ${HOSTSTATE}: ${HOSTDISPLAYNAME}",
      "color": "${COLOR}",
      "fields": [
        {
          "title": "Type",
          "value": "${NOTIFICATIONTYPE}",
          "short": true
        },
        {
          "title": "State",
          "value": "${HOSTSTATE}",
          "short": true
        },
        {
          "title": "Host",
          "value": "<${ICINGA_HOSTNAME}/monitoring/host/services?host=${HOSTNAME}|${HOSTDISPLAYNAME}>",
          "short": true
        },
        {
          "title": "Information",
          "value": "${HOSTOUTPUT}\n${NOTIFICATIONCOMMENT}",
          "short": false
        }
      ]
    }
  ]
}
EOF

curl --connect-timeout 30 --max-time 60 -s -S -X POST -H 'Content-type: application/json' --data "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"