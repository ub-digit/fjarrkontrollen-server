#!/bin/bash
# update_from_libris.sh
# is run by cronjob illbackend_TARGET_cron_script
# depends on file backend_server_name

TARGET=$1
cd /data/${TARGET}/illbackend
#rvm use 2.1.1
RAILS_ENV=production /usr/local/rvm/gems/ruby-2.1.1@illbe/wrappers/rake libris_info:user_requests
