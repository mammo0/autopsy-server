DOCKERFILE=Dockerfile
TAG=autopsy

MAIN_TEMPLATE=include/main.docker
SERVER_TEMPLATE=include/server.docker

.DEFAULT_GOAL := standalone
.PHONY: standalone server build compose clean

standalone: $(MAIN_TEMPLATE)
	cat $(MAIN_TEMPLATE) > $(DOCKERFILE)

server: $(MAIN_TEMPLATE) $(SERVER_TEMPLATE)
	cat $(MAIN_TEMPLATE) > $(DOCKERFILE)
	cat $(SERVER_TEMPLATE) >> $(DOCKERFILE)

image: standalone
	docker build --rm -t $(TAG) -f $(DOCKERFILE) .

compose: server
	docker-compose build

clean:
	rm $(DOCKERFILE)
