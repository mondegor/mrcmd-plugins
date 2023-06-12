# https://hub.docker.com/_/cassandra
# https://hub.docker.com/r/clickhouse/clickhouse-server
# https://hub.docker.com/r/tarantool/tarantool
# https://hub.docker.com/_/neo4j

function mrcmd_plugins_cassandra_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_cassandra_method_init() {
  readonly CASSANDRA_CAPTION="Cassandra"
  readonly CASSANDRA_DOCKER_SERVICE="db-cassandra"

  readonly CASSANDRA_VARS=(
    "CASSANDRA_DOCKER_CONTAINER"
    "CASSANDRA_DOCKER_CONTEXT_DIR"
    "CASSANDRA_DOCKER_DOCKERFILE"
    "CASSANDRA_DOCKER_COMPOSE_CONFIG_DIR"
    "CASSANDRA_DOCKER_IMAGE"
    "CASSANDRA_DOCKER_IMAGE_FROM"

    "CASSANDRA_DB_PUBLIC_PORT"
    "CASSANDRA_DB_USER"
    "CASSANDRA_DB_PASSWORD"
    "CASSANDRA_DB_NAME"

    "CASSANDRA_LISTEN_ADDRESS"
    "CASSANDRA_BROADCAST_ADDRESS"
    "CASSANDRA_RPC_ADDRESS"
    "CASSANDRA_START_RPC"
    "CASSANDRA_SEEDS"
    "CASSANDRA_CLUSTER_NAME"
    "CASSANDRA_NUM_TOKENS"
    "CASSANDRA_DC"
    "CASSANDRA_RACK"
    "CASSANDRA_ENDPOINT_SNITCH"
  )

  readonly CASSANDRA_VARS_DEFAULT=(
    "${APPX_ID}-db-cassandra"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}cassandra:3.11.15"
    "cassandra:3.11.15"

    "127.0.0.1:9042"
    "cassandra" # user_cs
    "cassandra" # 123456
    "db_cs"

    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
  )

  mrcore_dotenv_init_var_array CASSANDRA_VARS[@] CASSANDRA_VARS_DEFAULT[@]
  mrcmd_plugins_cassandra_db_url_init

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${CASSANDRA_DOCKER_COMPOSE_CONFIG_DIR}/db-cassandra.yaml")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${CASSANDRA_DOCKER_COMPOSE_CONFIG_DIR}/db-cassandra-init.yaml")
}

function mrcmd_plugins_cassandra_method_config() {
  mrcore_dotenv_echo_var_array CASSANDRA_VARS[@]
}

function mrcmd_plugins_cassandra_method_export_config() {
  mrcore_dotenv_export_var_array CASSANDRA_VARS[@]
}

function mrcmd_plugins_cassandra_method_install() {
  mrcmd_plugins_cassandra_docker_build --no-cache
}

function mrcmd_plugins_cassandra_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_cassandra_method_config
      mrcmd_plugins_cassandra_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${CASSANDRA_DOCKER_SERVICE}" \
        cqlsh
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${CASSANDRA_DOCKER_SERVICE}" \
        "bash" # "${DOCKER_DEFAULT_SHELL}"
      ;;

    # nodetool status
    # cqlsh 192.168.0.15

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${CASSANDRA_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${CASSANDRA_DOCKER_CONTAINER}" \
        "${CASSANDRA_DOCKER_SERVICE}"
      ;;

    create-db)
      mrcmd_plugins_cassandra_create_db "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_cassandra_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${CASSANDRA_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${CASSANDRA_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to cassandra cli in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts cassandra containers"
  echo -e "  create-db   Create user and db"
}

# private
function mrcmd_plugins_cassandra_db_url_init() {
  readonly CASSANDRA_DB_URL="cassandra://${CASSANDRA_DB_USER}:${CASSANDRA_DB_PASSWORD}@${CASSANDRA_DOCKER_SERVICE}:9042/${CASSANDRA_DB_NAME}"
  readonly CASSANDRA_DB_URL_JDBC="jdbc:cassandra://${CASSANDRA_DOCKER_SERVICE}:9042/${CASSANDRA_DB_NAME}"
}

# private
function mrcmd_plugins_cassandra_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${CASSANDRA_DOCKER_CONTEXT_DIR}" \
    "${CASSANDRA_DOCKER_DOCKERFILE}" \
    "${CASSANDRA_DOCKER_IMAGE}" \
    "${CASSANDRA_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_cassandra_create_db() {
  local dbUser="${1-}"
  local dbPassword="${2-}"
  local dbName="${3-}"

  mrcore_validate_value_required "User name" "${dbUser}"
  mrcore_validate_value_required "User password" "${dbPassword}"
  mrcore_validate_value_required "DB name" "${dbName}"

#  mrcmd_plugins_call_function "docker-compose/command" exec \
#    "${CASSANDRA_DOCKER_SERVICE}" psql -U "${CASSANDRA_DB_ROOT_USER}" \
#    -c "CREATE DATABASE ${dbName};"
#
#  mrcmd_plugins_call_function "docker-compose/command" exec \
#    "${CASSANDRA_DOCKER_SERVICE}" psql -U "${CASSANDRA_DB_ROOT_USER}" \
#    -c "CREATE USER ${dbUser};GRANT ALL PRIVILEGES ON DATABASE ${dbName} TO ${dbUser};ALTER USER ${dbUser} WITH PASSWORD '${dbPassword}';"

#user: cassandra
#password: cassandra
#
# CREATE KEYSPACE mydatebase
#  WITH REPLICATION = {
#   'class' : 'SimpleStrategy',
#   'replication_factor' : 1
#  };
#
#  create table mydatebase.employee (id int primary key, firstname varchar, lastname varchar);
#  insert into mydatebase.employee (id, firstname, lastname) values (1, 'Ivan', 'Ivanov');
#  update mydatebase.employee set firstname='Vasiliy' where id = 3
#
#  select * from mydatebase.employee;
#
#  alter table mydatebase.employee add age int;
#
#
#  insert/update - одна и таже операция
}
