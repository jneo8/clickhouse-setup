import requests
import time

PROJECT_ID: int = 1
DELETED: int = 0
RETENTION_DAYS: int = 32

query: str = f"insert into errors_dist values ({PROJECT_ID}, now(), {DELETED}, generateUUIDv4(), {RETENTION_DAYS})"

while True:
    print(requests.post(f"http://localhost:8123/?query={query}"))
    time.sleep(1.0)
