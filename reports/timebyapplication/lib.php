<?

/**
 * Time constant - the number of seconds in a year
 */

define('YEARSECS', 31536000);

/**
 * Time constant - the number of seconds in a week
 */
define('WEEKSECS', 604800);

/**
 * Time constant - the number of seconds in a day
 */
define('DAYSECS', 86400);

/**
 * Time constant - the number of seconds in an hour
 */
define('HOURSECS', 3600);

/**
 * Time constant - the number of seconds in a minute
 */
define('MINSECS', 60);

/**
 * Time constant - the number of minutes in a day
 */
define('DAYMINS', 1440);

/**
 * Time constant - the number of minutes in an hour
 */
define('HOURMINS', 60);

function print_error($text){
 global $dir, $reportdir;

 $reporthtml = str_replace('{error}', $text, file_get_contents($dir.'/report.tpl.html'));
 file_put_contents($reportdir.'/index.html', $reporthtml);
 
 die;
}

function stacked_graph($data,$labels,$imgpath, $title){
 global $libdir, $dir;
 // Standard inclusions     
 include_once($libdir."/pChart/pData.class");  
 include_once($libdir."/pChart/pChart.class");  

  
 // Dataset definition   
 $DataSet = new pData;  

 foreach($data as $key=>$val){
    $DataSet->AddPoint($val,"Serie".$key);  
 }   
 
 $DataSet->AddAllSeries();  
 $DataSet->SetAbsciseLabelSerie();  
 
 foreach($labels as $key=>$val){
    $DataSet->SetSerieName($val,"Serie".$key);  
 }    
  
 // Initialise the graph  
 $Test = new pChart(770,230);  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",8);  
 $Test->setGraphArea(50,30,660,200);  
 $Test->drawFilledRoundedRectangle(7,7,763,223,5,240,240,240);  
 $Test->drawRoundedRectangle(5,5,765,225,5,230,230,230);  
 $Test->drawGraphArea(255,255,255,TRUE);  
 $Test->drawScale($DataSet->GetData(),$DataSet->GetDataDescription(),SCALE_ADDALL,150,150,150,TRUE,0,2,TRUE);  
 $Test->drawGrid(4,TRUE,230,230,230,50);  
 $Test->loadColorPalette($libdir."/palette.txt");
  
 // Draw the 0 line  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",6);  
 $Test->drawTreshold(0,143,55,72,TRUE,TRUE);  
  
 // Draw the bar graph  
 $Test->drawStackedBarGraph($DataSet->GetData(),$DataSet->GetDataDescription(),TRUE);  
  
 // Finish the graph  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",8);  
 $Test->drawLegend(646,10,$DataSet->GetDataDescription(),255,255,255);  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",10);  
 $Test->drawTitle(50,22,$title,50,50,50,585);
 
 $Test->Render($imgpath);
}



function radar_graph($data,$labels,$imgpath){
 global $libdir,$dir;
 // Standard inclusions     
 include_once($libdir."/pChart/pData.class");  
 include_once($libdir."/pChart/pChart.class");  

 $radar = array();
 for($i = 0; $i<count($labels); $i++){
	$radar[$labels[$i]] = $data[$i];
 }
 ksort($radar);
 $labels = array();
 $data = array();
 foreach($radar as $r=>$v){
  $labels[] = $r;
  $data[] = $v;
 }
  
 // Dataset definition   
 $DataSet = new pData;  
 $DataSet->AddPoint($labels,"Label");  
 $DataSet->AddPoint($data,"Serie1");  
   
 $DataSet->AddSerie("Serie1");    
 $DataSet->SetAbsciseLabelSerie("Label");    
  
 $DataSet->SetSerieName("Reference","Serie1");  
  
 // Initialise the graph  
 $Test = new pChart(400,400);  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",8);  
 $Test->drawFilledRoundedRectangle(7,7,393,393,5,240,240,240);  
 $Test->drawRoundedRectangle(5,5,395,395,5,230,230,230);  
 $Test->setGraphArea(30,30,370,370);  
 $Test->drawFilledRoundedRectangle(30,30,370,370,5,255,255,255);  
 $Test->drawRoundedRectangle(30,30,370,370,5,220,220,220); 
 $Test->loadColorPalette($libdir."/palette.txt"); 
  
 // Draw the radar graph  
 $Test->drawRadarAxis($DataSet->GetData(),$DataSet->GetDataDescription(),TRUE,20,120,120,120,230,230,230);  
 $Test->drawFilledRadar($DataSet->GetData(),$DataSet->GetDataDescription(),50,20);  
  
 // Finish the graph  
 $Test->drawLegend(15,15,$DataSet->GetDataDescription(),255,255,255);  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",10);  
 $Test->Render($imgpath);
}
 
function pie_graph($data,$labels,$imgpath){
 global $libdir, $dir;
 
 include_once($libdir."/pChart/pData.class");  
 include_once($libdir."/pChart/pChart.class");  
  
 // Dataset definition   
 $DataSet = new pData;  
 $DataSet->AddPoint($data,"Serie1");  
 $DataSet->AddPoint($labels,"Serie2");  
 $DataSet->AddAllSeries();  
 $DataSet->SetAbsciseLabelSerie("Serie2");  
  
 // Initialise the graph  
 $Test = new pChart(480,200);  
 $Test->drawFilledRoundedRectangle(7,7,473,193,5,240,240,240);  
 $Test->drawRoundedRectangle(5,5,475,195,5,230,230,230);  
  $Test->loadColorPalette($libdir."/palette.txt");
  
 // Draw the pie chart  
 $Test->setFontProperties($libdir."/Fonts/tahoma.ttf",8);  
 $Test->drawPieGraph($DataSet->GetData(),$DataSet->GetDataDescription(),150,90,110,PIE_PERCENTAGE,TRUE,50,20,5);  
 $Test->drawPieLegend(300,15,$DataSet->GetData(),$DataSet->GetDataDescription(),250,250,250);  
  
 $Test->Render($imgpath);
}

function right_to_left() {
  static $result;

  if (isset($result)) {
	  return $result;
  }
  return $result = ('ltr' == 'rtl');
}

 function fix_align_rtl($align) {
     if (!right_to_left()) {
         return $align;
     }
      if ($align=='left')  { return 'right'; }
      if ($align=='right') { return 'left'; }
      return $align;
}

function print_table($table, $return=false) {
    $output = '';

    if (isset($table->align)) {
        foreach ($table->align as $key => $aa) {
            if ($aa) {
                $align[$key] = ' text-align:'. fix_align_rtl($aa) .';';  // Fix for RTL languages
            } else {
                $align[$key] = '';
            }
        }
    }
    if (isset($table->size)) {
        foreach ($table->size as $key => $ss) {
            if ($ss) {
                $size[$key] = ' width:'. $ss .';';
            } else {
                $size[$key] = '';
            }
        }
    }
    if (isset($table->wrap)) {
        foreach ($table->wrap as $key => $ww) {
            if ($ww) {
                $wrap[$key] = ' white-space:nowrap;';
            } else {
                $wrap[$key] = '';
            }
        }
    }

    if (empty($table->width)) {
        $table->width = '80%';
    }

    if (empty($table->tablealign)) {
        $table->tablealign = 'center';
    }

    if (!isset($table->cellpadding)) {
        $table->cellpadding = '5';
    }

    if (!isset($table->cellspacing)) {
        $table->cellspacing = '1';
    }

    if (empty($table->class)) {
        $table->class = 'generaltable';
    }

    $tableid = empty($table->id) ? '' : 'id="'.$table->id.'"';

    $output .= '<table width="'.$table->width.'" ';
    if (!empty($table->summary)) {
        $output .= " summary=\"$table->summary\"";
    }
    $output .= " id=\"$table->id\" cellpadding=\"$table->cellpadding\" cellspacing=\"$table->cellspacing\" class=\"$table->class boxalign$table->tablealign\" $tableid>\n";

    $countcols = 0;
    
    if (!empty($table->head)) {
        $countcols = count($table->head);
        $output .= '<thead><tr>';
        $keys=array_keys($table->head);
        $lastkey = end($keys);
        foreach ($table->head as $key => $heading) {

            if (!isset($size[$key])) {
                $size[$key] = '';
            }
            if (!isset($align[$key])) {
                $align[$key] = '';
            }
            if ($key == $lastkey) {
                $extraclass = ' lastcol';
            } else {
                $extraclass = '';
            }

            $output .= '<th style="vertical-align:top;'. $align[$key].$size[$key] .';white-space:nowrap;" class="header c'.$key.$extraclass.'" scope="col">'. $heading .'</th>';
        }
        $output .= '</tr></thead>'."\n";
    }

    if (!empty($table->data)) {
        $oddeven = 1;
        $keys=array_keys($table->data);
        $lastrowkey = end($keys);
        foreach ($table->data as $key => $row) {
            $oddeven = $oddeven ? 0 : 1;
            if (!isset($table->rowclass[$key])) {
                $table->rowclass[$key] = '';
            }
            if ($key == $lastrowkey) {
                $table->rowclass[$key] .= ' lastrow';
            }
            $output .= '<tr class="r'.$oddeven.' '.$table->rowclass[$key].'">'."\n";
            if ($row == 'hr' and $countcols) {
                $output .= '<td colspan="'. $countcols .'"><div class="tabledivider"></div></td>';
            } else {  /// it's a normal row of data
                $keys2=array_keys($row);
                $lastkey = end($keys2);
                foreach ($row as $key => $item) {
                    if (!isset($size[$key])) {
                        $size[$key] = '';
                    }
                    if (!isset($align[$key])) {
                        $align[$key] = '';
                    }
                    if (!isset($wrap[$key])) {
                        $wrap[$key] = '';
                    }
                    if ($key == $lastkey) {
                      $extraclass = ' lastcol';
                    } else {
                      $extraclass = '';
                    }
                    $output .= '<td style="'. $align[$key].$size[$key].$wrap[$key] .'" class="cell c'.$key.$extraclass.'">'. wordwrap($item, 30, "<br />\n", true) .'</td>';
                }
            }
            $output .= '</tr>'."\n";
        }
    }
    $output .= '</table>'."\n";

    if ($return) {
        return $output;
    }

    echo $output;
    return true;
}

 function format_time($totalsecs, $str=NULL) {

    $totalsecs = abs($totalsecs);

    if (!$str) {  // Create the str structure the slow way
        $str->hour  = 'hours';
        $str->hours = 'hours';
        $str->min   = 'mins';
        $str->mins  = 'mins';
        $str->sec   = 'secs';
        $str->secs  = 'secs';      
    }

    
    $hours     = floor($totalsecs/HOURSECS);
    $remainder = $totalsecs - ($hours*HOURSECS);
    $mins      = floor($remainder/MINSECS);
    $secs      = $remainder - ($mins*MINSECS);

    $ss = ($secs == 1)  ? $str->sec  : $str->secs;
    $sm = ($mins == 1)  ? $str->min  : $str->mins;
    $sh = ($hours == 1) ? $str->hour : $str->hours;


    $ohours = '';
    $omins = '';
    $osecs = '';

    if ($hours) $ohours = $hours .' '. $sh;
    if ($mins)  $omins  = $mins .' '. $sm;
    if ($secs)  $osecs  = $secs .' '. $ss;

    if ($hours) return trim($ohours .' '. $omins);
    if ($mins)  return trim($omins .' '. $osecs);
    if ($secs)  return $osecs;
    return '';
}

function tables_to_excel($filename,$tables, $images = array()){
    
    require_once 'Spreadsheet/Excel/Writer.php';

    $workbook = new Spreadsheet_Excel_Writer($filename);
    
    foreach($tables as $tkey=>$table){
        $matrix = array();
        
        if (!empty($table->head)) {
            $countcols = count($table->head);
            $keys=array_keys($table->head);
            $lastkey = end($keys);
            foreach ($table->head as $key => $heading) {
                    $matrix[0][$key] = $heading;
            }
        }

        if (!empty($table->data)) {
            foreach ($table->data as $rkey => $row) {
                foreach ($row as $key => $item) {
                    $matrix[$rkey + 1][$key] = htmlspecialchars_decode(strip_tags($item));;
                }
            }
        }     

        $worksheet =& $workbook->addWorksheet('Table '.$tkey);    
        
        if($matrix){
            foreach($matrix as $ri=>$col){
                foreach($col as $ci=>$cv){
                    $worksheet->write($ri,$ci,$cv);
                }
            }
            if(isset($images[$tkey]) && file_exists($images[$tkey])){
                
                $image = getimagesize($images[$tkey]);
                png2wbmp($images[$tkey], $images[$tkey].'.bmp', $image[1], $image[0], 7);
                
                $worksheet->insertBitmap($ri + 5, 2, $images[$tkey].'.bmp');
            }    
        }
    }    
    
    $workbook->close();
}

function create_report(){
    global $lang, $dir, $libdir, $reportdir, $sqlitefile, $starttime, $endtime;

	require_once($dir.'/lang/'.$lang.'.php');
    include($dir.'/config.php');
    
    // For xls creation
    ini_set('include_path', $libdir.'/pear' . PATH_SEPARATOR . ini_get('include_path'));

    // Setting ini vars
    $error = '';
    $reporthtml = '';
    $gdata = array();
    $glabels = array();
    $gpie = '';
    $gstacked = $rs['noperiodselected'];
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
      $fdays[] = $pname.' <br>'.gmdate('Y-m-d',$i);
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

			if($result){
	            while($row = $stmt->fetch()){
					$row[$rdata] = format_time(round($row[$rdata],2));
				
	                if(!isset($data[$row[$rid]]))
	                    $data[$row[$rid]] = array_fill(0,$cols, '--');
	                
	                //row's name
	                $labels[$row[$rid]] = $row[$rlabel];
	                //row's values
	                $data[$row[$rid]][$i] = $row[$rdata];            
	            }
			}	
            $i++;
        }

        if($$data){
			stacked_graph($data,$labels,$reportdir.'/gstacked.png',$name.' Period '.$startdate.' - '.$enddate);
			$gstacked = '<img src="gstacked.png">';
        }
		
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

    $table->id = 'mtable';
	$table->head  = $thead;
    $table->size  = $tsize;
    $table->align = $talign;
    $table->width = $twidth;
      
    if($result){
		while($row = $stmt->fetch()){
	     $glabels[] = $row[$rlabel];
	     $gdata[] = $row[$rdata];
	     $row[$rdata] = format_time(round($row[$rdata],2));
	     $table->data[]  = $row;
	    }
	}

    //Graph
	if($gdata){
		pie_graph($gdata,$glabels,$reportdir.'/gpie.png');
		$gpie = '<img src="gpie.png">';
	}
	
    // Output

    $excelname = 'report.xls';

	$xmlfile = ($lang <> 'en')? $dir.'/config.'.$lang.'.xml' : $dir.'/config.xml';
    $xml = new SimpleXMLElement(file_get_contents($xmlfile));

    $tags = array('{table_main}','{table_period}','{name}','{error}','{sql}','{gpie}','{gstacked}','{startdate}','{enddate}','{creationdate}','{excelname}','{summary}','{author}','{version}','{rdata}');
    $contents = array(print_table($table, true),print_table($table_period, true),$name,'',$sql,$gpie,$gstacked,$startdate,$enddate,$creationdate,$excelname,$xml->summary,$xml->author,$xml->version,$rdata);

    $reporthtml = str_replace($tags, $contents, file_get_contents($libdir.'/report.tpl.html'));
	if($rs){
		foreach($rs as $key=>$val){
			$reporthtml = str_replace("{lang:$key}", $val, $reporthtml);
		}
	}

    file_put_contents($reportdir.'/index.html', $reporthtml);

	if($gdata){
		tables_to_excel($reportdir.'/'.$excelname,array($table,$table_period), array($reportdir.'/gpie.png',$reportdir.'/gstacked.png'));
	}


}


?>