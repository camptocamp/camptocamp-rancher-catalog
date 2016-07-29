# PostgreSQL Incremental Backup

This composition is based on the following softwares:

* [pghoard](https://github.com/ohmu/pghoard) for the backup/restore service
* [confd](https://github.com/kelseyhightower/confd) to manage the configuration

Before starting the test scenario below, you have to:

1. Create a `.env` file containing your AWS variables:

```
AWS_ACCESS_KEY_ID=XXXX
AWS_SECRET_ACCESS_KEY=XXXX
AWS_BUCKETNAME=pghoard
AWS_DEFAULT_REGION=eu-west-1
```

## Test scenario to understand how it works
 
1. first of all, run the following command:

        docker-compose up

2. open a shell on the `master` container and see the replication slot

        docker exec -it master bash
        gosu postgres psql -c "SELECT * FROM pg_replication_slots;"

3. still on the master, create two first databases, get the current txid and create a third one

        gosu postgres createdb aa
        gosu postgres createdb bb
        gosu postgres psql -c "SELECT txid_current();" # xid=635
        gosu postgres createdb cc

4. now on the `pgbackup` container, we'll try to get the most recent backup (warning: pghoard doesn't manage automatically `.partial` wal file)

        docker exec -it pgbackup bash
        kill -STOP $(pgrep pg_receivexlog)
        cd pghoard/b5315a2c74f9/xlog_incoming
        cp 000000010000000000000003.partial 000000010000000000000003
        cd
        pghoard_restore list-basebackups --config pghoard.json --site $HOSTNAME
        pghoard_restore get-basebackup --config pghoard.json --site $HOSTNAME --target-dir restore --restore-to-master
        pg_ctl -D restore start
        psql -l

5. now do the same but restore a backup with a specific XID

        pg_ctl -D restore stop
        rm -fR restore
        pghoard_restore get-basebackup --config pghoard.json --site $HOSTNAME --target-dir restore --restore-to-master --recovery-target-xid 635
        pg_ctl -D restore start
        psql -l


6. finally, don't forget to remote the temporary wal file from S3 (not sure if it's really necessary), stop the local PostgreSQL and resume the pg_receivexlog process

        aws s3 rm s3://pghoard/${HOSTNAME}/xlog/000000010000000000000003
        pg_ctl -D restore stop
        kill -CONT $(pgrep pg_receivexlog)

## Restoring the master database cluster

As you can see in the file [docker-compose.yml](docker-compose.yml), the
PostgreSQL data cluster is available in both containers. This way, it's pretty
easy to restore your master to a certain PITR.

Once the composition is up and running, you can simply:

        docker exec -it pgbackup bash
        ...
        pghoard_restore get-basebackup --config pghoard.json --site $HOSTNAME --target-dir restore --restore-to-master --recovery-target-xid 635
        pg_ctl -D restore start
        pg_ctl -D restore stop

From another terminal, stop your current master with:

        docker-compose stop master

Go back inside your `pgbackup` container and

        rsync -av --delete restore/ master/

And finally restart your PostgreSQL master service:

        docker-compose start master

That's it!
