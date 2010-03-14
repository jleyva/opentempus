<?

$name = 'Window';

$thead = array($rs['id'],$rs['window'],$rs['time']);
$tsize = array('10%','60%', '30%');
$talign = array('center','left', 'center');
$twidth = '95%';

$rid = 0;
$rlabel = 1;
$rdata = 2;

$sql = 'SELECT w.id, w.title, SUM(seconds) as stotal FROM wp_track wp, windows w WHERE w.id = wp.idw AND w.title <> "" GROUP BY w.id ORDER BY stotal DESC LIMIT 20';


?>