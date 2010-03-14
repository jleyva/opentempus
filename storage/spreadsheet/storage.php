<?php

$dir = $argv[1];
$sqlitefile = $argv[2];
$newlines = '';
$flastid = $dir.'/lastid.txt';
$lang = $argv[3];

require($dir.'/lang/'.$lang.'.php');

if(!file_exists($flastid)){
	$lastid = 0;
}
else{
	$lastid = (integer) file_get_contents($flastid);
}

list($m,$d,$y) = split('-',date('m-d-Y'));

$starttime = gmmktime(0,0,0,$m,$d,$y);
$endtime = $starttime + 86400;

$ydir = $dir.'/'.$y;
$mdir = $ydir.'/'.$m;
// i.e 2009/11/08.csv
$fcsv = $mdir.'/'.$d.'.csv';

if(!is_dir($ydir))
	mkdir($ydir);
if(!is_dir($mdir))
	mkdir($mdir);
	
$sql = 'SELECT strftime("%Y-%m-%d %H:%M:%S",dtimestart) as ts, strftime("%Y-%m-%d %H:%M:%S",dtimeend) as te, w.title, p.name, t.seconds FROM wp_track t, windows w, processes p WHERE t.idw = w.id AND t.idp = p.id  AND t.timeend <> 0 AND t.timestart BETWEEN '.$starttime.' AND '.$endtime.' AND t.id > '.$lastid;	
	
$dbh = new PDO('sqlite:'.$sqlitefile);
$stmt = $dbh->query($sql);
if($stmt){
	$result = $stmt->setFetchMode(PDO::FETCH_NUM);
	while($row = $stmt->fetch()){
		foreach($row as $r)
			$newlines .= $r.',';
		$newlines .= "\n";	
		$lastid = $row[0]; 
	}	

	if (file_put_contents($fcsv,$newlines,FILE_APPEND)){
		file_put_contents($flastid,$lastid);
		echo $rs['ok'];	
	} else{
		echo $rs['bad'];
	}	
}
	
?>