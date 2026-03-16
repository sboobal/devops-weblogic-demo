#!/bin/bash
set -e

: "${APP_NAME:?APP_NAME is required}"
: "${WLS_HOME:?WLS_HOME is required}"
: "${WLS_ADMIN_URL:?WLS_ADMIN_URL is required}"
: "${WLS_USER:?WLS_USER is required}"
: "${WLS_PASSWORD:?WLS_PASSWORD is required}"

DEPLOYER_JAR_PATH="${WLS_HOME}/wlserver/server/lib/weblogic.jar"

java -cp "${DEPLOYER_JAR_PATH}" weblogic.Deployer \
  -adminurl "${WLS_ADMIN_URL}" \
  -username "${WLS_USER}" \
  -password "${WLS_PASSWORD}" \
  -name "${APP_NAME}" \
  -stop