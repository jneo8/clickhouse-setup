import requests
import time

PROJECT_ID: int = 1
DELETED: int = 0
RETENTION_DAYS: int = 32

insert: str = f"insert into errors_local values ({PROJECT_ID}, now(), {DELETED}, generateUUIDv4(), {RETENTION_DAYS})"
count: str = f"select count(*) from errors_local"

while True:
    print(requests.post(f"http://localhost:8013/?query={insert}"))
    print(requests.get(f"http://localhost:8013/?query={count}").text)
    time.sleep(1.0)
