# [Autopsy](https://github.com/sleuthkit/autopsy) Server

This repository helps to setup a multi-user Autopsy environment with `docker-compose`. It automates the setps of the official Autopsy documentation to create
 1. a server that can be used for automated ingest and
 2. the corresponding client for examination.




## Configuration (optional)
For Autopsy to work probably it's necessary that the server as well as the client have access to two directories with write permissions:
 - shared **cases** folder and
 - shared **images** folder

The easiest way to accomplish this is to use Docker volumes that have a bind mount to those directories. To use already created Docker volumes for the server, please edit the `docker-compose.yml` file:

In the `volumes` section at the bottom in that file change `autopsy_cases: {}` to
```yml
autopsy_cases:
    external: true
    name: <name of the existing cases volume>
```
and `autopsy_images: {}` to
```yml
autopsy_images:
    external: true
    name: <name of the existing images volume>
```

If those directories are owned by a special user (`UID != 1000`), edit the `.env` file: Change `BUILD_UID` and `BUILD_GID` to the ones of the corresponding user.



## Image building
### Server image(s)
To build the necessary images for the server operation:

```shell
make compose
```


### Client image
To build the client image:
```shell
make image
```



## Usage
### Server
To start everything:
```shell
docker-compose up -d
```

Afterwards the server application can be accessed via VNC on port `5911`. (The port can be changed in the `docker-compose.yml` file.)

**This VNC connection is unsecured!** To add a VNC password, add the following section to the `autopsy-server` section in the `docker-compose.yml` file:
```yml
environment:
    - VNC_PASSWORD=<your password>
```


### Client
To start the client:
```shell
docker run -d \
    --name=autopsy \
    -p "5901:5901" \
    -v <cases volume>:/cases \
    -v <images volume>:/images \
    -e VNC_PASSWORD=<your password>
    autopsy
```

Note that the two volumes must contain the same data as the ones for the server (see configuration section above).

Also like the server the Autopsy GUI of the client can be accessed via VNC. It's recommended to set a VNC password!
