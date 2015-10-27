#/bin/bash
# -------------------------------------------------- #
# collects deploy info
# -------------------------------------------------- #
# environment
# -------------------------------------------------- #
PATH=$PATH:/usr/local/bin
. /usr/local/lib/rvm
rvm use 2.1.1
# -------------------------------------------------- #
# initialization
# -------------------------------------------------- #
export SUDO_ASKPASS=/usr/bin/ssh-askpass
# -------------------------------------------------- #
DEPLOYER=$1
SERVERNAME=$2
DEPLOYMODE=$3   # test, demo, live
DEPDIR=$4       # t.ex. /data/rails/illbacked
# -------------------------------------------------- #
APP=illbackend
INFOFILE=deploy-info.html
CRONFILE=illbackend_${DEPLOYMODE}_cron_script
CRONFILEDEST=/etc/cron.d/${CRONFILE}
SERVERNAMEFILE=backend_server_name
# -------------------------------------------------- #
SEPARATOR='# ---------------------------------------- #'
HTMLHEADER='<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>illbackend</title>
</head>
<body>
<h3>'${APP}'</h3>
<pre>
'
HTMLFOOTER='
</pre>
</body>'
# -------------------------------------------------- #
# deploy
# -------------------------------------------------- #

cd $DEPDIR
echo ${SERVERNAME} > ${SERVERNAMEFILE}
sudo -A cp $CRONFILE $CRONFILEDEST
git pull
bundle install
rake db:migrate RAILS_ENV=production
touch tmp/restart.txt
# -------------------------------------------------- #
# create deploy-info.html available in web root
# -------------------------------------------------- #
echo ${HTMLHEADER}                                        > $INFOFILE
echo $SEPARATOR                                          >> $INFOFILE
date                                                     >> $INFOFILE
echo "DEPLOYER:$DEPLOYER"                                >> $INFOFILE
echo $SEPARATOR                                          >> $INFOFILE
git show HEAD | head -5 | awk '{gsub("<[^>]*>", "")}1'   >> $INFOFILE
echo $SEPARATOR                                          >> $INFOFILE
echo ${HTMLFOOTER}                                       >> $INFOFILE
chmod 664 ${INFOFILE}
mv ${INFOFILE} public
