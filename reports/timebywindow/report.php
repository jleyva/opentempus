<?php

// argc argv Command Line parameters in CLI mode
$lang = $argv[1];
$dir = $argv[2];
$sqlitefile = $argv[3];
$reportdir = $argv[4].'/timebywindow';
$starttime = $argv[5];
$endtime = $argv[6];

$libdir = dirname(dirname(__FILE__)).'/timebyapplication';

include($libdir.'/lib.php');

if(!is_dir($reportdir)){
 mkdir($reportdir);
}

if(!file_exists($sqlitefile)){
 //open the html document showing an error
 print_error('DB file not found');
}

create_report();


?>