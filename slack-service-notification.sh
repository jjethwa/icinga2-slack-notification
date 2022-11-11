#!/bin/bash

ICINGA_HOSTNAME="<YOUR_ICINGAWEB2_HOSTNAME>"
SLACK_WEBHOOK_URL="<YOUR_SLACK_WEBHOOK_INTEGRATION_URL>"
SLACK_CHANNEL="#alerts"
SLACK_BOTNAME="icinga2"

# Set the message icon based on ICINGA service state
if [ "$SERVICESTATE" = "CRITICAL" ]
then
    COLOR="#FF5566"
elif [ "$SERVICESTATE" = "WARNING" ]
then
    COLOR="#FFAA44"
elif [ "$SERVICESTATE" = "OK" ]
then
    COLOR="#44BB77"
elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
    COLOR="#800080"
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
  INFORMATION="${SERVICEOUTPUT}"
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
      "fallback": "${NOTIFICATIONTYPE} - ${SERVICESTATE}: ${HOSTDISPLAYNAME} - ${SERVICEDISPLAYNAME}",
      "color": "${COLOR}",
      "fields": [
        {
          "title": "Type",
          "value": "${NOTIFICATIONTYPE}",
          "short": true
        },
        {
          "title": "State",
          "value": "${SERVICESTATE}",
          "short": true
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
          "title": "Information",
          "value": "${INFORMATION}",
          "short": false
        },
      ]
    }
  ]
}
EOF

curl --connect-timeout 30 --max-time 60 -s -S -X POST -H 'Content-type: application/json' --data "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"