<?php

$dir = $argv[1];
$sqlitefile = $argv[2];
$flaststid = $dir.'/laststid.txt';
$lang = $argv[3];

require($dir.'/lang/'.$lang.'.php');

require_once($dir.'/config.php');

if(! $email || ! $password || ! $apikey){
	exit($rs['missingdata'].$dir.'config.php');
}

if(!file_exists($flaststid)){
	$laststid = 0;
}
else{
	$laststid = (integer) file_get_contents($flaststid);
}

ini_set('include_path', $dir . PATH_SEPARATOR . ini_get('include_path')); 
require_once 'Zend/Loader.php';
Zend_Loader::loadClass('Zend_Http_Client');

$client = new Zend_Http_Client('http://slimtimer.com/users/token');

$client->setMethod(Zend_Http_Client::POST);
$client->setHeaders('Accept', 'application/xml');
$client->setHeaders('Accept-encoding', '');
$client->setParameterPost('api_key', $apikey);
$client->setParameterPost('user[email]', $email);
$client->setParameterPost('user[password]', $password);

$response = $client->request();
$xmlbody = new SimpleXMLElement($response->getBody());


if(!isset($xmlbody->error)){
	$token 	= trim($xmlbody->{'access-token'});
	$userid =  trim($xmlbody->{'user-id'});
	
	// Get tasks	
	$client = new Zend_Http_Client('http://slimtimer.com/users/'.$userid.'/tasks');

	$client->setMethod(Zend_Http_Client::GET);
	$client->setHeaders('Accept', 'application/xml');
	$client->setHeaders('Accept-encoding', '');
	$client->setParameterGet('access_token',$token);
	$client->setParameterGet('api_key', $apikey);
	
	$response = $client->request();
	$xmlbody = new SimpleXMLElement($response->getBody());	

	if(!isset($xmlbody->error)){
		$dbh = new PDO('sqlite:'.$sqlitefile);
		
		$max = $laststid;
		foreach($xmlbody as $entry){
			if($entry->id > $laststid){
				$sql = 'INSERT INTO task (idc,name) VALUES ("1","'.(utf8_decode($entry->name)).'")';			
				if($dbh->exec($sql)){				
					$max = ($entry->id > $max)? $entry->id : $max;
				}
				else{
					echo $rs['notcreatetask'].$entry->name;
					exit;
				}
			}
		}	
		
		$laststid = $max;
		
		file_put_contents($flaststid,(string) $laststid);	
	}
	else{
		echo $rs['listtaskerror'];
		exit;
	}
} else{
	echo $rs['loginerror'];
	exit;
}

echo $rs['finishedok'];

?>