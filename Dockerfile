FROM mariadb:10.3 as builder

## Hijack docker-entrypoint.sh so we can do a custom install
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

## Defaults for setup stage
ENV MYSQL_ROOT_PASSWORD=none
ENV MYSQL_DATABASE=SQE


## Build UDFs and install them
COPY ./geom_transform.c /tmp/geom_transform.c
COPY ./nested_geom_transform.c /tmp/nested_geom_transform.c
RUN apt-get update \
    && apt-get install -y gcc libmariadb-dev mariadb-plugin-oqgraph \
    && gcc -shared -o /usr/lib/mysql/plugin/geom_transform.so /tmp/geom_transform.c  -I/usr/include/mariadb -fPIC -O3 \
    && gcc -shared -o /usr/lib/mysql/plugin/nested_geom_transform.so /tmp/nested_geom_transform.c -I/usr/include/mariadb -fPIC -O3 \
    && apt-get remove -y gcc libmysqlclient-dev \
    && apt-get -y autoclean \
    && apt-get clean \
    && apt-get -y autoremove

## Copy in our sql data
COPY ./data/ /docker-entrypoint-initdb.d/

## Now run the docker-entrypoint.sh and use a custom install dir
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db"]


## Second build stage
FROM mariadb:10.3

## Copy data from last build stage
COPY --from=builder /initialized-db /var/lib/mysql
COPY --from=builder /usr/lib/mysql/plugin/geom_transform.so /usr/lib/mysql/plugin/
COPY --from=builder /usr/lib/mysql/plugin/nested_geom_transform.so /usr/lib/mysql/plugin/

## Copy a new entrypoint script
COPY ./startup.sh /startup.sh

## Just inject the necessary event scheduler here (no need for a complete custom my.cnf)
RUN printf "event_scheduler = 1\ntransaction-isolation = READ-COMMITTED" >> /etc/mysql/mariadb.cnf

## Use our new entrypoint, which will pickup runtime password and user account settings
ENTRYPOINT [ "/startup.sh" ]
CMD [ "mysqld" ]