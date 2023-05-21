
# run: mrcmd_plugins_call_function "mvn/docker-run-workdir"
function mrcmd_func_mvn_docker_run_workdir() {
  local oldAppxWorkDir="${APPX_WORK_DIR}"
  APPX_WORK_DIR="${1:?}"
  shift

  mrcmd_plugins_call_function "mvn/docker-run" "$@"

  APPX_WORK_DIR="${oldAppxWorkDir}"
}
