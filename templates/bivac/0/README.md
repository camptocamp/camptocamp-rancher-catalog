Rancher catalog template for Bivac
==================================

[Bivac](https://github.com/camptocamp/bivac) lets you backup all your named Docker volumes using Restic, Duplicity or RClone.

Requires `Rancher Container Crontab`.

Parameters
----------

### BIVAC_RUN_TIME

The cron schedule for the job.

### BIVAC_FULL_IF_OLDER_THAN

Perform a full backup if the latest full backup in the collection is older than the given time.

### BIVAC_REMOVE_OLDER_THAN

Delete all backup sets older than the given time.

### BIVAC_VOLUMES_BLACKLIST

Comma separated list of named volumes to blacklist.

### BIVAC_NO_VERIFY

Whether to skip verification of volume backups.

### BIVAC_TARGET_URL

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

### BIVAC_LOG_LEVEL

Log level
