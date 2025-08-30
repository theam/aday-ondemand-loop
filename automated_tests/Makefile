CYPRESS_IMAGE ?= cypress/included:13.6.4
PROJECT_NAME ?= loop_atests

.PHONY: cypress cypress_open

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
