FROM mariadb:10.3 as builder

RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV MYSQL_ROOT_PASSWORD=none
ENV MYSQL_DATABASE=SQE_DEV

ADD ./affine_transform.c /tmp/affine_transform.c
ADD ./multiply_matrix.c /tmp/multiply_matrix.c
RUN apt-get update \
    && apt-get install -y gcc libmysqlclient-dev \
    && gcc -shared -o `mysql_config --plugindir`/affine_transform.so /tmp/affine_transform.c -I/usr/include/mysql -fPIC -O3 \
    && gcc -shared -o `mysql_config --plugindir`/multiply_matrix.so /tmp/multiply_matrix.c -I/usr/include/mysql -fPIC -O3 \
    && apt-get remove -y gcc libmysqlclient-dev \
    && apt-get -y autoclean \
    && apt-get clean \
    && apt-get -y autoremove

COPY ./data/ /docker-entrypoint-initdb.d/

RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db"]


FROM mariadb:10.3

COPY --from=builder /initialized-db /var/lib/mysql
COPY --from=builder /usr/lib/mysql/plugin/affine_transform.so /usr/lib/mysql/plugin/
COPY --from=builder /usr/lib/mysql/plugin/multiply_matrix.so /usr/lib/mysql/plugin/
RUN echo event_scheduler = 1 >> /etc/mysql/mariadb.cnf