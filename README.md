# Tutorial for set up clickhouse server


## Single server with docker


- Run server

```
docker run -d --name clickhouse-server -p 9000:9000 --ulimit nofile=262144:262144 yandex/clickhouse-server

```

- Run client

```
docker run -it --rm --link clickhouse-server:clickhouse-server yandex/clickhouse-client  --host clickhouse-server
```

Now you can see if it success setup or not.


## Cluster


For cluster, let's see docker-compose.yml first.


```
version: '3'

services:
    clickhouse-zookeeper:
        image: zookeeper
        ports:
            - "2181:2181"
            - "2182:2182"
        container_name: clickhouse-zookeeper
        hostname: clickhouse-zookeeper

    clickhouse-01:
        image: yandex/clickhouse-server
        hostname: clickhouse-01
        container_name: clickhouse-01
        ports:
            - 9001:9000
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika.xml:/etc/clickhouse-server/metrika.xml
                - ./data/server-01:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper"

    clickhouse-02:
        image: yandex/clickhouse-server
        hostname: clickhouse-02
        container_name: clickhouse-02
        ports:
            - 9002:9000
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika.xml:/etc/clickhouse-server/metrika.xml
                - ./data/server-02:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper"

    clickhouse-03:
        image: yandex/clickhouse-server
        hostname: clickhouse-03
        container_name: clickhouse-03
        ports:
            - 9003:9000
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika.xml:/etc/clickhouse-server/metrika.xml
                - ./data/server-03:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper"

    clickhouse-04:
        image: yandex/clickhouse-server
        hostname: clickhouse-04
        container_name: clickhouse-04
        ports:
            - 9004:9000
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika.xml:/etc/clickhouse-server/metrika.xml
                - ./data/server-04:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper"

    clickhouse-05:
        image: yandex/clickhouse-server
        hostname: clickhouse-05
        container_name: clickhouse-05
        ports:
            - 9005:9000
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika.xml:/etc/clickhouse-server/metrika.xml
                - ./data/server-05:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper"

    clickhouse-06:
        image: yandex/clickhouse-server
        hostname: clickhouse-06
        container_name: clickhouse-06
        ports:
            - 9006:9000
        volumes:
                - ./config/clickhouse_config.xml:/etc/clickhouse-server/config.xml
                - ./config/clickhouse_metrika.xml:/etc/clickhouse-server/metrika.xml
                - ./data/server-06:/var/lib/clickhouse
        ulimits:
            nofile:
                soft: 262144
                hard: 262144
        depends_on:
            - "clickhouse-zookeeper"
networks:
    default:
        external:
            name: clickhouse-net
```

We create 6 clickhouse server and one zookeeper container.


**To enable replication ZooKeeper is required. ClickHouse will take care of data consistency on all replicas and run restore procedure after failure automatically. It's recommended to deploy ZooKeeper cluster to separate servers.**

**ZooKeeper is not a requirement — in some simple cases you can duplicate the data by writing it into all the replicas from your application code. This approach is not recommended — in this case ClickHouse is not able to guarantee data consistency on all replicas. This remains the responsibility of your application.**


Lets see config file.

`./config/clickhouse_config.xml` is the default config file in docker, we copy it out and add


```
    <!-- If element has 'incl' attribute, then for it's value will be used corresponding substitution from another file.
         By default, path to file with substitutions is /etc/metrika.xml. It could be changed in config in 'include_from' element.
         Values for substitutions are specified in /yandex/name_of_substitution elements in that file.
      -->
    <include_from>/etc/clickhouse-server/metrika.xml</include_from>
```

So that we can put out our cluster settings in metrika.xml.


Also we need to set mocros for identifying shard and replica - it will be used on table creation.
(I already put it in metrika.xml)

```
<macros>
    <shard>01</shard>
    <replica>01</replica>
</macros>
```

So lets see metrika.xml


```
<yandex>
	<clickhouse_remote_servers>
		<cluster_person>
			<shard>
				<replica>
					<host>clickhouse-01</host>
					<port>9000</port>
				</replica>
				<replica>
					<host>clickhouse-02</host>
					<port>9000</port>
				</replica>
			</shard>
			<shard>
				<replica>
					<host>clickhouse-03</host>
					<port>9000</port>
				</replica>
				<replica>
					<host>clickhouse-04</host>
					<port>9000</port>
				</replica>
			</shard>
			<shard>
				<replica>
					<host>clickhouse-05</host>
					<port>9000</port>
				</replica>
				<replica>
					<host>clickhouse-06</host>
					<port>9000</port>
				</replica>
			</shard>
		</cluster_person>
	</clickhouse_remote_servers>
        <zookeeper-servers>
            <node index="1">
                <host>clickhouse-zookeeper</host>
                <port>2181</port>
            </node>
        </zookeeper-servers>
        <macros>
            <shard>01</shard>
            <replica>01</replica>
        </macros>
</yandex>
```

We setup 3 shards, each shard has two replica server.

So now you can start the server.

```
docker network create clickhouse-net
docker-compose up -d
```

Conn to server and see if the cluster settings fine;

```
docker run -it --rm --network="clickhouse-net" --link clickhouse-01:clickhouse-server yandex/clickhouse-client --host clickhouse-server
```

```sql
select * from system.clusters;
```

```
SELECT *
FROM system.clusters 

┌─cluster─────────────────────┬─shard_num─┬─shard_weight─┬─replica_num─┬─host_name─────┬─host_address─┬─port─┬─is_local─┬─user────┬─default_database─┐
│ cluster_person              │         1 │            1 │           1 │ clickhouse-01 │ 172.21.0.4   │ 9000 │        1 │ default │                  │
│ cluster_person              │         1 │            1 │           2 │ clickhouse-02 │ 172.21.0.6   │ 9000 │        1 │ default │                  │
│ cluster_person              │         2 │            1 │           1 │ clickhouse-03 │ 172.21.0.7   │ 9000 │        0 │ default │                  │
│ cluster_person              │         2 │            1 │           2 │ clickhouse-04 │ 172.21.0.8   │ 9000 │        0 │ default │                  │
│ cluster_person              │         3 │            1 │           1 │ clickhouse-05 │ 172.21.0.3   │ 9000 │        0 │ default │                  │
│ cluster_person              │         3 │            1 │           2 │ clickhouse-06 │ 172.21.0.5   │ 9000 │        0 │ default │                  │
│ test_shard_localhost        │         1 │            1 │           1 │ localhost     │ 127.0.0.1    │ 9000 │        1 │ default │                  │
│ test_shard_localhost_secure │         1 │            1 │           1 │ localhost     │ 127.0.0.1    │ 9440 │        0 │ default │                  │
└─────────────────────────────┴───────────┴──────────────┴─────────────┴───────────────┴──────────────┴──────┴──────────┴─────────┴──────────────────┘

8 rows in set. Elapsed: 0.003 sec. 
```
