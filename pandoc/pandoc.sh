# https://pandoc.org
# https://hub.docker.com/_/ubuntu
# https://hub.docker.com/r/pandoc/latex
# https://pandoc.org/MANUAL.html#templates
# https://ru.wikibooks.org/wiki/LaTeX

function mrcmd_plugins_pandoc_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_pandoc_method_init() {
  readonly PANDOC_CAPTION="Pandoc"

  readonly PANDOC_VARS=(
    "PANDOC_DOCKER_CONTEXT_DIR"
    "PANDOC_DOCKER_DOCKERFILE"
    "PANDOC_DOCKER_IMAGE"
    "PANDOC_DOCKER_IMAGE_FROM"
  )

  readonly PANDOC_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}pandoc:2.5"
    "ubuntu:20.04"
  )

  mrcore_dotenv_init_var_array PANDOC_VARS[@] PANDOC_VARS_DEFAULT[@]
}

function mrcmd_plugins_pandoc_method_config() {
  mrcore_dotenv_echo_var_array PANDOC_VARS[@]
}

function mrcmd_plugins_pandoc_method_export_config() {
  mrcore_dotenv_export_var_array PANDOC_VARS[@]
}

function mrcmd_plugins_pandoc_method_install() {
  mrcmd_plugins_pandoc_docker_build --no-cache
}

function mrcmd_plugins_pandoc_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_pandoc_method_config
      mrcmd_plugins_pandoc_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "pandoc/docker-run" "$@"
      ;;

    md2html)
      local docName="${1:?}"
      shift
      mrcmd_plugins_call_function "pandoc/docker-run" -f markdown -t html "$@" --output=${docName}.html --css=pandoc/markdown.css --metadata pagetitle=Doc --standalone
      ;;

    md2html-c)
      local docName="${1:?}"
      shift
      mrcmd_plugins_call_function "pandoc/docker-run" -f markdown -t html "$@" --output=${docName}.html --css=pandoc/markdown.css --metadata pagetitle=Doc --self-contained
      ;;

    md2pdf)
      local docName="${1:?}"
      shift
      mrcmd_plugins_call_function "pandoc/docker-run" -f markdown -t latex pandoc/header-latex.md "$@" --output=${docName}.pdf
      ;;

    md-html2pdf)
      local docName="${1:?}"
      shift
      mrcmd_plugins_call_function "pandoc/docker-run" -f markdown -t html5 "$@" --output=${docName}.pdf --metadata pagetitle=Doc --pdf-engine-opt=--enable-local-file-access --css=pandoc/markdown.css
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_pandoc_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${PANDOC_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build                Builds or rebuilds the image"
  echo -e "  cmd [arguments]             Runs 'pandoc [arguments]' in a container of the image"
  echo -e "  md2html [name] [files]      Runs 'pandoc [files] --output=[name].html'"
  echo -e "  md2html-c [name] [files]    Runs 'pandoc [files] --output=[name].html'"
  echo -e "  md2pdf [name] [files]       Runs 'pandoc [files] --output=[name].pdf'"
  echo -e "  md-html2pdf [name] [files]  Runs pandoc [files] to pdf with wkhtmltopdf"
}

# private
function mrcmd_plugins_pandoc_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${PANDOC_DOCKER_CONTEXT_DIR}" \
    "${PANDOC_DOCKER_DOCKERFILE}" \
    "${PANDOC_DOCKER_IMAGE}" \
    "${PANDOC_DOCKER_IMAGE_FROM}" \
    "$@"
}
