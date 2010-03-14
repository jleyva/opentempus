<?php

$dir = $argv[1];
$sqlitefile = $argv[2];
$lang = $argv[3];

require($dir.'/lang/'.$lang.'.php');

$today = date('Ymd');
$backup = $dir.'/'.$today.'_ot.s3db';

require($dir."/phpmailer/class.phpmailer.php");

require($dir.'/config.php');

if(! $host || ! $username || !	$password || !	$from || !	$fromname || !	$emailto || !	$nameemailto || !	$subject || !	$bodyhtml || !	$bodytxt){
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

	$mail = new PHPMailer();

	$mail->IsSMTP();                                      // set mailer to use SMTP
	$mail->Host = $host;  // specify main and backup server
	$mail->SMTPAuth = true;     // turn on SMTP authentication
	$mail->Username = $username;  // SMTP username
	$mail->Password = $password; // SMTP password

	$mail->From = $from;
	$mail->FromName = $fromname;
	$mail->AddAddress($emailto, $nameemailto);

	$mail->WordWrap = 50;                                 // set word wrap to 50 characters
	$mail->AddAttachment($backup);         // add attachments
	$mail->IsHTML(true);                                  // set email format to HTML

	$mail->Subject = $subject;
	$mail->Body    = $bodyhtml;
	$mail->AltBody = $bodytxt;

	if(!$mail->Send())
	{
	   echo $rs['messagenotsent'];
	   echo $rs['mailererror'] . $mail->ErrorInfo;
	   exit;
	}
	else{
		echo $rs['backupsuccess'];
	}
	unlink($backup);
}	

?>