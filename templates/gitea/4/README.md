Rancher catalog template for Gitea
==================================

[Gitea](https://gitea.io) - Git with a cup of tea

Parameters
----------

### GITEA_DATABASE_SERVICE

The database service to use.

### GITEA_SERVER_SSH_PORT

SSH port to access Gitea cli.

### GITEA_SERVER_DOMAIN

Domain name of your server.

### GITEA_SERVICE_ENABLE_NOTIFY_MAIL

Enable this to send e-mail to watchers of repository when something happens like creating issues, requires Mailer to be enabled.

### GITEA_SERVICE_ENABLE_REVERSE_PROXY_AUTHENTICATION

Gitea considers users authenticated if X-Forwarded-User is set.

### GITEA_SERVICE_ENABLE_REVERSE_PROXY_AUTO_REGISTRATION

Enable this if you want gitea to create users if REVERSE_PROXY_AUTHENTICATION is enabled.

### GITEA_SERVICE_DISABLE_REGISTRATION

Enable this if you want only administrators to create accounts.

### GITEA_SERVICE_SHOW_REGISTRATION_BUTTON

Disable this if you do not want users to create new accounts by clicking on the button.

### GITEA_MAILER_ENABLED

Enable this to use a mail service.

### GITEA_MAILER_FROM

Mail from address, RFC 5322. This can be just an email address, or the “Name” <email@example.com> format.

### GITEA_MAILER_HOST

Note, if the port ends with '465', SMTPS will be used. Using STARTTLS on port 587 is recommended per RFC 6409. If the server supports STARTTLS it will always be used.)

### GITEA_MAILER_USER

User name of mailer (usually just your e-mail address).

### GITEA_MAILER_PASSWD

Password of mailer.

### GITEA_MAILER_SKIP_VERIFY

Do not verify the self-signed certificates.
