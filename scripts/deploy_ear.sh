#!/bin/bash
set -e

echo "Starting WebLogic EAR deployment..."

: "${APP_NAME:?APP_NAME is required}"
: "${EAR_FILE:?EAR_FILE is required}"
: "${STAGE_DIR:?STAGE_DIR is required}"
: "${LOG_DIR:?LOG_DIR is required}"
: "${WLS_HOME:?WLS_HOME is required}"
: "${WLS_ADMIN_URL:?WLS_ADMIN_URL is required}"
: "${WLS_USER:?WLS_USER is required}"
: "${WLS_PASSWORD:?WLS_PASSWORD is required}"
: "${WLS_DEPLOY_TARGET:?WLS_DEPLOY_TARGET is required}"

DEPLOYER_JAR_PATH="${WLS_HOME}/wlserver/server/lib/weblogic.jar"
EAR_PATH="${STAGE_DIR}/${EAR_FILE}"
LOG_FILE="${LOG_DIR}/deploy_${APP_NAME}_$(date +%Y%m%d_%H%M%S).log"

if [ ! -f "${EAR_PATH}" ]; then
  echo "EAR file not found: ${EAR_PATH}"
  exit 1
fi

echo "Checking if application already exists..."
set +e
java -cp "${DEPLOYER_JAR_PATH}" weblogic.Deployer \
  -adminurl "${WLS_ADMIN_URL}" \
  -username "${WLS_USER}" \
  -password "${WLS_PASSWORD}" \
  -name "${APP_NAME}" \
  -listapps > /tmp/${APP_NAME}_apps.txt 2>&1
LIST_RC=$?
set -e

if grep -q "${APP_NAME}" /tmp/${APP_NAME}_apps.txt; then
  echo "Application exists. Performing redeploy..."
  java -cp "${DEPLOYER_JAR_PATH}" weblogic.Deployer \
    -adminurl "${WLS_ADMIN_URL}" \
    -username "${WLS_USER}" \
    -password "${WLS_PASSWORD}" \
    -name "${APP_NAME}" \
    -source "${EAR_PATH}" \
    -targets "${WLS_DEPLOY_TARGET}" \
    -redeploy | tee "${LOG_FILE}"
else
  echo "Application not found. Performing fresh deploy..."
  java -cp "${DEPLOYER_JAR_PATH}" weblogic.Deployer \
    -adminurl "${WLS_ADMIN_URL}" \
    -username "${WLS_USER}" \
    -password "${WLS_PASSWORD}" \
    -name "${APP_NAME}" \
    -source "${EAR_PATH}" \
    -targets "${WLS_DEPLOY_TARGET}" \
    -deploy | tee "${LOG_FILE}"
fi

echo "Deployment completed."