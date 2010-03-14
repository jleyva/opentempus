<?

$name = $rs['name'];

$thead = array($rs['id'],$rs['application'],$rs['time']);
$tsize = array('10%','60%', '30%');
$talign = array('center','left', 'center');
$twidth = '95%';

$rid = 0;
$rlabel = 1;
$rdata = 2;

$sql = 'SELECT p.id, p.name, SUM(seconds) as stotal FROM wp_track w, processes p WHERE p.id = w.idp GROUP BY p.id ORDER BY stotal DESC LIMIT 20';



?>