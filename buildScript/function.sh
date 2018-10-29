#!/bin/sh

dstFolder=""
dockerKey="worldopennetwork/wallet"

function splitLine () {
    echo
    if [ -n "${1}" ]; then
        echo "**********splitLine: ${1} ********************************************************************** "
        echo
    fi
}

function init(){
    # -- cd Src folder
    cd ../../
    basePath=`pwd`

    gitVersion=`git rev-parse HEAD`
    shortGitVersion=${gitVersion:0:7}

    dstFolder="/product/won/${productRelease}/${productType}/docker/"

    printInfo
}

function doGetVerifyCode() {
    echo
    echo "Start Get Verify Code:"

    echo "git fetch ssh://jenkins@gerrit:27000/${gerritProject} ${GERRIT_REFSPEC}"
    git fetch ssh://jenkins@gerrit:27000/${gerritProject} ${GERRIT_REFSPEC}
    if [ $? != 0 ]; then
        echo "Git fetch [${GERRIT_REFSPEC}] failed";
        exit 1;
    fi

    echo "git checkout FETCH_HEAD"
    git checkout FETCH_HEAD
    if [ $? != 0 ]; then
        echo "Git checkout failed";
        exit 1;
    fi
}

function printInfo() {
    echo
    echo "basePath: ${basePath}"

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

    echo "product: ${product}"
    echo "productRelease: ${productRelease}"
    echo "productType: ${productType}"
    echo "gerritProject: ${gerritProject}"

    echo
    echo "dstFolder: ${dstFolder}"

    echo
}

function buildApp() {
    if [ "${GERRIT_EVENT_TYPE}" == "patchset-created" ]; then
        # -- patchset-created, for code verify, just do compile
        echo "Code Verify, just do compile"
        doGetVerifyCode
        doVerifyCode
    else
        # -- change-merged, need rsync to server
        if [ "${productRelease}" == "production" ];then
            echo "Change Merged, need deploy with docker"
            # -- release, use docker
            generateDockerFile
            makeDockerImage
            deployDocker
        else
            # -- alpha/beta, use single server
            echo "Change Merged, need rsync to server"
        fi
    fi
}

function generateDockerFile() {
    splitLine "Start generateDockerFile"

    if [ -d ${dstFolder} ]; then
        rm -rf ${dstFolder}
    fi

    mkdir -p ${dstFolder}

    echo "/bin/cp -rf ${basePath}/* ${dstFolder}"
    /bin/cp -rf ${basePath}/* ${dstFolder}
    if [ $? != 0 ]; then
        echo "code cp failed";
        exit 1;
    fi

    echo "/bin/cp -rf ${basePath}/MyWonWallet/buildScript/docker/* ${dstFolder}"
    /bin/cp -rf ${basePath}/MyWonWallet/buildScript/docker/* ${dstFolder}

    if [ $? != 0 ]; then
        echo "docker file cp failed";
        exit 1;
    fi
}

function makeDockerImage() {
    cd ${dstFolder}
    pwd
    ls -hla

    echo "docker build -t ${dockerKey} ."
    docker build -t ${dockerKey} .
    if [ $? != 0 ]; then
        echo "docker image build failed";
        exit 1;
    fi

    docker tag ${dockerKey} us.gcr.io/${dockerKey}:${BUILD_NUMBER}
    if [ $? != 0 ]; then
        echo "docker image tag failed";
        exit 1;
    fi

    docker tag ${dockerKey} us.gcr.io/${dockerKey}:latest
    if [ $? != 0 ]; then
        echo "docker image latest tag failed";
        exit 1;
    fi

    docker push us.gcr.io/${dockerKey}:${BUILD_NUMBER}
    if [ $? != 0 ]; then
        echo "docker image push failed";
        exit 1;
    fi

    docker push us.gcr.io/${dockerKey}:latest
    if [ $? != 0 ]; then
        echo "docker image latest push failed";
        exit 1;
    fi
}

function deployDocker() {
    echo
    echo "Do Deploy Docker"

    cd /data/docker/kube/deployment
    find . -type f -name "*.yaml" | xargs grep ${dockerKey}

    dockerKeyR=${dockerKey/\//\\\/}
    find . -type f -name "*.yaml" | xargs sed -i "s/${dockerKeyR}.*/${dockerKeyR}:${BUILD_NUMBER}/g"

    echo
    echo "After replace tag is: "
    find . -type f -name "*.yaml" | xargs grep ${dockerKey}

    if [ "true" == "${deployK8s}" ]; then
        # -- aotu deploy k8s
        echo "Start deploy k8s replace:"
        echo "find . -type f -name 'wallet*.yaml' | xargs -i kubectl replace -f {}";
        find . -type f -name "wallet*.yaml" | xargs -i kubectl replace -f {}

        echo "kubectl get pods -o wide"
        kubectl get pods -o wide
    fi
}
