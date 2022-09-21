## New Replica Setup


Make sure in Snuba to be using the distributed migrations setting

```shell
export SNUBA_SETTINGS=distributed_migrations
```


Move into `new_replica` 

```shell
cd examples/new_replica
```

Start the containers

```shell
docker compose up -d
```

You should now see the following containers running with the appropriate ports, if you uncommented the 2nd replica for shard 2, you would see that included as well.

```shell
12:13 $ docker ps
CONTAINER ID   IMAGE                                                               COMMAND                  CREATED          STATUS          PORTS                                                                                            NAMES
30db1f879177   9e956a841d2c                                                        "/entrypoint.sh"         19 seconds ago   Up 15 seconds   9009/tcp, 0.0.0.0:8252->8123/tcp, :::8252->8123/tcp, 0.0.0.0:9052->9000/tcp, :::9052->9000/tcp   clickhouse-01-replica
09c26f83f962   9e956a841d2c                                                        "/entrypoint.sh"         19 seconds ago   Up 15 seconds   9009/tcp, 0.0.0.0:8251->8123/tcp, :::8251->8123/tcp, 0.0.0.0:9051->9000/tcp, :::9051->9000/tcp   clickhouse-01
9a4a99ee7d8b   9e956a841d2c                                                        "/entrypoint.sh"         19 seconds ago   Up 15 seconds   9009/tcp, 0.0.0.0:8253->8123/tcp, :::8253->8123/tcp, 0.0.0.0:9053->9000/tcp, :::9053->9000/tcp   clickhouse-02
d81237c56b39   9e956a841d2c                                                        "/entrypoint.sh"         19 seconds ago   Up 17 seconds   9009/tcp, 0.0.0.0:8254->8123/tcp, :::8254->8123/tcp, 0.0.0.0:9054->9000/tcp, :::9054->9000/tcp   clickhouse-migrations-01
08e4e10d2eac   9e956a841d2c                                                        "/entrypoint.sh"         19 seconds ago   Up 17 seconds   9009/tcp, 0.0.0.0:8225->8123/tcp, :::8225->8123/tcp, 0.0.0.0:9005->9000/tcp, :::9005->9000/tcp   query-old
eb3f1bf50341   3d526e752a54                                                        "/docker-entrypoint.…"   19 seconds ago   Up 17 seconds   2888/tcp, 3888/tcp, 0.0.0.0:2181-2182->2181-2182/tcp, :::2181-2182->2181-2182/tcp, 8080/tcp      clickhouse-zookeeper-01
```

Now in snuba you can run the migrations command

```shell
snuba migrations migrate --force
```

_COMING SOON should be the `--group` flag `snuba migrations migration --force --group=generic_metrics`_

Now the migrations should have been run. 

Let's check the migrations cluster:

```shell
docker exec -it clickhouse-migrations-01  clickhouse-client
```

You can now doing things like `SHOW TABLES` and `SELECT * FROM migrations_local`.

```sql
clickhouse-migrations-01 :) SHOW TABLES

SHOW TABLES

┌─name─────────────┐
│ migrations_local │
└──────────────────┘

1 rows in set. Elapsed: 0.007 sec.
```

Let's see the migrations that have been run:

```sql
clickhouse-migrations-01 :) SELECT * FROM migrations_local

SELECT *
FROM migrations_local

┌─group───────────┬─migration_id────────────────────────────────────────────┬───────────timestamp─┬─status────┬─version─┐
│ discover        │ 0001_discover_merge_table                               │ 2022-09-21 12:21:03 │ completed │       2 │
│ discover        │ 0002_discover_add_deleted_tags_hash_map                 │ 2022-09-21 12:21:04 │ completed │       2 │
│ discover        │ 0003_discover_fix_user_column                           │ 2022-09-21 12:21:04 │ completed │       2 │
│ discover        │ 0004_discover_fix_title_and_message                     │ 2022-09-21 12:21:04 │ completed │       2 │
│ discover        │ 0005_discover_fix_transaction_name                      │ 2022-09-21 12:21:04 │ completed │       2 │
│ discover        │ 0006_discover_add_trace_id                              │ 2022-09-21 12:21:04 │ completed │       2 │
│ discover        │ 0007_discover_add_span_id                               │ 2022-09-21 12:21:04 │ completed │       2 │
│ events          │ 0001_events_initial                                     │ 2022-09-21 12:20:53 │ completed │       2 │
│ events          │ 0002_events_onpremise_compatibility                     │ 2022-09-21 12:20:54 │ completed │       2 │
│ events          │ 0003_errors                                             │ 2022-09-21 12:20:54 │ completed │       2 │
│ events          │ 0004_errors_onpremise_compatibility                     │ 2022-09-21 12:20:55 │ completed │       2 │
│ events          │ 0005_events_tags_hash_map                               │ 2022-09-21 12:20:55 │ completed │       2 │
│ events          │ 0006_errors_tags_hash_map                               │ 2022-09-21 12:20:55 │ completed │       2 │
│ events          │ 0007_groupedmessages                                    │ 2022-09-21 12:20:55 │ completed │       2 │
│ events          │ 0008_groupassignees                                     │ 2022-09-21 12:20:55 │ completed │       2 │
│ events          │ 0009_errors_add_http_fields                             │ 2022-09-21 12:20:56 │ completed │       2 │
│ events          │ 0010_groupedmessages_onpremise_compatibility            │ 2022-09-21 12:20:56 │ completed │       2 │
│ events          │ 0011_rebuild_errors                                     │ 2022-09-21 12:20:56 │ completed │       2 │
│ events          │ 0012_errors_make_level_nullable                         │ 2022-09-21 12:20:57 │ completed │       2 │
│ events          │ 0013_errors_add_hierarchical_hashes                     │ 2022-09-21 12:20:57 │ completed │       2 │
│ events          │ 0014_backfill_errors                                    │ 2022-09-21 12:20:57 │ completed │       2 │
│ events          │ 0015_truncate_events                                    │ 2022-09-21 12:20:57 │ completed │       2 │
│ events          │ 0016_drop_legacy_events                                 │ 2022-09-21 12:20:58 │ completed │       2 │
│ generic_metrics │ 0001_sets_aggregate_table                               │ 2022-09-21 12:21:17 │ completed │       2 │
│ generic_metrics │ 0002_sets_raw_table                                     │ 2022-09-21 12:21:18 │ completed │       2 │
│ generic_metrics │ 0003_sets_mv                                            │ 2022-09-21 12:21:18 │ completed │       2 │
│ generic_metrics │ 0004_sets_raw_add_granularities                         │ 2022-09-21 12:21:18 │ completed │       2 │
│ generic_metrics │ 0005_sets_replace_mv                                    │ 2022-09-21 12:21:18 │ completed │       2 │
│ generic_metrics │ 0006_sets_raw_add_granularities_dist_table              │ 2022-09-21 12:21:18 │ completed │       2 │
│ generic_metrics │ 0007_distributions_aggregate_table                      │ 2022-09-21 12:21:19 │ completed │       2 │
│ generic_metrics │ 0008_distributions_raw_table                            │ 2022-09-21 12:21:19 │ completed │       2 │
│ generic_metrics │ 0009_distributions_mv                                   │ 2022-09-21 12:21:19 │ completed │       2 │
│ metrics         │ 0001_metrics_buckets                                    │ 2022-09-21 12:21:04 │ completed │       2 │
│ metrics         │ 0002_metrics_sets                                       │ 2022-09-21 12:21:05 │ completed │       2 │
│ metrics         │ 0003_counters_to_buckets                                │ 2022-09-21 12:21:05 │ completed │       2 │
│ metrics         │ 0004_metrics_counters                                   │ 2022-09-21 12:21:05 │ completed │       2 │
│ metrics         │ 0005_metrics_distributions_buckets                      │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0006_metrics_distributions                              │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0007_metrics_sets_granularity_10                        │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0008_metrics_counters_granularity_10                    │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0009_metrics_distributions_granularity_10               │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0010_metrics_sets_granularity_1h                        │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0011_metrics_counters_granularity_1h                    │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0012_metrics_distributions_granularity_1h               │ 2022-09-21 12:21:06 │ completed │       2 │
│ metrics         │ 0013_metrics_sets_granularity_1d                        │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0014_metrics_counters_granularity_1d                    │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0015_metrics_distributions_granularity_1d               │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0016_metrics_sets_consolidated_granularity              │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0017_metrics_counters_consolidated_granularity          │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0018_metrics_distributions_consolidated_granularity     │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0019_aggregate_tables_add_ttl                           │ 2022-09-21 12:21:07 │ completed │       2 │
│ metrics         │ 0020_polymorphic_buckets_table                          │ 2022-09-21 12:21:08 │ completed │       2 │
│ metrics         │ 0021_polymorphic_bucket_materialized_views              │ 2022-09-21 12:21:08 │ completed │       2 │
│ metrics         │ 0022_repartition_polymorphic_table                      │ 2022-09-21 12:21:08 │ completed │       2 │
│ metrics         │ 0023_polymorphic_repartitioned_bucket_matview           │ 2022-09-21 12:21:08 │ completed │       2 │
│ metrics         │ 0024_metrics_distributions_add_histogram                │ 2022-09-21 12:21:08 │ completed │       2 │
│ metrics         │ 0025_metrics_counters_aggregate_v2                      │ 2022-09-21 12:21:09 │ completed │       2 │
│ metrics         │ 0026_metrics_counters_v2_writing_matview                │ 2022-09-21 12:21:09 │ completed │       2 │
│ metrics         │ 0027_fix_migration_0026                                 │ 2022-09-21 12:21:09 │ completed │       2 │
│ metrics         │ 0028_metrics_sets_aggregate_v2                          │ 2022-09-21 12:21:09 │ completed │       2 │
│ metrics         │ 0029_metrics_distributions_aggregate_v2                 │ 2022-09-21 12:21:10 │ completed │       2 │
│ metrics         │ 0030_metrics_distributions_v2_writing_mv                │ 2022-09-21 12:21:10 │ completed │       2 │
│ metrics         │ 0031_metrics_sets_v2_writing_mv                         │ 2022-09-21 12:21:10 │ completed │       2 │
│ metrics         │ 0032_redo_0030_and_0031_without_timestamps              │ 2022-09-21 12:21:10 │ completed │       2 │
│ metrics         │ 0033_metrics_cleanup_old_views                          │ 2022-09-21 12:21:11 │ completed │       2 │
│ metrics         │ 0034_metrics_cleanup_old_tables                         │ 2022-09-21 12:21:12 │ completed │       2 │
│ outcomes        │ 0001_outcomes                                           │ 2022-09-21 12:21:12 │ completed │       2 │
│ outcomes        │ 0002_outcomes_remove_size_and_bytes                     │ 2022-09-21 12:21:12 │ completed │       2 │
│ outcomes        │ 0003_outcomes_add_category_and_quantity                 │ 2022-09-21 12:21:13 │ completed │       2 │
│ outcomes        │ 0004_outcomes_matview_additions                         │ 2022-09-21 12:21:13 │ completed │       2 │
│ replays         │ 0001_replays                                            │ 2022-09-21 12:21:15 │ completed │       2 │
│ replays         │ 0002_add_url                                            │ 2022-09-21 12:21:15 │ completed │       2 │
│ replays         │ 0003_alter_url_allow_null                               │ 2022-09-21 12:21:15 │ completed │       2 │
│ replays         │ 0004_add_error_ids_column                               │ 2022-09-21 12:21:16 │ completed │       2 │
│ replays         │ 0005_add_urls_user_agent_replay_start_timestamp         │ 2022-09-21 12:21:17 │ completed │       2 │
│ sessions        │ 0001_sessions                                           │ 2022-09-21 12:21:13 │ completed │       2 │
│ sessions        │ 0002_sessions_aggregates                                │ 2022-09-21 12:21:14 │ completed │       2 │
│ sessions        │ 0003_sessions_matview                                   │ 2022-09-21 12:21:14 │ completed │       2 │
│ system          │ 0001_migrations                                         │ 2022-09-21 12:20:52 │ completed │       1 │
│ transactions    │ 0001_transactions                                       │ 2022-09-21 12:20:58 │ completed │       2 │
│ transactions    │ 0002_transactions_onpremise_fix_orderby_and_partitionby │ 2022-09-21 12:20:58 │ completed │       2 │
│ transactions    │ 0003_transactions_onpremise_fix_columns                 │ 2022-09-21 12:21:00 │ completed │       2 │
│ transactions    │ 0004_transactions_add_tags_hash_map                     │ 2022-09-21 12:21:00 │ completed │       2 │
│ transactions    │ 0005_transactions_add_measurements                      │ 2022-09-21 12:21:00 │ completed │       2 │
│ transactions    │ 0006_transactions_add_http_fields                       │ 2022-09-21 12:21:00 │ completed │       2 │
│ transactions    │ 0007_transactions_add_discover_cols                     │ 2022-09-21 12:21:01 │ completed │       2 │
│ transactions    │ 0008_transactions_add_timestamp_index                   │ 2022-09-21 12:21:01 │ completed │       2 │
│ transactions    │ 0009_transactions_fix_title_and_message                 │ 2022-09-21 12:21:01 │ completed │       2 │
│ transactions    │ 0010_transactions_nullable_trace_id                     │ 2022-09-21 12:21:01 │ completed │       2 │
│ transactions    │ 0011_transactions_add_span_op_breakdowns                │ 2022-09-21 12:21:01 │ completed │       2 │
│ transactions    │ 0012_transactions_add_spans                             │ 2022-09-21 12:21:02 │ completed │       2 │
│ transactions    │ 0013_transactions_reduce_spans_exclusive_time           │ 2022-09-21 12:21:03 │ completed │       2 │
│ transactions    │ 0014_transactions_remove_flattened_columns              │ 2022-09-21 12:21:03 │ completed │       2 │
│ transactions    │ 0015_transactions_add_source_column                     │ 2022-09-21 12:21:03 │ completed │       2 │
│ transactions    │ 0016_transactions_add_group_ids_column                  │ 2022-09-21 12:21:03 │ completed │       2 │
│ transactions    │ 0017_transactions_add_app_start_type_column             │ 2022-09-21 12:21:03 │ completed │       2 │
└─────────────────┴─────────────────────────────────────────────────────────┴─────────────────────┴───────────┴─────────┘
```


Okay now we can quit out of this server and try to look at the storage nodes. 

```shell
docker exec -it clickhouse-01 clickhouse-client
```


```sql
clickhouse-01 :) SHOW TABLES

SHOW TABLES

┌─name──────────────────────────────────────────┐
│ discover_local                                │
│ errors_local                                  │
│ generic_metric_distributions_aggregated_local │
│ generic_metric_distributions_aggregation_mv   │
│ generic_metric_distributions_raw_local        │
│ generic_metric_sets_aggregation_mv            │
│ generic_metric_sets_local                     │
│ generic_metric_sets_raw_local                 │
│ groupassignee_local                           │
│ groupedmessage_local                          │
│ metrics_counters_polymorphic_mv_v4_local      │
│ metrics_counters_v2_local                     │
│ metrics_distributions_polymorphic_mv_v4_local │
│ metrics_distributions_v2_local                │
│ metrics_raw_v2_local                          │
│ metrics_sets_polymorphic_mv_v4_local          │
│ metrics_sets_v2_local                         │
│ outcomes_hourly_local                         │
│ outcomes_mv_hourly_local                      │
│ outcomes_raw_local                            │
│ replays_local                                 │
│ sessions_hourly_local                         │
│ sessions_hourly_mv_local                      │
│ sessions_raw_local                            │
│ transactions_local                            │
└───────────────────────────────────────────────┘

25 rows in set. Elapsed: 0.006 sec.
```

The distributed node should looks similar but all the tables should `_dist` instead of `_local`

```shell
docker exec -it query-old clickhouse-client
```

```sql
query-old :) SHOW TABLES

SHOW TABLES

┌─name─────────────────────────────────────────┐
│ discover_dist                                │
│ errors_dist                                  │
│ errors_dist_ro                               │
│ generic_metric_distributions_aggregated_dist │
│ generic_metric_distributions_raw_dist        │
│ generic_metric_sets_aggregated_dist          │
│ generic_metric_sets_raw_dist                 │
│ groupassignee_dist                           │
│ groupedmessage_dist                          │
│ metrics_counters_v2_dist                     │
│ metrics_distributions_v2_dist                │
│ metrics_raw_v2_dist                          │
│ metrics_sets_v2_dist                         │
│ outcomes_hourly_dist                         │
│ outcomes_raw_dist                            │
│ replays_dist                                 │
│ sessions_hourly_dist                         │
│ sessions_raw_dist                            │
│ transactions_dist                            │
└──────────────────────────────────────────────┘

19 rows in set. Elapsed: 0.009 sec.
```

