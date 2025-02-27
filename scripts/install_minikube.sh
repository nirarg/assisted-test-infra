#!/bin/bash
set -euxo pipefail
export SUDO=$(if [ -x "$(command -v sudo)" ]; then echo "sudo"; else echo ""; fi)

function install_minikube() {
    if [ "${DEPLOY_TARGET}" != "minikube" ]; then
        echo "Skips installing minikube when deployment target is ${DEPLOY_TARGET}..."
        return
    fi

    minikube_version=v1.23.2
    if ! [ -x "$(command -v minikube)" ]; then
        echo "Installing minikube..."
        download_minikube $minikube_version
        ${SUDO} mv -f ${HOME}/.arkade/bin/minikube /usr/local/bin/
    elif [ "$(minikube version | grep version | awk -F'version: *' '{print $2}')" != "$minikube_version" ]; then
        echo "Upgrading minikube..."
        download_minikube $minikube_version
        ${SUDO} mv -f ${HOME}/.arkade/bin/minikube $(command -v minikube)
    else
        echo "minikube is already installed and up-to-date"
    fi
}

function download_minikube() {
    for i in {1..4}; do
        arkade get minikube --version=$1 && break
        echo "minikube installation failed. Retrying again in 5 seconds..."
        sleep 5
    done
}
function install_kubectl() {
    if ! [ -x "$(command -v kubectl)" ]; then
        echo "Installing kubectl..."
        arkade get kubectl --version=v1.22.0
        ${SUDO} mv ${HOME}/.arkade/bin/kubectl /usr/local/bin/
    else
        echo "kubectl is already installed"
    fi
}

function install_oc() {
    if ! [ -x "$(command -v oc)" ]; then
        echo "Installing oc..."
        for i in {1..4}; do
            curl --retry 3 -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable-4.8/openshift-client-linux.tar.gz | tar -xz -C /usr/local/bin && break
            echo "oc installation failed. Retrying again in 5 seconds..."
            sleep 5
        done
    else
        echo "oc is already installed"
    fi
}

function install_arkade() {
    if ! [ -x "$(command -v arkade)" ]; then
        echo "Installing arkade..."
        for i in {1..4}; do
            curl --retry 3 -sLS https://get.arkade.dev | ${SUDO} sh && break
            echo "arkade installation failed. Retrying again in 5 seconds..."
            sleep 5
        done
	arkade version
        echo "successfully installed arkade!"
    else
        echo "arkade is already installed"
    fi
}

install_arkade
install_minikube
install_kubectl
install_oc
