#!/bin/bash
set -eo pipefail
shopt -s nullglob

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

# skip setup if they want an option that stops mysqld
wantHelp=
for arg; do
	case "$arg" in
		-'?'|--help|--print-defaults|-V|--version)
			wantHelp=1
			break
			;;
	esac
done

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

_check_config() {
	toRun=( "$@" --verbose --help --log-bin-index="$(mktemp -u)" )
	if ! errors="$("${toRun[@]}" 2>&1 >/dev/null)"; then
		cat >&2 <<-EOM
			ERROR: mysqld failed while attempting to check config
			command was: "${toRun[*]}"
			$errors
		EOM
		exit 1
	fi
}

# Fetch value from server config
# We use mysqld --verbose --help instead of my_print_defaults because the
# latter only show values present in config files, and not server defaults
_get_config() {
	local conf="$1"; shift
	"$@" --verbose --help --log-bin-index="$(mktemp -u)" 2>/dev/null \
		| awk '$1 == "'"$conf"'" && /^[^ \t]/ { sub(/^[^ \t]+[ \t]+/, ""); print; exit }'
	# match "datadir      /some/path with/spaces in/it here" but not "--xyz=abc\n     datadir (xyz)"
}

# allow the container to be started with `--user`
if [ "$1" = 'mysqld' -a -z "$wantHelp" -a "$(id -u)" = '0' ]; then
	_check_config "$@"
	DATADIR="$(_get_config 'datadir' "$@")"
	mkdir -p "$DATADIR"
	find "$DATADIR" \! -user mysql -exec chown mysql '{}' +
	exec gosu mysql "$BASH_SOURCE" "$@"
fi

## Start the database server
echo "Starting the init database"
exec "$@" &
pid="$!"

## Wait till the server is running
echo "Waiting for the init database to start"
while ! mysqladmin -u root -pnone status && ! mysqladmin -u root -p$MYSQL_ROOT_PASSWORD status
#while ! lsof -i :3306
do
   sleep 1
done

## Reset the root password if MYSQL_ROOT_PASSWORD is set
echo "Checking if root password should be reset"
if [ "$MYSQL_ROOT_PASSWORD" ]; then
    if ! mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"; then
        echo "Resetting the root password"
        mysql -u root -pnone -e "USE mysql; SET PASSWORD FOR 'root'@'%' = PASSWORD('$MYSQL_ROOT_PASSWORD'); FLUSH PRIVILEGES;"
        mysql -u root -pnone -e "USE mysql; SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD'); FLUSH PRIVILEGES;"
    fi
else export MYSQL_ROOT_PASSWORD="none"
fi

## Setup a user account if MYSQL_USER and MYSQL_PASSWORD are set
echo "Checking if user + password should be added"
if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
    if ! mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SELECT 1"; then
        echo "Setting up initial user account"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL ON \`SQE\`.* TO '$MYSQL_USER'@'%' ;"
    fi
fi

## End the init sequence
echo "Killing the init database"
if ! kill -s TERM "$pid" || ! wait "$pid"; then
    echo >&2 'MySQL init process failed.'
    exit 1
fi

## Startup the runtime instance as specified on the command line
echo "Starting the runtime database"
exec "$@"