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

Also we need to set mocros for identifying shard and replica - it will be used on table creation.

```
<macros>
    <shard>01</shard>
    <replica>01</replica>
</macros>
```
