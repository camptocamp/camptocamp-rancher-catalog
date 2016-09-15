Rancher catalog template for Conplicity
=======================================

[Conplicity](https://github.com/camptocamp/conplicity) lets you backup all your named Docker volumes using Duplicity or RClone.

Parameters
----------

### CONPLICITY_RUN_TIME

The cron schedule for the job.

### CONPLICITY_FULL_IF_OLDER_THAN

Perform a full backup if the latest full backup in the collection is older than the given time.

### CONPLICITY_REMOVE_OLDER_THAN

Delete all backup sets older than the given time.

### CONPLICITY_VOLUMES_BLACKLIST

Comma separated list of named volumes to blacklist.

### CONPLICITY_NO_VERIFY

Whether to skip verification of volume backups.

### CONPLICITY_TARGET_URL

Target URL passed to backup engine. The hostname and the name of the volume to backup are added to the path as directory levels.

### PUSHGATEWAY_URL

Prometheus Pushgateway service to push metrics to.

### AWS_ACCESS_KEY_ID

### AWS_SECRET_ACCESS_KEY

### SWIFT_AUTHURL

### SWIFT_TENANTNAME

### SWIFT_USERNAME

### SWIFT_PASSWORD

### SWIFT_REGIONNAME

### JSON_OUTPUT

Wheter to output logs as JSON

### CONPLICITY_LOG_LEVEL

Log level
