#!/bin/bash

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppet-agent git python-pip
pip install pyzabbix lxml cssselect

if [ -d "$HOME/zeg" ]; then
  cd $HOME/zeg && git reset --hard && git pull
else
  git clone https://github.com/papungag/zeg.git
fi

mv $HOME/zeg/manifests/* /etc/puppetlabs/code/environments/production/manifests/
mv $HOME/zeg/data/* $HOME/
crontab -l | { cat; echo "* * * * * /usr/bin/python $HOME/scrape.py"; } | crontab -
/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
/opt/puppetlabs/bin/puppet module install puppetlabs-docker --version 1.1.0
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/zabbix.pp

sleep 2m

/usr/bin/python $HOME/add_host.py
/usr/bin/python $HOME/add_item.py
