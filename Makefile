SHELL := /bin/bash
include .env

.PHONY: backend.updateRoles

install:
	sudo apt-get update
	sudo apt-get install unzip build-essential apt-transport-https ca-certificates curl gnupg lsb-release -y
	apt -y install docker.io docker-compose

ports:
	sudo iptables -I INPUT -p tcp -m tcp --dport ${BACKEND_PORT} -j ACCEPT
	sudo iptables -I INPUT -p tcp -m tcp --dport 8000 -j ACCEPT

env:
	cp backend/.env.example backend/.env

build:
	docker-compose build
	docker-compose up -d
	docker-compose exec php chown -R www-data:www-data .
	docker-compose exec php composer install --optimize-autoloader --no-dev
	docker-compose exec php php artisan migrate
	docker-compose exec php php artisan db:seed
	docker-compose exec php php artisan jwt:secret
	docker-compose exec php php artisan key:generate
	docker-compose exec php php artisan config:cache
	docker-compose exec php php artisan route:cache
	docker-compose exec php chown -R www-data:www-data .

build.backend:
	docker-compose exec php chown -R www-data:www-data .
	docker-compose exec php composer install
	docker-compose exec php php artisan migrate
	docker-compose exec php php artisan db:seed
	docker-compose exec php chmod -R 775 storage/

restart:
	docker-compose restart

stop:
	docker-compose stop

down:
	docker-compose down -v

backend.updateRoles:
	docker-compose exec php php artisan db:seed RolesSeeder
	docker-compose exec php php artisan cache:forget spatie.permission.cache￼Enter
