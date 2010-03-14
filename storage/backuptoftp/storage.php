<?php

$dir = $argv[1];
$sqlitefile = $argv[2];
$lang = $argv[3];

require($dir.'/lang/'.$lang.'.php');
$today = date('Ymd');
$backup = $dir.'/'.$today.'_ot.s3db';

require_once($dir.'/config.php');

if(! $ftp_server || ! $ftp_user_name){
	exit($rs['missingdata'].$dir.'config.php');
}

if (copy($sqlitefile,$backup)){

    if($zip){
        include_once($dir."/pclzip.lib.php");

        $archive = new PclZip($backup.".zip");
        $tf = array();
        $tf[PCLZIP_ATT_FILE_NAME] = $backup;
        $tf[PCLZIP_ATT_FILE_NEW_FULL_NAME] = 'opentempus.s3db';

        if (! $archive->create(array($tf))) {
            echo $rs['zipfailed'];
            exit;
        }
        unlink($backup);
        $backup = $backup.".zip";
    }

	// set up basic connection
	$conn_id = ftp_connect($ftp_server); 

	// login with username and password
	$login_result = ftp_login($conn_id, $ftp_user_name, $ftp_user_pass); 

	// check connection
	if ((!$conn_id) || (!$login_result)) { 
		echo $rs['ftpconnectionfailed']; 
		unlink($backup);
		exit; 
	}

	// upload the file
	$upload = ftp_put($conn_id, $today.'_ot.s3db', $backup, FTP_BINARY); 

	// check upload status
	if (!$upload) { 
		echo $rs['ftpuploadfailed'];
	}
	else{
		echo $rs['ftpsuccess'];	
	}
	
	// close the FTP stream 
	ftp_close($conn_id); 	
	
	unlink($backup);
}

?>