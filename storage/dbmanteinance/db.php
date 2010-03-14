<?php

$dir = $argv[1];
$sqlitefile = $argv[2];

if(file_exists($sqlitefile)){	
	$sql = 'VACUUM';	
	
	$dbh = new PDO('sqlite:'.$sqlitefile);
	$stmt = $dbh->exec($sql);
	if($stmt)
		echo 'Plugin DB Manteinance: Finished succesfully';
	else
		echo 'Plugin DB Manteinance: error, VACUUM not executed';
}

?>