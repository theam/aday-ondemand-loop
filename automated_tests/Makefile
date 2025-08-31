include ../tools/make/ood_versions.mk

CYPRESS_IMAGE ?= cypress/included:13.6.4
PROJECT_NAME ?= loop_atests
COMPOSE_CMD = docker compose
ENV := env OOD_IMAGE=$(OOD_IMAGE) OOD_UID=$(OOD_UID) OOD_GID=$(OOD_GID)

.PHONY: atest_up atest_down cypress cypress_open

atest_up: atest_down
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -p $(PROJECT_NAME) up --build || :

atest_down:
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -p $(PROJECT_NAME) down -v || :

cypress:
	docker run --rm -it \
		--network $${PROJECT_NAME}_default \
		-e CYPRESS_baseUrl=https://ood \
		-e NODE_TLS_REJECT_UNAUTHORIZED=0 \
		-v $$(PWD):/e2e \
		-w /e2e \
		$${CYPRESS_IMAGE} \
		cypress run

cypress_open:
	docker run --rm -it \
		--network $${PROJECT_NAME}_default \
		-e CYPRESS_baseUrl=https://ood \
		-e NODE_TLS_REJECT_UNAUTHORIZED=0 \
		-v $$(PWD):/e2e \
		-w /e2e \
		--entrypoint=cypress \
		$${CYPRESS_IMAGE} open
