<?php
/**
 * Zend Framework
 *
 * LICENSE
 *
 * This source file is subject to the new BSD license that is bundled
 * with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://framework.zend.com/license/new-bsd
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@zend.com so we can send you a copy immediately.
 *
 * @category   Zend
 * @package    Zend_Gdata
 * @subpackage Demos
 * @copyright  Copyright (c) 2005-2009 Zend Technologies USA Inc. (http://www.zend.com)
 * @license    http://framework.zend.com/license/new-bsd     New BSD License
 */

ini_set('include_path', $dir . PATH_SEPARATOR . ini_get('include_path')); 
 
require_once 'Zend/Loader.php';

Zend_Loader::loadClass('Zend_Gdata');
Zend_Loader::loadClass('Zend_Gdata_AuthSub');
Zend_Loader::loadClass('Zend_Gdata_ClientLogin');
Zend_Loader::loadClass('Zend_Gdata_Docs');
Zend_Loader::loadClass('Zend_Gdata_Spreadsheets');
Zend_Loader::loadClass('Zend_Gdata_Spreadsheets_DocumentQuery');

$spreadsheetService = 0;

function gdocs_gdocsclient($username, $password){
	$service = Zend_Gdata_Docs::AUTH_SERVICE_NAME;
	$client = Zend_Gdata_ClientLogin::getHttpClient($username, $password, $service);
	return $client;
}

function gdocs_gssclient($username, $password){
	$service = Zend_Gdata_Spreadsheets::AUTH_SERVICE_NAME;
	$client = Zend_Gdata_ClientLogin::getHttpClient($username, $password, $service);
	return $client;	
}

function gdocs_get_sskey($month){
	global $dir,$username,$password,$ssprefix,$xlsfile,$ssname;
	
	$client = gdocs_gdocsclient($username,$password);
	$docs = new Zend_Gdata_Docs($client);

	$newDocumentEntry = $docs->uploadFile($xlsfile, $ssname, null, Zend_Gdata_Docs::DOCUMENTS_LIST_FEED_URI);

    $alternateLink = '';
    foreach ($newDocumentEntry->link as $link) {
	  if ($link->getRel() === 'alternate') {
		  $alternateLink = $link->getHref();
	  }
	} 

	$key = substr($alternateLink,strpos($alternateLink,'key=') + 4);
	if(strpos($key,'&') !== false)
		$key = substr($key,0,strpos($key,'&'));
	if(strpos($key,'"') !== false)
		$key = substr($key,0,strpos($key,'"'));

	return $key;
}

function gdocs_get_wskey($sskey,$day){
	global $spreadsheetService,$dir,$username,$password,$ssprefix;
	
	$ssclient = gdocs_gssclient($username,$password);

	$spreadsheetService = new Zend_Gdata_Spreadsheets($ssclient);
	$query = new Zend_Gdata_Spreadsheets_DocumentQuery();
	$query->setSpreadsheetKey($sskey);
	$feed = $spreadsheetService->getWorksheetFeed($query);

	foreach ($feed->entries as $entry) {
		if (trim($entry->title) == "Day $day")
			break;
	}
	
	$key = substr($entry->id,strpos($entry->id,'full/') + 5);
	
	return $key;
}

function gdocs_insert_row($ss_key,$ws_key,$row){
	global $spreadsheetService,$username,$password;
	
	if(empty($spreadsheetService)){
		$ssclient = gdocs_gssclient($username,$password);
		$spreadsheetService = new Zend_Gdata_Spreadsheets($ssclient);
	}
	
	$insertedListEntry = $spreadsheetService->insertRow($row, $ss_key, $ws_key);
}

?>