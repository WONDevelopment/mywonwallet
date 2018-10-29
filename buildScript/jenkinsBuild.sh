#!/usr/bin/env bash
# 第一次要执行:
#

. ./function.sh

function printInfo() {
    echo
    echo "BUILD_NUMBER: ${BUILD_NUMBER}"
    echo "JOB_NAME: ${JOB_NAME}"
    echo "BUILD_URL: ${BUILD_URL}"
    echo "GIT_COMMIT: ${GIT_COMMIT}"
    echo "GIT_BRANCH: ${GIT_BRANCH}"
    echo "GIT_URL: ${GIT_URL}"
    echo "GERRIT_PROJECT : ${GERRIT_PROJECT}"
    echo "GERRIT_CHANGE_NUMBER : ${GERRIT_CHANGE_NUMBER}"
    echo "GERRIT_PATCHSET_NUMBER : ${GERRIT_PATCHSET_NUMBER}"
    echo "GERRIT_CHANGE_ID : ${GERRIT_CHANGE_ID}"
    echo "GERRIT_REFSPEC : ${GERRIT_REFSPEC}"
    echo "GERRIT_EVENT_TYPE: ${GERRIT_EVENT_TYPE}"

    echo "productType: ${productType}"
    echo "gerritProject: ${gerritProject}"
    echo
}

function doVerifyCode(){
    echo
    echo "Start Do Verify Code:"
}

init
buildApp
