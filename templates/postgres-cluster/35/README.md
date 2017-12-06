# Camptocamp PostgreSQL's Cluster for Rancher

## Features

This stack will:

* start one PostgreSQL per node in the environment,
* configure the first one as master and the other ones as replicas,
* provide a read-write entry point listening on port 5432 that redirects all
queries to the PostgreSQL master container,
* provide a read-only entry point listening on port 5433 that load balances all
queries to all PostgreSQL containers,
* start a PGHoard container that will do incremental backups to an object
storage and allows Point In Time Recovery.

## Replication

The replication is set-up at database initialization. When a container is
spawned, if it detects that it is not the first container of its service, then
it configures itself as a replica of the master, performing a *pg_base_backup*,
and registering as a *physical_slot_replication*.

### Testing the replication

Log into the master container and create a database:
```
$ psql -U postgres -c "CREATE DATABASE db1;"
```

Log into the replicas and check that the database is created:
```
$ psql -U postgres -l
```

If everything works as expected the database *db1* created on the current master
is replicated on the replicas.

## Load-balancing

The load-balancing is performed by HAProxy.
The first container is added to the read-write listener and enabled is it is not
in *recovery*.
All the containers are added to the read-only listener.

### Testing the load-balancing

To test the load balancing of read-only requests you can use something like this:

```
$ while true; do psql -Atq -h lb -p 5433 -U postgres -c "select inet_server_addr();"; done
```

### Simulate the crash of the master

:bulb: To see what happens with the read/write access during this simulation,
simply run the above command to generate continuous read requests and the script
[cinsert](../scripts/cinsert.sh) to generate continuous write requests.

The goal of this simulation is to promote a standby to become the master (with
replication slots) and test again the replication. Here is the procedure step by
step (which could be easily wrapped in a script):

1. Deactivate the host that hosts the master container (so that Rancher does not
respawn the container when you will delete it).

2. Delete the current master container and its sidekick (very important), then
remove its named volume (so that it will do the database initialization on
respawning).

        $ docker volume rm <volume_name>

3. create the replication slots on the replica that will be promoted:

        $ psql -U postgres -c "SELECT * FROM pg_create_physical_replication_slot('<replica_container_name>');"

4. promote the new master:

        $ gosu postgres pg_ctl promote

5. create a new database (on the master):

        $ psql -U postgres -c "CREATE DATABASE db2;"

6. Test the replication (on the replicas):

        $ psql -U postgres -l

7. Activate the deactivated host. This will respawn the missing container.

8. create a new database (on the master):

        $ psql -U postgres -c "CREATE DATABASE db3;"

9. Test the replication (on the replicas):

        $ psql -U postgres -l

## Incremental Backup

## Point In Time Recovery

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
