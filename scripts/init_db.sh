#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

#su - mysql -c mysql_install_db
#su - mysql -c /usr/sbin/mysqld &
mysql_install_db --user=mysql
cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql' &

while 
    /usr/bin/mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
    (( $? != 0 ))
    do
        printf "${YELLOW}Waiting a second for the database to be ready.${NC}\n"; sleep 1
    done

mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $SQE_DATABASE"
printf "${GREEN}✓ Created the database $SQE_DATABASE.${NC}\n"

mysql -u root -p$MYSQL_ROOT_PASSWORD $SQE_DATABASE < /tmp/data/schema.sql
printf "${GREEN}✓ Loaded the schema.${NC}\n"

for f in /tmp/data/tables/*.sql 
    do 
        printf "${BLUE}Loading $f.${NC}\n"
        mysql -u root -p$MYSQL_ROOT_PASSWORD $SQE_DATABASE < $f
        printf "${GREEN}✓ Loaded $f.${NC}\n"
    done