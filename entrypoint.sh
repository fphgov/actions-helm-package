#!/usr/bin/env bash

export HELM_REPOSITORY_URL=${INPUT_HELM_REPOSITORY_URL}
export HELM_REPOSITORY_NAME=${INPUT_HELM_REPOSITORY_NAME}
export HELM_REPOSITORY_USER=${INPUT_HELM_REPOSITORY_USER}
export HELM_REPOSITORY_PASSWORD=${INPUT_HELM_REPOSITORY_PASSWORD}
export HELM_REPOSITORY_INSECURE=${INPUT_HELM_REPOSITORY_INSECURE}
export HELM_CHART_DIR=${INPUT_HELM_CHART_DIR:-"."}

function required() {
    if [ -z "${1}" ]; then
        echo >&2 "${2} variable is required!"
        exit 1
    fi
}

required "${HELM_REPOSITORY_URL}" "helm_repository_url"
required "${HELM_REPOSITORY_NAME}" "helm_repository_name"
required "${HELM_REPOSITORY_USER}" "helm_repository_user"
required "${HELM_REPOSITORY_PASSWORD}" "helm_repository_password"

export CURL_EXTRA_ARGS=""

if [ "${HELM_REPOSITORY_INSECURE}" ] && [ "${HELM_REPOSITORY_INSECURE}" = "true" ]; then
    CURL_EXTRA_ARGS+=" -k"
fi

helm package "./${HELM_CHART_DIR}"
PACKAGE=("$HELM_CHART_DIR"-*)

curl -v -F "file=@${PACKAGE}" -u "${HELM_REPOSITORY_USER}:${HELM_REPOSITORY_PASSWORD}" "https://${HELM_REPOSITORY_URL}/service/rest/v1/components?repository=${HELM_REPOSITORY_NAME}" $CURL_EXTRA_ARGS