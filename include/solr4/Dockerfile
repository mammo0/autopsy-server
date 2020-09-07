# This file was adapted from https://github.com/docker-solr/docker-solr4
FROM openjdk:8-jre

# Some configuration files of the Autopsy package are needed for Solr
ARG AUTOPSY_VERSION=4.15.0
ARG AUTOPSY_PACKAGE=autopsy-$AUTOPSY_VERSION.zip

# build arguments
ARG SOLR_USER="solr"
ARG SOLR_UID="8983"
ARG SOLR_GROUP="solr"
ARG SOLR_GID="8983"
ARG SOLR_VERSION="4.10.4"
ARG SOLR_URL="${SOLR_DOWNLOAD_SERVER:-https://archive.apache.org/dist/lucene/solr}/4.10.4/solr-4.10.4.tgz"
ARG SOLR_SHA256="ac3543880f1b591bcaa962d7508b528d7b42e2b5548386197940b704629ae851"

ENV PATH="/opt/solr/bin:/opt/docker-solr/scripts:$PATH"


# install dependencies
RUN apt-get update && \
    apt-get -y install lsof procps wget gpg unzip && \
    rm -rf /var/lib/apt/lists/*

# add the Solr user
RUN groupadd -r --gid $SOLR_GID $SOLR_GROUP && \
  useradd -r --uid $SOLR_UID --gid $SOLR_GID $SOLR_USER

# install Solr
RUN mkdir -p /opt/solr && \
    echo "downloading $SOLR_URL" && \
    wget -nv $SOLR_URL -O /opt/solr.tgz && \
    echo "downloading $SOLR_URL.asc" && \
    wget -nv $SOLR_URL.asc -O /opt/solr.tgz.asc && \
    echo "$SOLR_SHA256 */opt/solr.tgz" | sha256sum -c - && \
    (>&2 ls -l /opt/solr.tgz /opt/solr.tgz.asc) && \
    tar -C /opt/solr --extract --file /opt/solr.tgz --strip-components=1 && \
    rm /opt/solr.tgz* && \
    rm -Rf /opt/solr/docs/ && \
    mkdir -p /opt/solr/server/solr/lib /opt/solr/server/solr/mycores /opt/solr/server/logs /docker-entrypoint-initdb.d /opt/docker-solr && \
    sed -i -e 's/"\$(whoami)" == "root"/$(id -u) == 0/' /opt/solr/bin/solr && \
    sed -i -e 's/lsof -PniTCP:/lsof -t -PniTCP:/' /opt/solr/bin/solr && \
    sed -i -e '/-Dsolr.clustering.enabled=true/ a SOLR_OPTS="$SOLR_OPTS -Dsun.net.inetaddr.ttl=60 -Dsun.net.inetaddr.negative.ttl=60"' /opt/solr/bin/solr.in.sh && \
    chown -R $SOLR_USER:$SOLR_GROUP /opt/solr

COPY scripts /opt/docker-solr/scripts
RUN chown -R $SOLR_USER:$SOLR_GROUP /opt/docker-solr


# copy the custom Autopsy config files
COPY config/solr.xml /opt/solr/solr_autopsy/
COPY config/log4j.properties /opt/solr/server/resources/

# copy more config files from the Autopsy package
RUN cd /opt && \
    wget https://github.com/sleuthkit/autopsy/releases/download/autopsy-$AUTOPSY_VERSION/$AUTOPSY_PACKAGE && \
    unzip $AUTOPSY_PACKAGE && \
    rm $AUTOPSY_PACKAGE && \
    mv autopsy-$AUTOPSY_VERSION/autopsy/solr/solr/configsets solr/solr_autopsy/ && \
    mv autopsy-$AUTOPSY_VERSION/autopsy/solr/lib solr/solr_autopsy/ && \
    mv autopsy-$AUTOPSY_VERSION/autopsy/solr/solr/zoo.cfg solr/solr_autopsy/ && \
    rm -rf autopsy-$AUTOPSY_VERSION && \
    chown -R $SOLR_USER:$SOLR_GROUP /opt/solr


EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground", \
        "-s", "/opt/solr/solr_autopsy", \
        "-a", "-Dcollection.configName=AutopsyConfig -Dbootstrap_confdir=/opt/solr/solr_autopsy/configsets/AutopsyConfig/conf -DzkRun"]
