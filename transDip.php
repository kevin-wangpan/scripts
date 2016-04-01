<?php
$sourceDip = $_GET['sourceDip'];
$destDip = $_GET['destDip'];
$source = $_GET['source'];

#写入零时stacktrace文件，供retrace使用
$timestamp = time();
$rand = rand(1000,9999);
$tmp_file = "/home/kankan/www/tmp/$timestamp$rand";
$file = fopen($tmp_file,"w");
fwrite($file, $source);
fclose($file);

exec("sh /home/kankan/www/ci/transDip.sh $tmp_file $sourceDip $destDip", $out);

$data = "";
$fp = fopen($tmp_file,"r");
if ($fp){
 while(!feof($fp)){
  $data .= fread($fp, 8192);
 }
 fclose($fp);
}
echo "$data";

unlink($tmp_file);
?>
