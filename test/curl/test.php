<?php
//
// HTTP PUT to a remote site
// Author: Julian Bond
// (tampered with by Johan Andersson)
//

// Simple xml validation
//$res = simplexml_load_string($nytt);

$shortopts  = "";
//$shortopts .= "h:";  // Required value
//$shortopts .= "f:"; // Optional value
//$shortopts .= "x"; // These options do not accept values

$longopts  = array(
    "protocol:",
    "host:",
    "port:",
    "path:",
    "file:",
);
$options = getopt($shortopts, $longopts);

$protocol = $options["protocol"];
$host = $options["host"];
$port = $options["port"];
$path = $options["path"];
$localfile = $options["file"];

//$url = "$protocol://$host:$port/v1.0$path";
$url = "$protocol://$host:$port$path";
print "Connecting to [$url] ...";
print "Using file [$localfile]";

$fp = fopen ($localfile, "r");
$ch = curl_init();
curl_setopt($ch, CURLOPT_VERBOSE, 1);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
//curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
//curl_setopt($ch, CURLOPT_CAINFO, getcwd() . "/home/xanjoo/Development/ws4/certs/testsunda/lab/chain-3369-testsunda.ub.gu.se-1-TERENA_SSL_CA.pem");
//curl_setopt($ch, CURLOPT_CAINFO, getcwd() . "chain-3369-testsunda.ub.gu.se-1-TERENA_SSL_CA.pem");
//curl_setopt($ch, CURLOPT_CAINFO, "/etc/ssl/certs/chain-3369-testsunda.ub.gu.se-1-TERENA_SSL_CA.pem");
//curl_setopt($ch, CURLOPT_USERPWD, 'user:password');
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_PUT, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_INFILE, $fp);
curl_setopt($ch, CURLOPT_INFILESIZE, filesize($localfile));

$http_result = curl_exec($ch);
$error = curl_error($ch);
$http_code = curl_getinfo($ch ,CURLINFO_HTTP_CODE);

curl_close($ch);
fclose($fp);

print 'HTTP: [' . $http_code . ']';
//print "<br /><br />$http_result";
//if ($error) {
//   print "<br /><br />$error";
//}
?>
