#!/bin/bash
# Creating orders export
# is run by cronjob fjarrkontrollen_server_ENV_cron_script
PATH=$PATH:/usr/local/bin
. /usr/local/rvm/scripts/rvm

CURRENT_ENV=$1
DIR=$2

cd ${DIR}
rvm use 2.3.1
RAILS_ENV=${CURRENT_ENV} bundle exec rake export:orders
