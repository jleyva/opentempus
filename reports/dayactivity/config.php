<?

$name = $rs['name'];

$thead = array($rs['id'],$rs['time'],$rs['seconds'],$rs['task'],$rs['category'],$rs['process'],$rs['window']);
$tsize = array('5%','10%','5%','10%','10%','10%','50%');
//$talign = array('center','left', 'center');
$twidth = '100%';

$rlabel = 1;
$rdata = 2;
$rid = 0;

$sql = "SELECT wp.id, dtimestart, seconds, t.name, c.name, p.name, w.title FROM wp_track wp LEFT JOIN task t ON wp.idt = t.id LEFT JOIN category c ON c.id = t.idc JOIN processes p ON wp.idp = p.id JOIN windows w ON wp.idw = w.id WHERE timestart BETWEEN $starttime AND $endtime ORDER BY timestart";

?>