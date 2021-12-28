#!/bin/sh
#set -v -x
TAG=gh-export-godot-project

if [ "${BASE_DOCKER}x" == "x" ]; then
    echo "::error::misconfiguration! base docker image not set!"
    exit 99
fi

result=`docker manifest inspect ${BASE_DOCKER}:${GODOT_VERSION} >/dev/null 2>&1; echo $?`
if [ "${result}" -ne "0" ]; then
    echo "::error::docker image with tag (godot version) ${GODOT_VERSION} does not exist within ${BASE_DOCKER}"
    exit 5
fi

cd "${ACTION_PATH}" || exit 2;
sed 's/GODOT_VERSION/'${GODOT_VERSION}'/g' -i docker/Dockerfile
sed 's/BASE_DOCKER/'${BASE_DOCKER}'/g' -i docker/Dockerfile
cd docker || exit 2;
docker build . --file Dockerfile --tag "${TAG}" --label "runnumber=${GITHUB_RUN_ID}"
docker run --workdir /github/workspace --rm -e GODOT_VERSION -e REPO_NAME -e INPUT_PROJECT-DIRECTORY -e INPUT_EXPORT-DEBUG -e INPUT_EXPORT-PACK -e INPUT_EXPORT-PLATFORM -e INPUT_PLATFORM -e INPUT_EXECUTABLE-NAME -e HOME -e GITHUB_JOB -e GITHUB_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER -e GITHUB_RUN_ID -e GITHUB_RUN_NUMBER -e GITHUB_RETENTION_DAYS -e GITHUB_RUN_ATTEMPT -e GITHUB_ACTOR -e GITHUB_WORKFLOW -e GITHUB_HEAD_REF -e GITHUB_BASE_REF -e GITHUB_EVENT_NAME -e GITHUB_SERVER_URL -e GITHUB_API_URL -e GITHUB_GRAPHQL_URL -e GITHUB_REF_NAME -e GITHUB_REF_PROTECTED -e GITHUB_REF_TYPE -e GITHUB_WORKSPACE -e GITHUB_ACTION -e GITHUB_EVENT_PATH -e GITHUB_ACTION_REPOSITORY -e GITHUB_ACTION_REF -e GITHUB_PATH -e GITHUB_ENV -e RUNNER_OS -e RUNNER_ARCH -e RUNNER_NAME -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -e CI=true -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" -v "/home/runner/work/_temp/_runner_file_commands":"/github/file_commands" -v "/home/runner/work/godot-github-ci-actions/godot-github-ci-actions":"/github/workspace" "$PROJECT_DIRECOTRY" "$EXPORT_DEBUG" "$EXPORT_PACK" "$EXPORT_PLATFORM" "$PLATFORM" $EXECUTABLE_NAME"
cd .. 
exit 0
