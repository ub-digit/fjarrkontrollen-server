#!/bin/bash
# update_from_libris.sh
# Negativa svar från Libris Fjärrlån
# is run by cronjob fjarrkontrollen_server_ENV_cron_script

CURRENT_ENV=$1
cd /apps/fjarrlan/fjarrkontrollen-server/current
RAILS_ENV=${CURRENT_ENV} /usr/local/rvm/gems/ruby-2.1.5/wrappers/rake libris_info:neg_responses
