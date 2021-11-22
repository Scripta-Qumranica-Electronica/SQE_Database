FROM mariadb:10.3

# Install OQGraph
RUN apt-get update \
    && apt-get install -y mariadb-plugin-oqgraph

## Copy in the saved SQE data
COPY data /backup
RUN mariabackup --prepare --target-dir=/backup \
    && mariabackup --copy-back --target-dir=/backup \
    && chown -R mysql:mysql /var/lib/mysql

## Copy a new entrypoint script
COPY ./scripts/startup.sh /startup.sh

## Just inject the necessary event scheduler here (no need for a complete custom my.cnf)
RUN printf "event_scheduler = 1\ntransaction-isolation = READ-COMMITTED" >> /etc/mysql/mariadb.cnf

## Use our new entrypoint, which will pickup runtime password and user account settings
ENTRYPOINT [ "/startup.sh" ]
CMD [ "mysqld" ]