#!/bin/bash
#
# Runs all php test scripts and make them call the service at localhost.
#
export HOST=localhost
export PORT=3000
export PROTOCOL=http
echo "HOST is set to [$HOST]."
echo "PORT is set to [$PORT]."
echo "PROTOCOL is set to [$PROTOCOL]."
php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/orders/1" --file="order_1.json"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1110111011" --file="file-new-student.xml"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1212121212" --file="file-update-student.xml"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1212121212" --file="file-new-staff.xml"
##php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/6304146746" --file="2011-02-17-16-26-17-427.xml"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1212121212/pnr" --file="file-updatepnr.xml"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1212121212/card" --file="file-updatevalidperiod.xml"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1212121212/card" --file="file-updatecardinvalid.xml"
#php test.php --protocol=$PROTOCOL --host=$HOST --port=$PORT --path="/patrons/1212121212/card" --file="file-changepin.xml"
echo " "
echo "DONE"
