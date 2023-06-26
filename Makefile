start:
	docker compose up -d
stop:
	docker compose down
start-m1:
	docker compose -f docker-compose-m1.yml up -d
stop-m1:
	docker compose -f docker-compose-m1.yml down