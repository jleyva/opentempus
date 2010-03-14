<?php

$dir = $argv[1];
$sqlitefile = $argv[2];
$wflastid = $dir.'/wlastid.txt';
$tflastid = $dir.'/tlastid.txt';
$wcache = $dir.'/wcache.txt';
$tcache = $dir.'/tcache.txt';

$lang = $argv[3];

require($dir.'/lang/'.$lang.'.php');

require_once($dir.'/config.php');

if(! $email || ! $password || ! $apikey){
	exit($rs['missingdata'].$dir.'config.php');
}

ini_set('include_path', $dir . PATH_SEPARATOR . ini_get('include_path')); 
require_once 'Zend/Loader.php';
Zend_Loader::loadClass('Zend_Http_Client');

if($uploadonlytasks){
	$flastid = $tflastid;
}
else{
	$flastid = $wflastid;
}

if(!file_exists($flastid)){
	$lastid = 0;
}
else{
	$lastid = (integer) file_get_contents($flastid);
}

list($m,$d,$y) = split('-',date('m-d-Y'));
$starttime = gmmktime(0,0,0,$m,$d,$y);
$endtime = $starttime + 86400;

$uploaddata = array();

if($uploadonlytasks){
	$sql = 'SELECT t.id as cid, strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, wp.seconds, t.name as name, c.name as tag, wp.id as lid FROM wp_track wp, task t, category c WHERE wp.idt = t.id AND t.idc = c.id  AND wp.timestart BETWEEN '.$starttime.' AND '.$endtime.' AND wp.id > '.$lastid.' ORDER BY wp.id ASC';	
	$cache = build_cache($tcache);
	$fcache = $tcache;
}
else{
	$sql = 'SELECT w.id as cid, strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, t.seconds, w.title as name, p.name as tag, t.id as lid FROM wp_track t, windows w, processes p WHERE t.idw = w.id AND t.idp = p.id AND t.timestart BETWEEN '.$starttime.' AND '.$endtime.'  AND t.id > '.$lastid.' ORDER BY t.id ASC';	
	$cache = build_cache($wcache);
	$fcache = $wcache;
}	
	
$dbh = new PDO('sqlite:'.$sqlitefile);
$stmt = $dbh->query($sql);

if($stmt){
	$result = $stmt->setFetchMode(PDO::FETCH_NUM);

	while($row = $stmt->fetch()){
		$uploaddata[] = $row;
		$lastid = $row[0]; 
	}

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
		$token = trim($xmlbody->{'access-token'});
		$userid =  trim($xmlbody->{'user-id'});
		
		// Persistent connection, we don't wanna kick down slimtimer server		
		$client = new Zend_Http_Client('http://slimtimer.com/users/'.$userid.'/time_entries');

		$i = 0;
		
		foreach($uploaddata as $d){
		
			$i++;
			if($i > $maxrecords)
				break;
			
			if(!isset($cache[$d[0]])){
				//We need to create a task before the time entry
				$client->setUri('http://slimtimer.com/users/'.$userid.'/tasks');
				$client->setHeaders('Accept', 'application/xml');
				$client->setHeaders('Accept-encoding', '');
				$client->setParameterPost('api_key', $apikey);
				$client->setParameterPost('access_token', $token);
				$client->setParameterPost('task[name]', $d[3]);
				$client->setParameterPost('task[tags]', $d[4]);	
				
				$response = $client->request(Zend_Http_Client::POST);
				$xmlbody = new SimpleXMLElement($response->getBody());
				$client->resetParameters();
				
				if(!isset($xmlbody->error) && is_numeric(trim($xmlbody->id))){
					$tid = trim($xmlbody->id);
					$cache[$d[0]] = $tid;
					file_put_contents($fcache,$d[0].' - '.$tid."\n", FILE_APPEND);
				}
				else{
					echo $rs['notcreatetask'];
					exit;
				}
			}
			
			$client->setUri('http://slimtimer.com/users/'.$userid.'/time_entries');
			$client->setHeaders('Accept', 'application/xml');
			$client->setHeaders('Accept-encoding', '');
			$client->setParameterPost('api_key', $apikey);
			$client->setParameterPost('access_token', $token);	
			$client->setParameterPost('time-entry[task_id]', $cache[$d[0]]);
			$client->setParameterPost('time-entry[start_time]', $d[1]);
			$client->setParameterPost('time-entry[duration_in_seconds]', $d[2]);
			$client->setParameterPost('time-entry[tags]', $d[4]);				
			
			$response = $client->request(Zend_Http_Client::POST);
			if(isset($xmlbody->error)){
				echo $rs['notcreatetimeentry'].$d[5];
				exit;
			}			
			$client->resetParameters();
			
			file_put_contents($flastid,(string) $d[5]);			
		}
	}
}

echo $rs['finishedok'];
	
?>