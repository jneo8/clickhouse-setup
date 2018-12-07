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
