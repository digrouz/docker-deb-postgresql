FROM debian:jessie
LABEL maintainer "DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>"

### Environment variables
ENV PG_MAJOR 9.4
ENV GOSU_VERSION 1.9
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

### Install Applications DEBIAN_FRONTEND=noninteractive  --no-install-recommends
RUN perl -npe 's/main/main\ contrib\ non-free/' -i /etc/apt/sources.list && \
    apt-get update && \
    groupadd -g 2005 postgres && \
    useradd postgres -u 2005 -g postgres -r -m -d /var/lib/postgresql -s /bin/false && \
    apt-get install -y --no-install-recommends ca-certificates postgresql-common wget && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"  && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install -y --no-install-recommends postgresql postgresql-contrib && \
    wget --no-check-certificate https://raw.githubusercontent.com/digrouz/docker-deb-postgresql/master/docker-entrypoint.sh -O /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir -p /var/run/postgresql && \
    chown -R postgres /var/run/postgresql && \
    mv -v /usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample /usr/share/postgresql/ && \
    ln -sv ../postgresql.conf.sample /usr/share/postgresql/$PG_MAJOR/ && \
    sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample && \
    apt-get -y autoclean && \ 
    apt-get -y clean && \
    apt-get -y autoremove && \
    ln -s /usr/local/bin/docker-entrypoint.sh / && \
    gosu nobody true && \
    apt-get purge -y --auto-remove ca-certificates wget && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/*


### Volume
VOLUME ["/var/lib/postgresql/data"]

### Expose ports
EXPOSE 5432

### Start postgresql
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["postgres"]
