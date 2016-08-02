# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER DI GREGORIO Nicolas "nicolas.digregorio@gmail.com"

### Environment variables
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
ENV PG_MAJOR 9.4

### Install Applications DEBIAN_FRONTEND=noninteractive  --no-install-recommends
RUN perl -npe 's/main/main\ contrib\ non-free/' -i /etc/apt/sources.list && \
    apt-get update && \
    groupadd -g 2005 postgres && \
    useradd postgres -u 2005 -g postgres -r -m -d /var/lib/postgresql -s /bin/false && \
    apt-get install -y --no-install-recommends ca-certificates postgresql-common socat wget && \
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
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/*


### Volume
VOLUME ["/var/lib/postgresql/data"]

### Expose ports
EXPOSE 5432

### Running User
USER postgres

### Start postgresql
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
