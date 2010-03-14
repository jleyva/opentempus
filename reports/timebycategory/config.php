<?

$name = $rs['name'];

$thead = array($rs['id'],$rs['category'],$rs['time']);
$tsize = array('10%','60%', '30%');
$talign = array('center','left', 'center');
$twidth = '95%';

$rid = 0;
$rlabel = 1;
$rdata = 2;

$sql = 'SELECT c.id, c.name, SUM(seconds) AS stotal FROM wp_track w, category c, task t WHERE w.idt = t.id AND t.idc = c.id GROUP BY c.id ORDER BY stotal DESC LIMIT 20';

?>