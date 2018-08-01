# icinga2-slack-notification

Example:

![alt text](https://user-images.githubusercontent.com/1058480/43542720-ca579cc6-959b-11e8-889b-dfa6c9b0dce4.png "Slack screenshot")

Thanks to @dverkade for the updated template and screenshot :smile:

### Your setup may vary, so some of the config files included here may need to be tweaked

1. Set up a new incoming webhook /services/new/incoming-webhook for your team
2. Add slack-service-notification.sh to /etc/icinga2/scripts directory
3. Add the contents of slack-service-notification.conf to your templates.conf (or keep it separate depending on your setup)
4. Add the contents of slack-service-notification-command.conf to your commands.conf (or keep it separate depending on your setup)
5. Add an entry to your notifications.conf (see example below)
```
apply Notification "slack" to Service {
  import "slack-service-notification"
  user_groups = [ "oncall" ]
  interval = 30m
  assign where host.vars.sla == "24x7"
}
```
6. Set up a new user and usergroup
```
object User "oncall_alerts" {
  import "generic-user"

  display_name = "oncall alerts"
  groups = [ "oncall" ]
  states = [ OK, Warning, Critical ]
  types = [ Problem, Recovery ]

  email = "my@email.com"
}

object UserGroup "oncall" {
  display_name = "oncall"
}
```
