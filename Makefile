run-single-server:
	docker run -d --name clickhouse-server -p 9000:9000 --ulimit nofile=262144:262144 yandex/clickhouse-server

run-single-client:
	docker run -it --rm --link clickhouse-server:clickhouse-server yandex/clickhouse-client  --host clickhouse-server

run-cluster-client:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-01:clickhouse-server yandex/clickhouse-client --host clickhouse-server

