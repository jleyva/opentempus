<?php

$dir = $argv[1];
$sqlitefile = $argv[2];
$flastid = $dir.'/lastid.txt';
$ss_cache = $dir.'/ss_cache.txt';
$ws_cache = $dir.'/ws_cache.txt';
$sep = ' <- -> ';

$lang = $argv[3];

require($dir.'/lang/'.$lang.'.php');

require_once($dir.'/config.php');
require_once($dir."/lib.php");

if(! $username || !	$password){
	exit($rs['missingdata'].$dir.'config.php');
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
	$sql = 'SELECT strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, strftime("%Y-%m-%d %H:%M:%S",dtimeend) as te, wp.seconds, t.name as task, c.name as category FROM wp_track wp, task t, category c WHERE wp.idt = t.id AND t.idc = c.id AND wp.timestart BETWEEN '.$starttime.' AND '.$endtime.' AND wp.id > '.$lastid;	
	$headers = array('timestart','timeend','seconds','task','category');
	$xlsfile = $dir.'tmonth.xls';
	$ssname = $ssprefix."$y-$m".'.xls';
}
else{
	$sql = 'SELECT strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, strftime("%Y-%m-%d %H:%M:%S",dtimeend) as te, t.seconds, w.title, p.name FROM wp_track t, windows w, processes p WHERE t.idw = w.id AND t.idp = p.id  AND t.timestart BETWEEN '.$starttime.' AND '.$endtime.' AND t.id > '.$lastid;	
	$headers = array('timestart','timeend','seconds','window','process');
	$xlsfile = $dir.'wmonth.xls';
	$ssname = $ssprefix."$y-$m".'.xls';
}	
	
$dbh = new PDO('sqlite:'.$sqlitefile);
$stmt = $dbh->query($sql);
if($stmt){
	$result = $stmt->setFetchMode(PDO::FETCH_NUM);
	
	$i = 0;
	while($row = $stmt->fetch()){
		$j = 0;
		foreach($row as $r){
			$uploaddata[$i][$headers[$j]] = utf8_encode($r);
			$j++;
		}
		$lastid = $row[0]; 
		$i++;
	}	


	$ss_key = '';
	$ss_find = false;
	$cmonth = "$y-$m";
	if(file_exists($ss_cache)){
		$cskeys = file($ss_cache);
		if($cskeys){
			foreach($cskeys as $kline){
				list($month,$key) = split($sep,$kline);
				if($month == $cmonth){
					$ss_key = trim($key);
					$ss_find = true;
					break;
				}
			}
		}
	}
	
	if(!$ss_key)
		$ss_key = gdocs_get_sskey($cmonth);
		
	if(!$ss_key){
		die('Cannot get Spreadsheet Key');
	} else{
		if(!$ss_find)
			file_put_contents($ss_cache,"\n".$cmonth.$sep.$ss_key,FILE_APPEND);
	}	

		
	$ws_key = '';
	$ws_find = false;	
	$cday = "$y-$m-$d";
	if(file_exists($ws_cache)){
		$cwkeys = file($ws_cache);
		if($cwkeys){
			foreach($cwkeys as $kline){
				list($day,$key) = split($sep,$kline);
				if($day == $cday){
					$ws_key = trim($key);
					$ws_find = true;
					break;
				}
			}
		}
	}
	
	if(!$ws_key)
		$ws_key = gdocs_get_wskey($ss_key,$d);	
	
	if(!$ws_key){
		die('Cannot get Worksheet Key');
	} else{
		if(!$ws_find)
			file_put_contents($ws_cache,"\n".$cday.$sep.$ws_key,FILE_APPEND);
	}	
	
	foreach($uploaddata as $row){
		gdocs_insert_row($ss_key,$ws_key,$row);
	}
		
	file_put_contents($flastid,(string) $lastid);
}

echo $rs['ok'];


?>