#!/bin/bash

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppet-agent
yum -y install git
yum -y install python-pip

if [ -d "$HOME/zeg" ]; then
  cd $HOME/zeg && git reset --hard && git pull
else
  git clone https://github.com/papungag/zeg.git
fi

mv $HOME/zeg/manifests/* /etc/puppetlabs/code/environments/production/manifests/

/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
/opt/puppetlabs/bin/puppet module install puppetlabs-docker --version 1.1.0
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/zabbix.pp

sleep 2m

pip install pyzabbix
pip install lxml
pip install cssselect

mv $HOME/zeg/data/* $HOME/
/usr/bin/python $HOME/add_host.py

crontab -l | { cat; echo "* * * * * /usr/bin/python $HOME/scrape.py"; } | crontab -
crontab -l | { cat; echo "*/2 * * * * /usr/bin/python $HOME/add_host.py"; } | crontab -
crontab -l | { cat; echo "*/5 * * * * /usr/bin/python $HOME/add_item.py"; } | crontab -