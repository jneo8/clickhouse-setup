run-single-server:
	docker run -d --name clickhouse-server -p 9000:9000 --ulimit nofile=262144:262144 yandex/clickhouse-server

run-single-client:
	docker run -it --rm --link clickhouse-server:clickhouse-server yandex/clickhouse-client  --host clickhouse-server

run-cluster-client-1:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-01:clickhouse-server yandex/clickhouse-client --host clickhouse-server
run-cluster-client-2:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-02:clickhouse-server yandex/clickhouse-client --host clickhouse-server
run-cluster-client-3:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-03:clickhouse-server yandex/clickhouse-client --host clickhouse-server
run-cluster-client-4:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-04:clickhouse-server yandex/clickhouse-client --host clickhouse-server
run-cluster-client-5:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-05:clickhouse-server yandex/clickhouse-client --host clickhouse-server
run-cluster-client-6:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-06:clickhouse-server yandex/clickhouse-client --host clickhouse-server

run-cluster-client-1-auth:
	docker run -it --rm --network="clickhouse-net" --link clickhouse-01:clickhouse-server yandex/clickhouse-client --host clickhouse-server -u user1 --password 123456
