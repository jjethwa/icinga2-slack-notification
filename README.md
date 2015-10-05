# icinga2-slack-notification

1. Set up a new incoming webhook /services/new/incoming-webhook for your team
2. Add slack-service-notification.sh to /etc/icinga2/scripts directory
3. Add the contents of slack-service-notification.conf to your templates.conf (or keep it separate depending on your setup)
4. Add an entry to your notifications.conf (see example below)

```
apply Notification "slack" to Service {
  import "slack-service-notification"
  interval = 30m
  assign where host.vars.sla == "24x7"
}
```
