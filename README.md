# Tutorial for set up clickhouse server


## Setup Cluster


This part we will setup

- 3 node zookeeper cluster
- 3 node clickhouse storage cluster
- 1 node clichouse query cluster

### Cluster

So now you can start the server.

```
docker-compose up -d
```

Check query node

```sql
query-01 :) SELECT *
:-] FROM system.clusters

SELECT *
FROM system.clusters

Query id: 3d9ed1d4-abd2-4f53-8496-67195f6686cd

┌─cluster─────────────────────┬─shard_num─┬─shard_weight─┬─replica_num─┬─host_name──┬─host_address─┬─port─┬─is_local─┬─user────┬─default_database─┬─errors_count─┬─slowdowns_count─┬─estimated_recovery_time─┐
│ query                       │         1 │            1 │           1 │ query-01   │ 172.18.0.8   │ 9000 │        1 │ default │                  │            0 │               0 │                       0 │
│ storage                     │         1 │            1 │           1 │ storage-01 │ 172.18.0.5   │ 9000 │        0 │ default │                  │            0 │               0 │                       0 │
│ storage                     │         1 │            1 │           2 │ storage-02 │ 172.18.0.7   │ 9000 │        0 │ default │                  │            0 │               0 │                       0 │
│ storage                     │         1 │            1 │           3 │ storage-03 │ 172.18.0.6   │ 9000 │        0 │ default │                  │            0 │               0 │                       0 │
│ test_shard_localhost        │         1 │            1 │           1 │ localhost  │ 127.0.0.1    │ 9000 │        1 │ default │                  │            0 │               0 │                       0 │
│ test_shard_localhost_secure │         1 │            1 │           1 │ localhost  │ 127.0.0.1    │ 9440 │        0 │ default │                  │            0 │               0 │                       0 │
└─────────────────────────────┴───────────┴──────────────┴─────────────┴────────────┴──────────────┴──────┴──────────┴─────────┴──────────────────┴──────────────┴─────────────────┴─────────────────────────┘

6 rows in set. Elapsed: 0.040 sec.
```

Check replication status on storage nodes

```sql
storage-02 :) SELECT
:-] database,
:-] table,
:-] total_replicas,
:-] active_replicas
:-] FROM system.replicas

SELECT
    database,
    table,
    total_replicas,
    active_replicas
FROM system.replicas

Query id: 6e4363c2-fa28-4902-b633-02c502945094

┌─database─┬─table────────┬─total_replicas─┬─active_replicas─┐
│ default  │ errors_local │              3 │               3 │
└──────────┴──────────────┴────────────────┴─────────────────┘

1 rows in set. Elapsed: 0.025 sec.
```
