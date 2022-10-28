## Setting up a new replica with snuba's `copy-tables`
This example will walk you through getting a clickhouse setup that has a storage cluster, a migrations cluster, and a query node. In addition, you will be able to test out adding a new replica and using snuba's `copy-tables` script to create tables on that new replica.


**1. Create the network**

  You'll need to create the network that is used in the `docker-compose.yml` file. Setting the `subnet` and `gateway` ensures that we have the same IPs that are used in the rest of the compose file.

  ```shell
  docker network create clickhouse-setup-network --subnet=172.28.0.0/16 --gateway=172.28.0.1
  ```
  
  If you want to verify you created the network you can use `docker network ls`, and if you want check the IPs look correct, you can use `docker inspect clickhouse-set-network`.

**2. Move into the `new_replica` folder**

```shell
cd examples/new_replica
```

**3. Build the snuba image**

The build [context](https://docs.docker.com/compose/compose-file/build/#context-required), which is basically the path to your snuba Dockerfile could be different than what's currently defined, so make sure to change that path if needed. Then you can build the image.

```shell
docker compose build
```

**4. Start the containers**

At this point you should be able to start up the containers.

> The redis ports from the sentry containers running will conflict with the redis container in this docker setp up so I would suggest that you do `sentry devservices down` before going forward.

```shell
docker compose up -d
```

You should have the following containers running:

```shell
10:27 $ docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                                            NAMES
b3bca2823668   yandex/clickhouse-server:20.7   "/entrypoint.sh"         20 seconds ago   Up 16 seconds   9009/tcp, 0.0.0.0:8251->8123/tcp, 0.0.0.0:9051->9000/tcp         clickhouse-01
d611fcf69501   yandex/clickhouse-server:20.7   "/entrypoint.sh"         20 seconds ago   Up 16 seconds   9009/tcp, 0.0.0.0:8252->8123/tcp, 0.0.0.0:9052->9000/tcp         clickhouse-01-replica
23dda7d7450e   yandex/clickhouse-server:20.7   "/entrypoint.sh"         20 seconds ago   Up 16 seconds   9009/tcp, 0.0.0.0:8253->8123/tcp, 0.0.0.0:9053->9000/tcp         clickhouse-02
ca56edfe381a   yandex/clickhouse-server:20.7   "/entrypoint.sh"         21 seconds ago   Up 18 seconds   9009/tcp, 0.0.0.0:8254->8123/tcp, 0.0.0.0:9054->9000/tcp         clickhouse-migrations-01
7984457a716e   yandex/clickhouse-server:20.7   "/entrypoint.sh"         21 seconds ago   Up 18 seconds   9009/tcp, 0.0.0.0:8225->8123/tcp, 0.0.0.0:9005->9000/tcp         query-old
4536fe2ad008   new_replica-custom              "./docker_entrypoint…"   21 seconds ago   Up 18 seconds   0.0.0.0:1218->1218/tcp                                           new_replica-custom-1
3e37886887f7   redis:5.0-alpine                "docker-entrypoint.s…"   21 seconds ago   Up 18 seconds   0.0.0.0:6379->6379/tcp                                           new_replica-redis-1
035fda3e6fa8   zookeeper                       "/docker-entrypoint.…"   21 seconds ago   Up 18 seconds   2888/tcp, 3888/tcp, 0.0.0.0:2181-2182->2181-2182/tcp, 8080/tcp   clickhouse-zookeeper-01
```

**5. Run migrations**

You wont have any tables on any of the nodes until you run migrations. We run the migrations from the snuba container which is the `new_replica-custom-1` container.

```shell
docker exec -it new_replica-custom-1 bash
```

You can run the migrations for everything, but here we will just be running the migrations for a single migration group: `generic_metrics`. The `system` migration group gets run by default first if it isn't run explicitly with `snuba migrations migrate --force --group=system`. 

```shell
snuba migrations migrate --force --group=generic_metrics
```

You should see the following in your output after running the migrations:

```shell
2022-10-28 17:30:58,321 Running migration: 0001_migrations
2022-10-28 17:30:58,433 Finished: 0001_migrations
2022-10-28 17:30:58,488 Running migration: 0001_sets_aggregate_table
2022-10-28 17:30:59,168 Finished: 0001_sets_aggregate_table
2022-10-28 17:30:59,194 Running migration: 0002_sets_raw_table
2022-10-28 17:30:59,364 Finished: 0002_sets_raw_table
2022-10-28 17:30:59,378 Running migration: 0003_sets_mv
2022-10-28 17:30:59,407 Finished: 0003_sets_mv
2022-10-28 17:30:59,416 Running migration: 0004_sets_raw_add_granularities
2022-10-28 17:30:59,523 Finished: 0004_sets_raw_add_granularities
2022-10-28 17:30:59,537 Running migration: 0005_sets_replace_mv
2022-10-28 17:30:59,599 Finished: 0005_sets_replace_mv
2022-10-28 17:30:59,609 Running migration: 0006_sets_raw_add_granularities_dist_table
2022-10-28 17:30:59,633 Finished: 0006_sets_raw_add_granularities_dist_table
2022-10-28 17:30:59,649 Running migration: 0007_distributions_aggregate_table
2022-10-28 17:31:00,582 Finished: 0007_distributions_aggregate_table
2022-10-28 17:31:00,597 Running migration: 0008_distributions_raw_table
2022-10-28 17:31:00,758 Finished: 0008_distributions_raw_table
2022-10-28 17:31:00,774 Running migration: 0009_distributions_mv
2022-10-28 17:31:00,814 Finished: 0009_distributions_mv
Finished running migrations
```

**6. Checking the migrations node**

We can first check that the migrations node (`clickhouse-migrations-01`) has the correct `migrations_local` table.

```shell
docker exec -it clickhouse-migrations-01  clickhouse-client
```

```sql
clickhouse-migrations-01 :) SHOW TABLES

SHOW TABLES

┌─name─────────────┐
│ migrations_local │
└──────────────────┘

1 rows in set. Elapsed: 0.007 sec.
```

And next we actually look at the migrations that were run and their status.

```sql
clickhouse-migrations-01 :) SELECT * FROM migrations_local

SELECT *
FROM migrations_local

┌─group───────────┬─migration_id───────────────────────────────┬───────────timestamp─┬─status────┬─version─┐
│ generic_metrics │ 0001_sets_aggregate_table                  │ 2022-10-28 17:30:59 │ completed │       2 │
│ generic_metrics │ 0002_sets_raw_table                        │ 2022-10-28 17:30:59 │ completed │       2 │
│ generic_metrics │ 0003_sets_mv                               │ 2022-10-28 17:30:59 │ completed │       1 │
│ generic_metrics │ 0004_sets_raw_add_granularities            │ 2022-10-28 17:30:59 │ completed │       1 │
│ generic_metrics │ 0005_sets_replace_mv                       │ 2022-10-28 17:30:59 │ completed │       1 │
│ generic_metrics │ 0006_sets_raw_add_granularities_dist_table │ 2022-10-28 17:30:59 │ completed │       1 │
│ generic_metrics │ 0007_distributions_aggregate_table         │ 2022-10-28 17:31:00 │ completed │       2 │
│ generic_metrics │ 0008_distributions_raw_table               │ 2022-10-28 17:31:00 │ completed │       2 │
│ generic_metrics │ 0009_distributions_mv                      │ 2022-10-28 17:31:00 │ completed │       1 │
│ system          │ 0001_migrations                            │ 2022-10-28 17:30:58 │ completed │       1 │
└─────────────────┴────────────────────────────────────────────┴─────────────────────┴───────────┴─────────┘

10 rows in set. Elapsed: 0.020 sec. 
```

**7. Checking the storage nodes and query node**

We can now do a similar check for the storage nodes and the query node. The storage nodes should have all the `local` tables for the `generic_metrics` group, and the query node will have all the `dist` tables, including the `migrations_dist` table.

> For each storage node you'd substitute `clickhouse-01` with the other container names.

```shell
docker exec -it clickhouse-01 clickhouse-client
```

```sql
clickhouse-01 :) SHOW TABLES

SHOW TABLES

┌─name──────────────────────────────────────────┐
│ generic_metric_distributions_aggregated_local │
│ generic_metric_distributions_aggregation_mv   │
│ generic_metric_distributions_raw_local        │
│ generic_metric_sets_aggregation_mv            │
│ generic_metric_sets_local                     │
│ generic_metric_sets_raw_local                 │
└───────────────────────────────────────────────┘

6 rows in set. Elapsed: 0.006 sec. 
```

The distributed node should looks similar but all the tables should `_dist` instead of `_local`

```shell
docker exec -it query-old clickhouse-client
```

```sql
query-old :) SHOW TABLES

SHOW TABLES

┌─name─────────────────────────────────────────┐
│ generic_metric_distributions_aggregated_dist │
│ generic_metric_distributions_raw_dist        │
│ generic_metric_sets_aggregated_dist          │
│ generic_metric_sets_raw_dist                 │
│ migrations_dist                              │
└──────────────────────────────────────────────┘

5 rows in set. Elapsed: 0.007 sec. 
```

**8. Add in `clickhouse-02-replica`**

At this point you could play around with inserting data, if you wanted but we are going forward with adding a new replica. 

Uncomment the `clickhouse-02-replica` section in the `docker-compose.yml` file. 

Then you can start up the container.

```shell
docker compose up -d clickhouse-02-replica
```
You should see it running when checking `docker ps`.

If you want to can use the clickhouse client to check to see that there are no tables yet, but the next step is to add the tables using the `copy-tables` script in snuba.

Once again you'll execute this from the snuba container

```shell
docker exec -it new_replica-custom-1 bash
```

Then you can cd into the `scripts` folder and run the script with the table(s) you want to copy over

```shell
$ cd scripts
$ python copy-tables.py --source-host=clickhouse-02 --target-host=clickhouse-02-replica --tables=generic_metric_distributions_raw_local

Replicated Table Check:
...looking up macros
...found replica: clickhouse-02 for shard: 02
...verifying zk replica path for table: generic_metric_distributions_raw_local...
...zookeeper replica paths verified for table: generic_metric_distributions_raw_local ! :)
creating generic_metric_distributions_raw_local... on replica: clickhouse-02-replica, shard: 02

create table statement: 
 CREATE TABLE default.generic_metric_distributions_raw_local
(
    `use_case_id` LowCardinality(String),
    `org_id` UInt64,
    `project_id` UInt64,
    `metric_id` UInt64,
    `timestamp` DateTime,
    `retention_days` UInt16,
    `tags.key` Array(UInt64),
    `tags.indexed_value` Array(UInt64),
    `tags.raw_value` Array(String),
    `set_values` Array(UInt64),
    `count_value` Float64,
    `distribution_values` Array(Float64),
    `metric_type` LowCardinality(String),
    `materialization_version` UInt8,
    `timeseries_id` UInt32,
    `partition` UInt16,
    `offset` UInt64,
    `granularities` Array(UInt8)
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/generic_metrics_distributions/{shard}/default/generic_metric_distributions_raw_local', '{replica}')
PARTITION BY toStartOfInterval(timestamp, toIntervalDay(3))
ORDER BY (use_case_id, org_id, project_id, metric_id, timestamp)
TTL timestamp + toIntervalDay(7)
SETTINGS index_granularity = 8192
```

And to actually execute, you'd use the `--execute` flag

```shell
$ python copy-tables.py --source-host=clickhouse-02 --target-host=clickhouse-02-replica --tables=generic_metric_distributions_raw_local --execute

Replicated Table Check:
...looking up macros
...found replica: clickhouse-02 for shard: 02
...verifying zk replica path for table: generic_metric_distributions_raw_local...
...zookeeper replica paths verified for table: generic_metric_distributions_raw_local ! :)
creating generic_metric_distributions_raw_local... on replica: clickhouse-02-replica, shard: 02
created generic_metric_distributions_raw_local !
```

**9. Check the new replica**

Now we can see that the table exists on the `clickhouse-02-replica` node

```shell
docker exec -it clickhouse-02-replica clickhouse-client
```

```shell
clickhouse-02-replica :) show tables

SHOW TABLES

┌─name───────────────────────────────────┐
│ generic_metric_distributions_raw_local │
└────────────────────────────────────────┘

1 rows in set. Elapsed: 0.007 sec. 
```
