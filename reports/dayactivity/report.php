<?php

// argc argv Command Line parameters in CLI mode
$lang = $argv[1];
$dir = $argv[2];
$sqlitefile = $argv[3];
$reportdir = $argv[4].'/dayactivity';
$starttime = $argv[5];
$endtime = $argv[6];

$libdir = dirname(dirname(__FILE__)).'/timebyapplication';

require_once($dir.'/lang/'.$lang.'.php');
include($dir.'/config.php');
include($libdir.'/lib.php');

if(!is_dir($reportdir)){
 mkdir($reportdir);
}

if(!file_exists($sqlitefile)){
 //open the html document showing an error
 print_error('DB file not found');
}

// For xls creation
ini_set('include_path', $libdir.'/pear' . PATH_SEPARATOR . ini_get('include_path'));

// Setting ini vars
$error = '';
$reporthtml = '';
$gdata = array();
$glabels = array();
$gpie = '';
$gstacked = 'No period selected';
$startdate = '';
$enddate = '';
$creationdate = date('Y-m-d H:i:s',time());

$table = new stdclass();
$table_period = new stdclass();


$dbh = new PDO('sqlite:'.$sqlitefile);

// Time period
if($starttime && $endtime && ($endtime >= $starttime)){
 $startdate = gmdate('Y-m-d H:i:s',$starttime);
 $enddate = gmdate('Y-m-d H:i:s',$endtime);
 $period = 0;
 $days = ($endtime - $starttime) / DAYSECS;
 
 if($days < 15){
	$period = DAYSECS;
    $pname = 'Day';
 }   
 else if($days < 31){
	$period = DAYSECS * 7;
    $pname = 'Week';
 }      
 else if($days < 367){
	$period = DAYSECS * 30;
    $pname = 'Month';
 }      
 else {
	$period = DAYSECS * 365;
	$pname = 'Year';
 }  
 	
 $queries = array();
 $fdays = array();

 // one query for each period
 // WP_TRACK table doest not have indexes, so we use the less fields references in the query
 for($i = $starttime; $i <= $endtime; $i += $period){
  $queries[] = str_replace('GROUP BY','AND timestart  BETWEEN '.$i.' AND '.($i+$period).' GROUP BY',$sql);
  $fdays[] = $pname.' '.gmdate('Y-m-d',$i);
 }
 
 if($queries && count($queries) > 1){
    $cols = count($queries);
    
    $table_period = new stdclass();    
    $labels = array();
    $data = array();
    
    $i = 0;   
    foreach($queries as $q){
        $stmt = $dbh->query($q);

        $result = $stmt->setFetchMode(PDO::FETCH_NUM);

        while($row = $stmt->fetch()){
            if(!isset($data[$row[$rid]]))
                $data[$row[$rid]] = array_fill(0,$cols, '--');
            
            //row's name
            $labels[$row[$rid]] = $row[$rlabel];
            //row's values
            $data[$row[$rid]][$i] = $row[$rdata];            
        }
        $i++;
    }

    
    stacked_graph($data,$labels,$reportdir.'/gstacked.png',$name.' Period '.$startdate.' - '.$enddate);
    $gstacked = '<img src="gstacked.png">';
    
    $table_period->width = '90%';
    
    // header
    $table_period->head = $fdays;
    array_unshift($table_period->head,'Tasks');
    
    //cols and rows
    foreach($labels as $key=>$val){
        array_unshift($data[$key], $val);
        $table_period->data[] = $data[$key];
    }    
 }
 
 //MAIN SQL
 $sql = str_replace('GROUP BY','AND timestart BETWEEN '.$starttime.' AND '.$endtime.' GROUP BY',$sql);
 	
}

$stmt = $dbh->query($sql);

$result = $stmt->setFetchMode(PDO::FETCH_NUM);

$table->head  = $thead;
$table->size  = $tsize;
$table->align = $talign;
$table->width = $twidth;
  
while($row = $stmt->fetch()){
 $glabels[] = $row[$rlabel];
 $gdata[] = $row[$rdata];
 $row[$rdata] = format_time($row[$rdata]);
 $table->data[]  = $row;
}


// Output

$excelname = 'report.xls';

$xml = new SimpleXMLElement(file_get_contents($dir.'/config.xml'));

$tags = array('{table_main}','{table_period}','{name}','{error}','{sql}','{gpie}','{gstacked}','{startdate}','{enddate}','{creationdate}','{excelname}','{summary}','{author}','{version}');
$contents = array(print_table($table, true),print_table($table_period, true),$name,'',$sql,$gpie,$gstacked,$startdate,$enddate,$creationdate,$excelname,$xml->summary,$xml->author,$xml->version);

$reporthtml = str_replace($tags, $contents, file_get_contents($dir.'/report.tpl.html'));

if($rs){
	foreach($rs as $key=>$val){
		$reporthtml = str_replace("{lang:$key}", $val, $reporthtml);
	}
}

file_put_contents($reportdir.'/index.html', $reporthtml);

tables_to_excel($reportdir.'/'.$excelname,array($table,$table_period), array($reportdir.'/gpie.png',$reportdir.'/gstacked.png'));


?>