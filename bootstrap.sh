#!/usr/bin/env bash

BOOTSTRAP_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PUPPET_BIN=/opt/puppetlabs/bin/puppet
PUPPET_HIERADATA=/etc/puppetlabs/code/environments/production/hieradata
PUPPET_MODULES=/etc/puppetlabs/code/environments/production/modules
PUPPET_MANIFEST=main.pp

if [ -z "$(ls /etc/apt/sources.list.d/ | grep puppetlabs-pc1.list)" ]; then
    source /etc/lsb-release

    curl https://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb -o /tmp/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
    sudo dpkg -i /tmp/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
fi

if [ ! -f ${PUPPET_BIN} ]; then
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install puppet-agent
fi

if [ ! -h "${PUPPET_HIERADATA}/common.yaml" ]; then
    sudo ln -s ${BOOTSTRAP_DIR}/hieradata/common.yaml ${PUPPET_HIERADATA}/common.yaml
fi

install_puppet_module_if_not_present(){
    # $1 is puppet forge module name
    # $2 is module name on filesystem
    if [ ! -d "${PUPPET_MODULES}/${2}" ]; then
        sudo ${PUPPET_BIN} module install ${1}
    fi
}

install_puppet_module_if_not_present "stankevich-python" "python"

if [ -f ${BOOTSTRAP_DIR}/${PUPPET_MANIFEST} ]; then
    sudo ${PUPPET_BIN} apply ${BOOTSTRAP_DIR}/${PUPPET_MANIFEST}
fi
