# https://github.com/getsentry/self-hosted/releases

function mrcmd_plugins_sentry_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "vendor")
}

function mrcmd_plugins_sentry_method_init() {
  readonly SENTRY_CAPTION="Self-Hosted Sentry"

  readonly SENTRY_VARS=(
    "SENTRY_SOURCE_URL"
    "SENTRY_ENV_FILE"

    "SENTRY_WEBAPP_PUBLIC_PORT"

    "SENTRY_EVENT_RETENTION_DAYS"
    "SENTRY_INSTALL_SKIP_USER_CREATION"
    "SENTRY_SEND_REPORTS"
  )

  readonly SENTRY_VARS_DEFAULT=(
    "https://github.com/getsentry/self-hosted/archive/refs/tags/23.4.0.zip"
    "${APPX_WORK_DIR}/.env.custom"

    "127.0.0.1:9050"

    "90"
    "false"
    "false"
  )

  mrcore_dotenv_init_var_array SENTRY_VARS[@] SENTRY_VARS_DEFAULT[@]
}

function mrcmd_plugins_sentry_method_config() {
  mrcore_dotenv_echo_var_array SENTRY_VARS[@]
}

function mrcmd_plugins_sentry_method_export_config() {
  mrcore_dotenv_export_var_array SENTRY_VARS[@]
}

function mrcmd_plugins_sentry_method_install() {
  if [ ! -e "${APPX_WORK_DIR}" ]; then
    mrcmd_plugins_call_function "vendor/package-get" "${SENTRY_SOURCE_URL}" "${APPX_WORK_DIR}"
  fi

  mrcmd_plugins_sentry_create_custom_env

  local flags=""

  if [[ "${SENTRY_INSTALL_SKIP_USER_CREATION}" == true ]]; then
    flags="${flags}${CMD_SEPARATOR}--skip-user-creation"
  fi

  cd "${APPX_WORK_DIR}"
  ./install.sh ${flags}
  cd "${APPX_DIR_REAL}"
}

function mrcmd_plugins_sentry_method_start() {
  mrcmd_plugins_sentry_create_custom_env
  mrcmd_plugins_sentry_docker_compose up -d --remove-orphans
}

function mrcmd_plugins_sentry_method_stop() {
  mrcmd_plugins_sentry_docker_compose down --remove-orphans
}

function mrcmd_plugins_sentry_method_uninstall() {
  mrcmd_plugins_sentry_docker_compose down -v --remove-orphans --rmi=all
  mrcore_lib_rmdir "${APPX_WORK_DIR}"
}

function mrcmd_plugins_sentry_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    conf)
      mrcmd_plugins_sentry_docker_compose config
      ;;

    ps)
      mrcmd_plugins_sentry_docker_compose ps
      ;;

    logs)
      mrcmd_plugins_sentry_docker_compose logs --follow
      ;;

    create-user)
      mrcmd_plugins_sentry_docker_compose run --rm web createuser
      ;;

  esac
}

function mrcmd_plugins_sentry_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker compose commands:${CC_END}"
  echo -e "  conf                docker-compose config"
  echo -e "  ps                  docker-compose ps"
  echo -e "  logs                docker-compose logs --follow"
  echo -e "  create-user         Create user for access to panel"
}

# private
function mrcmd_plugins_sentry_create_custom_env() {
  cp "${APPX_WORK_DIR}/.env" "${SENTRY_ENV_FILE}"

  echo -e "\n# exported from ${MRCMD_INFO_NAME} plugin
COMPOSE_PROJECT_NAME=${APPX_ID}
SENTRY_EVENT_RETENTION_DAYS=${SENTRY_EVENT_RETENTION_DAYS}
SENTRY_BIND=${SENTRY_WEBAPP_PUBLIC_PORT}
SENTRY_BEACON=False
REPORT_SELF_HOSTED_ISSUES=$(mrcore_lib_flag_to_int "${SENTRY_SEND_REPORTS}")" >> "${SENTRY_ENV_FILE}"
}

# private
function mrcmd_plugins_sentry_docker_compose() {
  docker compose -p "${APPX_ID}" --env-file "${SENTRY_ENV_FILE}" -f "${APPX_WORK_DIR}/docker-compose.yml" "$@"
}
