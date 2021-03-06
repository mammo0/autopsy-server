DOCKERFILE=Dockerfile
TAG=autopsy

MAIN_TEMPLATE=include/main.docker
SERVER_TEMPLATE=include/server.docker
CLIENT_TEMPLATE=include/client.docker

CURRENT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

.DEFAULT_GOAL := standalone
.PHONY: standalone server build compose clean

standalone: $(MAIN_TEMPLATE) $(CLIENT_TEMPLATE)
	cat $(MAIN_TEMPLATE) > $(DOCKERFILE)
	cat $(CLIENT_TEMPLATE) >> $(DOCKERFILE)

server: $(MAIN_TEMPLATE) $(SERVER_TEMPLATE)
	cat $(MAIN_TEMPLATE) > $(DOCKERFILE)
	cat $(SERVER_TEMPLATE) >> $(DOCKERFILE)

image: standalone
	source $(CURRENT_DIR)/.env && \
	docker build --rm -t $(TAG) -f $(DOCKERFILE) --build-arg AUTOPSY_VERSION=$$AUTOPSY_VERSION \
												 --build-arg SLEUTHKIT_VERSION=$$SLEUTHKIT_VERSION \
 												 --build-arg AUTOPSY_UID=$$BUILD_UID \
												 --build-arg AUTOPSY_GID=$$BUILD_GID .

compose: server
	docker-compose build

clean:
	rm $(DOCKERFILE)
