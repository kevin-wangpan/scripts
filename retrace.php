<html>
<head>
<style>
.shortcut-button {
border: 1px solid #ccc;
background: #f7f7f7 url('resources/images/shortcut-button-bg.gif') top left no-repeat;
display: block;
width: 120px;
margin: 0 0 20px 0;
-webkit-border-radius: 6px;
border-radius: 6px;
}
.shortcut-button span {
border: 1px solid #fff;
display: block;
padding: 15px 10px 15px 10px;
text-align: center;
color: #555;
font-size: 13px;
line-height: 1.3em;
-moz-border-radius: 7px;
-webkit-border-radius: 7px;
border-radius: 7px;
}
.shortcut-button:hover {
background: #fff;
}
.shortcut-button span:hover {
color: #57a000; 
}
a:link,a:visited{
 text-decoration:none;  /*超链接无下划线*/
}
</style>
<script>   
 function struct(key, value) {   
   this.key = key;   
   this.value = value;   
 }   
    
 function put(key, value){   
   for (var i = 0; i < this.arr.length; i++) {   
     if ( this.arr[i].key === key ) {   
       this.arr[i].value = value;   
       return;   
     }   
   }   
   this.arr[this.arr.length] = new struct(key, value);   
 }   
    
 function get(key) {   
   for (var i = 0; i < this.arr.length; i++) {   
     if ( this.arr[i].key === key ) {   
       return this.arr[i].value;   
     }   
   }   
   return null;   
 }   
    
 function remove(key) {   
   var v;   
   for (var i = 0; i < this.arr.length; i++) {   
     v = this.arr.pop();   
     if ( v.key === key ) {   
       continue;   
     }   
     this.arr.unshift(v);   
   }   
 }   
    
 function size() {   
   return this.arr.length;   
 }   
    
 function isEmpty() {   
   return this.arr.length <= 0;   
 }   
    
 function Map() {   
   this.arr = new Array();   
   this.get = get;   
   this.put = put;   
   this.remove = remove;   
   this.size = size;   
   this.isEmpty = isEmpty;   
   this.sort = sort;   
 }   
    
 function sort() {   
     
 }   

function retrace(btn){
	btn.parentNode.removeChild(btn);
	document.getElementById('tips').innerHTML = "retracing...";
	document.getElementById('form').submit();
	document.getElementById('projects').disabled = true;
	document.getElementById('mapping').disabled = true;
	document.getElementById('stack').disabled = true;
}
</script>
<?php
function myException($exception)
{
	echo "<b>Exception:</b> " , $exception->getMessage();
}
set_exception_handler('myException');

function listfile($dir){
	$fileArray = array();
	if($handle = opendir($dir)){
		while(($file = readdir($handle)) !== false){
			if($file !="." && $file !=".."){
				if(is_dir($dir . DIRECTORY_SEPARATOR . $file)){
					array_push($fileArray, $file);
				}
			}
		}
		fclose($handle);
	}
	return $fileArray;
}

#ftp目录列表
$ftp_root = "/home/ftp/android/";
#源码与ftp目录映射
$src_mapping = parse_ini_file("src.ini");

$param_project = $_POST['projects']; 
$param_mapping = $_POST['mapping']; 
$param_stack = $_POST['stack']; 
#echo "param_project=$param_project,param_mapping=$param_mapping,param_stack=$param_stack";
$out = "";

if(!empty($param_project) && !empty($param_mapping) && !empty($param_stack)){
	$src = $src_mapping[$param_project];
	$mapping_file = "$ftp_root$param_project/.mapping/$param_mapping";
	
	#替换logcat输出的日期等字串
	$param_stack = preg_replace("/.*\):\s/", "", $param_stack);

	#写入零时stacktrace文件，供retrace使用
	$timestamp = time();
	$rand = rand(1000,9999);
	$stack_file = "/home/kankan/www/tmp/$timestamp$rand";
	$file = fopen($stack_file,"w");
	fwrite($file, $param_stack);
	fclose($file);

	#执行rerrace
	exec("sh /home/kankan/adt-bundle-linux-x86-20130917/sdk/tools/proguard/bin/retrace.sh $mapping_file $stack_file", $out);
	#echo "sh /home/kankan/adt-bundle-linux-x86-20130917/sdk/tools/proguard/bin/retrace.sh $mapping_file $stack_file";
	unlink($stack_file);
	#print_r("<br/>111<br/>");
	#print_r($out); 
	#print_r("<br/>222<br/>");
	#print_r($status); 
	#print_r("<br/>333<br/>");
	#print_r($log); 
	#print_r("<br/>444<br/>");
}

$projects = listfile($ftp_root);
rsort($projects);
$selectors = "";
$project_mappings = array();
foreach($projects as $project){
	if(array_key_exists($project, $src_mapping)){
		$selectors .= "<option value=\"$project\"".(strcmp($param_project, $project) == 0 ? "selected" : "").">$project</option>";
		$project_mappings[$project] = get_project_mappings("$ftp_root$project/.mapping");
	}else{
		$selectors .= "<option disabled=\"false\" value=\"$project\">$project(未配置源码)</option>";
	}
}

function endWith($haystack, $needle){
    return $needle === "" || substr($haystack, -strlen($needle)) === $needle;
}

function get_project_mappings($project_dir){
	$fileArray = array();
        if($handle = opendir($project_dir)){
                while(($file = readdir($handle)) !== false){
			if(!is_dir($project_dir . DIRECTORY_SEPARATOR . $file)){
                        	array_push($fileArray, $file);
                        }
                }
                fclose($handle);
        }
	rsort($fileArray);
        return $fileArray;
}

?>
<script>
var project_mapping = new Map();
<?php
foreach(array_keys($project_mappings) as $project){
	echo "var mappings = new Array();\r\n";
	foreach($project_mappings[$project] as $mapping){
		echo "mappings.push('$mapping');\r\n";	
	}
	echo "project_mapping.put('$project', mappings);\r\n";
}
?>

function onProjectChange(project, selectedVal){
	var mappings = project_mapping.get(project);
	var mappingObj = document.getElementById("mapping");
	mappingObj.options.length = 0;
	for(var i = 0; i < mappings.length; i++){
		var opt = document.createElement("OPTION");
		opt.value = mappings[i];
		opt.text = mappings[i];
		opt.selected = selectedVal && selectedVal == mappings[i] ? true : false;
		mappingObj.options.add(opt);
	}
}
</script>
</head>
<body style="background:transparent" onload="onProjectChange(document.getElementById('projects').value, <?php echo(!empty($param_mapping) ? "'$param_mapping'" : "null") ?>);">
<p>异常回溯</p>
<form name="form" id="form" action="retrace.php" method="post">
<select name="projects" id="projects" onchange="onProjectChange(this.value, null);">
<?php echo $selectors ?>
</select>
<select name="mapping" id="mapping">
</select>
<br/>
<textarea id="stack" name="stack" cols="100" rows="30">
<?php
foreach($out as $line){
echo "$line\n";
}
?>
</textarea>
<a class="shortcut-button" href="javascript:void(0)" onclick="retrace(this)">
<span>
Retrace
</span>
</a>
</form>
<p id="tips"></p>
</body>
</html>
