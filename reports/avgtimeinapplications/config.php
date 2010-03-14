<?

$name = $rs['name'];

$thead = array($rs['id'],$rs['application'],$rs['averagetime']);
$tsize = array('10%','60%', '30%');
$talign = array('center','left', 'center');
$twidth = '95%';

$rid = 0;
$rlabel = 1;
$rdata = 2;

$sql = 'SELECT p.id, p.name, AVG(seconds) as stotal FROM wp_track wp, processes p WHERE wp.idp = p.id AND seconds > 5 GROUP BY idp ORDER BY stotal DESC LIMIT 20';

?>