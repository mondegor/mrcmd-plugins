# https://hub.docker.com/_/postgres

function mrcmd_plugins_postgres_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_postgres_method_init() {
  export POSTGRES_DOCKER_SERVICE="db-postgres"

  readonly POSTGRES_CAPTION="Postgres"

  readonly POSTGRES_VARS=(
    "POSTGRES_DOCKER_CONTAINER"
    "POSTGRES_DOCKER_CONTEXT_DIR"
    "POSTGRES_DOCKER_DOCKERFILE"
    "POSTGRES_DOCKER_COMPOSE_CONFIG_DIR"
    "POSTGRES_DOCKER_IMAGE"
    "POSTGRES_DOCKER_IMAGE_FROM"

    ##### "POSTGRES_DB_PUBLIC_PORT"
    ##### "POSTGRES_DB_DOMAIN"
    "POSTGRES_DB_USER"
    "POSTGRES_DB_PASSWORD"
    "POSTGRES_DB_NAME"
  )

  readonly POSTGRES_VARS_DEFAULT=(
    "${APPX_ID}-${POSTGRES_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}postgres:15.7"
    "postgres:15.7-alpine3.20"

    ##### "127.0.0.1:5432"
    ##### "postrges.db.local"
    "user_pg"
    "123456"
    "db_pg"
  )

  mrcore_dotenv_init_var_array POSTGRES_VARS[@] POSTGRES_VARS_DEFAULT[@]
  mrcmd_plugins_postgres_db_dsn_init

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${POSTGRES_DOCKER_COMPOSE_CONFIG_DIR}/db-postgres.yaml")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${POSTGRES_DOCKER_COMPOSE_CONFIG_DIR}/db-postgres-init.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${POSTGRES_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_postgres_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_postgres_method_config() {
  mrcore_dotenv_echo_var_array POSTGRES_VARS[@]
  mrcore_echo_var "POSTGRES_DOCKER_SERVICE (host, readonly)" "${POSTGRES_DOCKER_SERVICE}"
  mrcore_echo_var "POSTGRES_DB_DSN (readonly)" "${POSTGRES_DB_DSN}"
  mrcore_echo_var "POSTGRES_DB_URL_JDBC (readonly)" "${POSTGRES_DB_URL_JDBC}"
}

function mrcmd_plugins_postgres_method_export_config() {
  mrcore_dotenv_export_var_array POSTGRES_VARS[@]
}

function mrcmd_plugins_postgres_method_install() {
  mrcmd_plugins_postgres_docker_build --no-cache
}

function mrcmd_plugins_postgres_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_postgres_method_config
      mrcmd_plugins_postgres_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${POSTGRES_DOCKER_SERVICE}" \
        psql \
        -U "${POSTGRES_DB_USER}" \
        -d "${POSTGRES_DB_NAME}"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${POSTGRES_DOCKER_SERVICE}" \
        bash # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${POSTGRES_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${POSTGRES_DOCKER_CONTAINER}" \
        "${POSTGRES_DOCKER_SERVICE}"
      ;;

    dump)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        --env PGPASSWORD="${POSTGRES_DB_PASSWORD}" \
        "${POSTGRES_DOCKER_SERVICE}" \
        pg_dump --rows-per-insert=1024 \
        -U "${POSTGRES_DB_USER}" \
        -d "${POSTGRES_DB_NAME}" > "./postgres_${POSTGRES_DB_NAME}_$(date +'%Y-%m-%d-%H-%M-%S').dump.sql"
      ;;

    create-db)
      mrcmd_plugins_postgres_create_db "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_postgres_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${POSTGRES_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${POSTGRES_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to postgres cli in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
  echo -e "  dump        Export db's dump to ${CC_BLUE}./${CC_END}"
  echo -e "  create-db   Create user and db"
}

# private
function mrcmd_plugins_postgres_db_dsn_init() {
  readonly POSTGRES_DB_DSN="postgres://${POSTGRES_DB_USER}:${POSTGRES_DB_PASSWORD}@${POSTGRES_DOCKER_SERVICE}:5432/${POSTGRES_DB_NAME}?sslmode=disable"
  readonly POSTGRES_DB_URL_JDBC="jdbc:postgresql://${POSTGRES_DOCKER_SERVICE}:5432/${POSTGRES_DB_NAME}"
}

# private
function mrcmd_plugins_postgres_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${POSTGRES_DOCKER_CONTEXT_DIR}" \
    "${POSTGRES_DOCKER_DOCKERFILE}" \
    "${POSTGRES_DOCKER_IMAGE}" \
    "${POSTGRES_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_postgres_create_db() {
  local dbUser="${1-}"
  local dbPassword="${2-}"
  local dbName="${3-}"

  mrcore_validate_value_required "User name" "${dbUser}"
  mrcore_validate_value_required "User password" "${dbPassword}"
  mrcore_validate_value_required "DB name" "${dbName}"

  mrcmd_plugins_call_function "docker-compose/command" exec \
    "${POSTGRES_DOCKER_SERVICE}" psql -U "${POSTGRES_DB_ROOT_USER}" \
    -c "CREATE DATABASE ${dbName};"

  mrcmd_plugins_call_function "docker-compose/command" exec \
    "${POSTGRES_DOCKER_SERVICE}" psql -U "${POSTGRES_DB_ROOT_USER}" \
    -c "CREATE USER ${dbUser};GRANT ALL PRIVILEGES ON DATABASE ${dbName} TO ${dbUser};ALTER USER ${dbUser} WITH PASSWORD '${dbPassword}';"
}
