<?

$name = $rs['name'];

$thead = array($rs['id'],$rs['task'],$rs['time']);
$tsize = array('10%', '30%', '30%');
$talign = array('center','left', 'center');
$twidth = '500';

$rid = 0;
$rlabel = 1;
$rdata = 2;


$sql = 'SELECT t.id, c.name || ": " || t.name as name, SUM(seconds) as stotal FROM wp_track w, category c, task t WHERE w.idt = t.id AND t.idc = c.id GROUP BY t.id ORDER BY stotal DESC LIMIT 20';




?>