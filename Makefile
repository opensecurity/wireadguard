SHELL := /bin/bash
-include .env
export

.PHONY: all up down logs restart check-env get-root-hints tune-host

all: up

check-env:
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found. Please create it from .env.example."; \
		exit 1; \
	fi

get-root-hints:
	@if [ ! -f ./unbound/root.hints ]; then \
		echo "Downloading root.hints from internic..."; \
		wget https://www.internic.net/domain/named.root -O ./unbound/root.hints; \
	else \
		echo "root.hints file already exists. Skipping download."; \
	fi

up: check-env get-root-hints
	@echo "Forging the system... Starting all services."
	docker compose up --build -d --remove-orphans

down:
	@echo "Decommissioning the system... Stopping all services."
	docker compose down -v

logs:
	@echo "Accessing service chronicles..."
	docker compose logs -f

restart:
	@echo "Re-initiating service protocols..."
	docker compose restart

tune-host:
	@echo "Applying host system tuning for Unbound..."
	sudo sysctl -w net.core.rmem_max=4194304
	sudo sysctl -w net.core.wmem_max=4194304
