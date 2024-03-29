#!/usr/bin/env sh
set -e
# 8 ANSI colors
TEXT_COLOR_BLACK=30
TEXT_COLOR_RED=31
TEXT_COLOR_GREEN=32
TEXT_COLOR_BROWN=33
TEXT_COLOR_BLUE=34
TEXT_COLOR_PURPLE=35
TEXT_COLOR_CYAN=36
TEXT_COLOR_GRAY=37
TEXT_COLOR_DEFAULT=0

# 4 ANSI text formats
TEXT_FORMAT_NORMAL=0
TEXT_FORMAT_BOLD=1
TEXT_FORMAT_UNDERLINE=4
TEXT_FORMAT_BLINKING=5

INTERNAL_IMAGE_NAME=numbers-api:latest

colored_line() {
    # usage: colored_line <format> <color> <message>...
    local COLOR=""
    local RESET=""
    if [ -t 1 ]; then
        COLOR="\e[${1};${2}m"
        RESET="\e[m"
    fi
    shift; shift
    printf "${COLOR}"
    local prefix=""
    for part in "$@"; do
        printf "%s" "${prefix}${part}"
        prefix=" "
    done
    printf "${RESET}"
}

colored_text() {
    # usage: colored_text <format> <color> <message>...
    colored_line "$@"
    printf "\n"
}

command_text() {
    # Display a CLI command
    local COLOR=""
    local RESET=""
    if [ -t 1 ]; then
        COLOR="\e[${TEXT_FORMAT_BOLD};${TEXT_COLOR_GREEN}m"
        RESET="\e[m"
    fi
    printf "${COLOR}==>> ${RESET}"
    colored_text ${TEXT_FORMAT_BOLD} ${TEXT_COLOR_BLUE} "$@"
}

info_text() {
    # Display a regular message
    colored_text ${TEXT_FORMAT_NORMAL} ${TEXT_COLOR_GREEN} "$@"
}

box_text(){
    local LAYOUT=${1}
    shift
    local template="$@xxxx"
    local delimeter=${replace:-=}
    ${LAYOUT} "${template//?/${delimeter}}"
    ${LAYOUT} "${delimeter} $@ ${delimeter}"
    ${LAYOUT} "${template//?/${delimeter}}"
}

info_box() {
    # Display an important message
     box_text info_text "$@"
}

error_text() {
    # Display an error message within a single-line log
    colored_text ${TEXT_FORMAT_BOLD} ${TEXT_COLOR_RED} "$@"
}

error_box() {
    # Display an error message within a multi-line log
    box_text error_text "$@"
}

question_text() {
    # Display a question on current cursor's line
    colored_line ${TEXT_FORMAT_NORMAL} ${TEXT_COLOR_PURPLE} "$@"
}

verbose_execution() {
    command_text "$@"
    "$@"
}

style_code() {
    info_box "Formatting Python code ..."
    verbose_execution python -m isort --multi-line 3 --trailing-comma --line-length 120 thenumbers tests
    verbose_execution python -m black --line-length 120 thenumbers tests
}

assess_black(){ verbose_execution python -m black --check thenumbers tests; }
assess_isort(){ verbose_execution python -m isort --multi-line 3 --trailing-comma --line-length 120 --check-only thenumbers tests; }
assess_flake(){ verbose_execution python -m flake8 thenumbers; }
assess_mypy() { verbose_execution python -m mypy thenumbers; }
assess_tests(){ verbose_execution python -m pytest tests; }

assess_code() {
    info_box "Running all Python's code verifications..."
    local fail
    for command in assess_black assess_isort assess_mypy assess_flake assess_tests; do
        "${command}" || fail+="${command}, "
    done
    if [ -n "${fail}" ]; then
        error_box "The code verification is failed!!!"
        error_text "Failed commands: ${fail}"
        error_text "Please check the output above to find a reason."
        exit 1
    fi
}

install_all_packages() {
    info_box "Configuring development environment..."
    verbose_execution python -m pip install -r requirements.txt
    verbose_execution python -m pip install -r requirements-test.txt
}

build_ci_image() {
    verbose_execution docker build \
        --no-cache \
        --tag ${INTERNAL_IMAGE_NAME} \
        --label commit=$(git rev-parse @) \
        --label branch=$(git rev-parse --abbrev-ref @) \
        --label version=$(git describe 2>/dev/null | echo "unknown") \
        .
}

build_dev_image() {
    verbose_execution docker build \
        --tag ${INTERNAL_IMAGE_NAME} \
        .
}

assess_image_code() {
     verbose_execution docker run --rm --user root \
            -v $(pwd)/tests:/home/thenumbers/tests \
            -v $(pwd)/.flake8:/home/thenumbers/.flake8 \
            -v $(pwd)/.isort.cfg:/home/thenumbers/.isort.cfg \
            -v $(pwd)/requirements-test.txt:/home/thenumbers/requirements-test.txt \
            -v $(pwd)/workflows.sh:/home/thenumbers/workflows.sh \
            --workdir /home/thenumbers \
            --entrypoint ./workflows.sh \
            ${INTERNAL_IMAGE_NAME} \
            "apk add --virtual .build-deps gcc musl-dev sudo" \
            "sudo --user thenumbers sh" \
            "python -m pip install --user --no-cache-dir --no-warn-script-location -r requirements-test.txt" \
            assess_code
}

assess_image_health(){
    local container=test
    info_text "Starting '${container}' container to check '${INTERNAL_IMAGE_NAME}' image..."
    info_text "Wait for 'healthy' container status..."
    local attempt=0
    verbose_execution docker run -itd --rm --name ${container} ${INTERNAL_IMAGE_NAME}
    while [ ! $(docker inspect --format='{{json .State.Health.Status}}' ${container}) = "\"healthy\"" ]; do
        attempt=$((attempt+1))
        verbose_execution sleep 2s
        if [ ${attempt} -gt 10 ]; then
            error_box "The container is not healthy. Something goes wrong..."
            verbose_execution docker logs ${container}
            verbose_execution docker stop ${container}
            exit 1
        fi
    done
    info_text "The '${INTERNAL_IMAGE_NAME}' image has great health!"
    verbose_execution docker stop ${container}
}

_push_image(){
        local public_image_name=docker.pkg.github.com/extsoft/numbers-api/app:${1}
        info_text "New image name: " ${public_image_name}
        verbose_execution docker tag ${INTERNAL_IMAGE_NAME} ${public_image_name}
        verbose_execution docker push ${public_image_name}
}

publish_image() {
    local branch=$(git rev-parse --abbrev-ref @)
    local tag=$(git describe --exact-match --always --tags @ 2>/dev/null)
    info_box "Push the 'latest' image"
    if [[ ${branch} == main || -n "${tag}" ]]; then
        _push_image latest
    else
        info_text "Do nothing as"
        info_text "the current revision is from '${branch}' branch"
        info_text "but 'latest' image can be built based on 'main' branch only."
    fi
    info_box "Push a release image"
    if [[ -n "${tag}" ]]; then
        _push_image ${tag}
    else
        info_text "Do nothing as"
        info_text "the current revision is not a tag."
    fi
}

quality_pipeline() {
    build_ci_image
    assess_image_code
    assess_image_health
}

run_app() {
    verbose_execution python -m thenumbers
}

usage() {
cat <<MESSAGE
usage: ${0} <command>

Commands:
 code modification:
    - style_code            formats the code

 code verifications:
    - assess_black          checks formatting
    - assess_isort          checks imports order
    - assess_flake          runs static analysis
    - assess_mypy           checks types usage
    - assess_tests          runs unit testing
    - assess_code           runs all checks against the code

 image modification:
    - build_ci_image        creates a new production Docker image
    - build_dev_image       creates a new Docker image (opimized for build time)

 image verifications:
    - assess_image_code     runs all checks against the code within Docker image
    - assess_image_health   checks the Docker image health

 project:
    - install_all_packages  installs packages for development
    - run_app               runs the app from Python sources (development only)
    - quality_pipeline      runs all assessments (aka CI workflow)
    - publish_image         pushes the last built Docker image to Github register

 other:
    - help                  prints this message

MESSAGE
}

main() {
    if test -z ${1}; then
        usage
        exit 1
    fi
    case ${1} in
        -h|--help|help) usage ;;
        *) for target in "$@"; do info_box "${target}"; eval "${target}"; done ;;
    esac
}

main "$@"
