# Tutorial for set up clickhouse server


## Setup Cluster


This part we will setup

- 2 clusters, with 2 shards
- Each shard has 2 replica server
- Each cluster has its own query node


### Cluster

Let's see our docker-compose.yml first.

```
version: '3'

services:
    clickhouse-zookeeper-01:
        image: zookeeper
        ports:
            - "2181:2181"
            - "2182:2182"
        container_name: clickhouse-zookeeper-01
        hostname: clickhouse-zookeeper-01
	
    clickhouse-zookeeper-02:
        image: zookeeper
        ports:
            - "2281:2181"
            - "2282:2182"
        container_name: clickhouse-zookeeper-02
        hostname: clickhouse-zookeeper-02

    # cluster_old
    clickhouse-01:
        image: yandex/clickhouse-server:20.7
        hostname: clickhouse-01
        container_name: clickhouse-01
        ports:
            - 9001:9000
            - 8221:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_old.xml:/etc/clickhouse-server/metrika.xml
                - ./config/macros/macros-01.xml:/etc/clickhouse-server/config.d/macros.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-01:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper-01"
	    
    # cluster_old
    clickhouse-01-replica:
        image: yandex/clickhouse-server:20.7
        hostname: clickhouse-01-replica
        container_name: clickhouse-01-replica
        ports:
            - 9051:9000
            - 8251:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_old.xml:/etc/clickhouse-server/metrika.xml
                - ./config/macros/macros-01-replica.xml:/etc/clickhouse-server/config.d/macros.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-01:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper-01"

    # cluster_old
    clickhouse-02:
        image: yandex/clickhouse-server:20.7
        hostname: clickhouse-02
        container_name: clickhouse-02
        ports:
            - 9002:9000
            - 8222:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_old.xml:/etc/clickhouse-server/metrika.xml
                - ./config/macros/macros-02.xml:/etc/clickhouse-server/config.d/macros.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-02:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper-01"

    # cluster_new
    clickhouse-03:
        image: clickhouse/clickhouse-server:21.8
        hostname: clickhouse-03
        container_name: clickhouse-03
        ports:
            - 9003:9000
            - 8223:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_new.xml:/etc/clickhouse-server/metrika.xml
                - ./config/macros/macros-03.xml:/etc/clickhouse-server/config.d/macros.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-03:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper-02"
	    
    # cluster_new
    clickhouse-03-replica:
        image: clickhouse/clickhouse-server:21.8
        hostname: clickhouse-03-replica
        container_name: clickhouse-03-replica
        ports:
            - 9053:9000
            - 8253:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_new.xml:/etc/clickhouse-server/metrika.xml
                - ./config/macros/macros-03-replica.xml:/etc/clickhouse-server/config.d/macros.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-03:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper-02"

    #cluster_new
    clickhouse-04:
        image: clickhouse/clickhouse-server:21.8
        hostname: clickhouse-04
        container_name: clickhouse-04
        ports:
            - 9004:9000
            - 8224:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_new.xml:/etc/clickhouse-server/metrika.xml
                - ./config/macros/macros-04.xml:/etc/clickhouse-server/config.d/macros.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-04:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper-02"

    # query_old
    query-old:
        image: yandex/clickhouse-server:20.7
        hostname: query-old
        container_name: query-old
        ports:
            - 9005:9000
            - 8225:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_old.xml:/etc/clickhouse-server/metrika.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-05:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144

    # query_new
    query-new:
        image: clickhouse/clickhouse-server:21.8
        hostname: query-new
        container_name: query-new
        ports:
            - 9006:9000
            - 8226:8123
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika_new.xml:/etc/clickhouse-server/metrika.xml
                - ./config/users.xml:/etc/clickhouse-server/users.xml
                # - ./data/server-06:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144

networks:
    default:
        name: sentry
```


We have 8 clickhouse server container and 2 zookeeper container. They are created in the sentry network so Snuba can talk to the clsuter.

clickhouse-01 and clickhouse-01-replica are replicas of each other. Those two and clickhouse-02 are storage nodes for cluster-old. clickhouse-03 and clickhouse-03-replica are replicas of each other. Those two and clickhouse-04 are storage nodes for cluster-new. query-old is the query node for cluster-old and query-new is the query node for cluster-new.


**To enable replication ZooKeeper is required. ClickHouse will take care of data consistency on all replicas and run restore procedure after failure automatically. It's recommended to deploy ZooKeeper cluster to separate servers.**

**ZooKeeper is not a requirement — in some simple cases you can duplicate the data by writing it into all the replicas from your application code. This approach is not recommended — in this case ClickHouse is not able to guarantee data consistency on all replicas. This remains the responsibility of your application.**


Let's see config file.

`./config/clickhouse_config.xml` is the default config file in docker, we copy it out and add this line

```
    <!-- If element has 'incl' attribute, then for it's value will be used corresponding substitution from another file.
         By default, path to file with substitutions is /etc/metrika.xml. It could be changed in config in 'include_from' element.
         Values for substitutions are specified in /yandex/name_of_substitution elements in that file.
      -->
    <include_from>/etc/clickhouse-server/metrika.xml</include_from>
```


So lets see `metrika.xml` for cluster_old

```
<yandex>
	<clickhouse_remote_servers>
		<cluster_old>
			<shard>
				<weight>1</weight>
				<internal_replication>true</internal_replication>
				<replica>
					<host>clickhouse-01</host>
					<port>9000</port>
				</replica>
				<replica>
					<host>clickhouse-01-replica</host>
					<port>9000</port>
				</replica>
			</shard>
			<shard>
				<weight>1</weight>
				<internal_replication>true</internal_replication>
				<replica>
					<host>clickhouse-02</host>
					<port>9000</port>
				</replica>
			</shard>
		</cluster_old>
	</clickhouse_remote_servers>
	<zookeeper-servers>
		<node index="1">
			<host>clickhouse-zookeeper-01</host>
			<port>2181</port>
		</node>
	</zookeeper-servers>
	<networks>
		<ip>::/0</ip>
	</networks>
	<clickhouse_compression>
		<case>
			<min_part_size>10000000000</min_part_size>
			<min_part_size_ratio>0.01</min_part_size_ratio>
			<method>lz4</method>
		</case>
	</clickhouse_compression>
</yandex>
```

and macros.xml, each instances has there own macros settings, like server 1:

```
<yandex>
    <macros>
        <replica>clickhouse-01</replica>
        <shard>01</shard>
    </macros>
</yandex>
```


**Make sure your macros settings is equal to remote server settings in metrika.xml**

So now you can start the server.

```
docker-compose up -d
```

Conn to server and see if the cluster settings fine;

```
docker run -it --rm --network="sentry" --link query-old:clickhouse-server yandex/clickhouse-client --host clickhouse-server
```

```sql
query-old :) select * from system.clusters

SELECT *
FROM system.clusters

Query id: 05bc4ab6-4438-4110-821f-3dbcabbb4700

┌─cluster─────────────────────┬─shard_num─┬─shard_weight─┬─replica_num─┬─host_name─────┬─host_address─┬─port─┬─is_local─┬─user────┬─default_database─┬─errors_count─┬─estimated_recovery_time─┐
│ cluster_old                 │         1 │            1 │           1 │ clickhouse-01 │ 172.21.0.8   │ 9000 │        0 │ default │                  │            0 │                       0 │
│ cluster_old                 │         2 │            1 │           1 │ clickhouse-02 │ 172.21.0.4   │ 9000 │        0 │ default │                  │            0 │                       0 │
│ test_shard_localhost        │         1 │            1 │           1 │ localhost     │ 127.0.0.1    │ 9000 │        1 │ default │                  │            0 │                       0 │
│ test_shard_localhost_secure │         1 │            1 │           1 │ localhost     │ 127.0.0.1    │ 9440 │        0 │ default │                  │            0 │                       0 │
└─────────────────────────────┴───────────┴──────────────┴─────────────┴───────────────┴──────────────┴──────┴──────────┴─────────┴──────────────────┴──────────────┴─────────────────────────┘

4 rows in set. Elapsed: 0.027 sec.
```

If you see this, it means cluster's settings work well(but not conn fine).

```
docker run -it --rm --network="sentry" --link query-new:clickhouse-server yandex/clickhouse-client --host clickhouse-server
```

```sql
query-new :) select * from system.clusters

SELECT *
FROM system.clusters

Query id: 8857ef86-00cb-4f09-845d-5f223bec7602

┌─cluster─────────────────────┬─shard_num─┬─shard_weight─┬─replica_num─┬─host_name─────┬─host_address─┬─port─┬─is_local─┬─user────┬─default_database─┬─errors_count─┬─slowdowns_count─┬─estimated_recovery_time─┐
│ cluster_new                 │         1 │            1 │           1 │ clickhouse-03 │ 172.21.0.7   │ 9000 │        0 │ default │                  │            0 │               0 │                       0 │
│ cluster_new                 │         2 │            1 │           1 │ clickhouse-04 │ 172.21.0.6   │ 9000 │        0 │ default │                  │            0 │               0 │                       0 │
│ test_shard_localhost        │         1 │            1 │           1 │ localhost     │ 127.0.0.1    │ 9000 │        1 │ default │                  │            0 │               0 │                       0 │
│ test_shard_localhost_secure │         1 │            1 │           1 │ localhost     │ 127.0.0.1    │ 9440 │        0 │ default │                  │            0 │               0 │                       0 │
└─────────────────────────────┴───────────┴──────────────┴─────────────┴───────────────┴──────────────┴──────┴──────────┴─────────┴──────────────────┴──────────────┴─────────────────┴─────────────────────────┘

4 rows in set. Elapsed: 0.018 sec.
```
