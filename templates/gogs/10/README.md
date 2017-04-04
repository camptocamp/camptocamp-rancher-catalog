Rancher catalog template for Gogs
=================================

[Gogs](https://gogs.io) A painless self-hosted Git service.

Parameters
----------

### GOGS_DATABASE_SERVICE

The database service to use.

### GOGS_SERVER_SSH_PORT

SSH port to access Gogs cli.

### GOGS_SERVER_DOMAIN

Domain name of your server.

### GOGS_SERVICE_ENABLE_NOTIFY_MAIL

Enable this to send e-mail to watchers of repository when something happens like creating issues, requires Mailer to be enabled.

### GOGS_SERVICE_ENABLE_REVERSE_PROXY_AUTHENTICATION

Gogs considers users authenticated if X-Forwarded-User is set.

### GOGS_SERVICE_ENABLE_REVERSE_PROXY_AUTO_REGISTRATION

Enable this if you want gogs to create users if REVERSE_PROXY_AUTHENTICATION is enabled.

### GOGS_SERVICE_DISABLE_REGISTRATION

Enable this if you want only administrators to create accounts.

### GOGS_SERVICE_SHOW_REGISTRATION_BUTTON

Disable this if you do not want users to create new accounts by clicking on the button.

### GOGS_MAILER_ENABLED

Enable this to use a mail service.

### GOGS_MAILER_FROM

Mail from address, RFC 5322. This can be just an email address, or the “Name” <email@example.com> format.

### GOGS_MAILER_HOST

Note, if the port ends with '465', SMTPS will be used. Using STARTTLS on port 587 is recommended per RFC 6409. If the server supports STARTTLS it will always be used.)

### GOGS_MAILER_USER

User name of mailer (usually just your e-mail address).

### GOGS_MAILER_PASSWD

Password of mailer.

### GOGS_MAILER_SKIP_VERIFY

Do not verify the self-signed certificates.
