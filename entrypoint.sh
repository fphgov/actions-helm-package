#!/usr/bin/env bash

export HELM_REPOSITORY_URL=${INPUT_HELM_REPOSITORY_URL}
export HELM_REPOSITORY_NAME=${INPUT_HELM_REPOSITORY_NAME}
export HELM_REPOSITORY_USER=${INPUT_HELM_REPOSITORY_USER}
export HELM_REPOSITORY_PASSWORD=${INPUT_HELM_REPOSITORY_PASSWORD}
export HELM_REPOSITORY_INSECURE=${INPUT_HELM_REPOSITORY_INSECURE}
export HELM_CHART_DIR=${INPUT_HELM_CHART_DIR:-"."}
export HELM_EXPERIMENTAL_OCI=1

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

echo "${HELM_REPOSITORY_PASSWORD}" | helm registry login ${HELM_REPOSITORY_URL} -u ${HELM_REPOSITORY_USER} --password-stdin --insecure 

helm push ${PACKAGE} oci://${HELM_REPOSITORY_URL}/${HELM_REPOSITORY_NAME} --insecure-skip-tls-verify 