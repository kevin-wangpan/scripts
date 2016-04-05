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

        a:link, a:visited {
            text-decoration: none; /*超链接无下划线*/
        }
    </style>
    <script type="text/javascript" src="resources/scripts/pinyin.js"></script>
    <?php
    $sign = isset($_GET['sign']) ? $_GET['sign']: 0;
    $needSign = $sign == 1;
    $ftp_sub_dir = $needSign ? "Release" : "Debug";
    ?>
    <script>
        function makeApk(btn) {
            var channels = codefans_net_CC2PY(document.getElementById('channels').value);

            btn.parentNode.removeChild(btn);
            document.getElementById('tips').innerHTML = "打包中...";
            document.getElementById('projects').disabled = true;
            document.location = 'apk.php?sign=<?php echo $sign ?>&project=' + document.getElementById('projects').value + '&channels=' + channels + '&host=' + document.getElementById("host").value;
        }
    </script>
</head>
<?php
function myException($exception)
{
    echo "<b>Exception:</b> ", $exception->getMessage();
}

set_exception_handler('myException');

function listfile($dir)
{
    $fileArray = array();
    if ($handle = opendir($dir)) {
        while (($file = readdir($handle)) !== false) {
            if ($file != "." && $file != "..") {
                if (is_dir($dir . DIRECTORY_SEPARATOR . $file)) {
                    array_push($fileArray, $file);
                }
            }
        }
        fclose($handle);
    }
    return $fileArray;
}

function findString($arr, $string)
{
    foreach ($arr as $key => $val) {
        $pos = strpos($val, $string);
        if ($pos !== false) {
            return $val;
        }
    }
    return "";
}

#源码与ftp目录映射
$src_mapping = parse_ini_file("src.ini");

$param_project = isset($_GET['project']) ? $_GET['project']: '';
$channels = isset($_GET['channels']) ? $_GET['channels']: '';
$host = isset($_GET['host']) ? $_GET['host']: '';
$out = -1;
if (!empty($param_project)) {
    $src = $src_mapping[$param_project];

    $semaphore = sem_get(890116);
    if (!$semaphore) {
        echo "获取同步锁失败";
        exit;
    }
    sem_acquire($semaphore);

    exec("sh /data/www/ci/apk.sh '$param_project' '$src' $sign '$channels' '$host' 2>&1", $out);
    #print_r("<br/>111<br/>");
    #print_r($out);
    #print_r("<br/>222<br/>");
    #print_r($status);
    #print_r("<br/>333<br/>");
    sem_release($semaphore);
}
?>

<body style="background:transparent">
<p>编译<?php echo $needSign ? "正式包" : "测试包" ?></p>
<select id="projects">
    <?php
    #ftp目录列表
    $projects = listfile("/data/www/ci/citest/apk");
    rsort($projects);

    foreach ($projects as $project) {
        if (array_key_exists($project, $src_mapping)) {
            echo "<option value=\"$project\"" . (strcmp($param_project, $project) == 0 ? "selected" : "") . ">$project</option>";
        } else {
            echo "<option disabled=\"false\" value=\"$project\">$project(未配置源码)</option>";
        }
    }

    ?>
</select>
<br/>
<br/>
设置渠道
<br/>
<textarea id="channels"
          placeholder="渠道号填写格式:
用英文逗号,区分各个渠道. 例如:
    应用宝, 百度.
(注意:汉字会被转变成拼音,例如百度->BaiDu)"
          cols="100" rows="10">
</textarea>
<br/>
设置服务器地址
<br/>
<textarea id="host"
          placeholder="服务器地址, 例如: http://172.16.10.237:9094/apis"
          cols="100" rows="1">
</textarea>
<br/>
<br/>
<a class="shortcut-button" href="javascript:void(0)" onclick="makeApk(this)">
<span>
打包
</span>
</a>

<p id="tips">
    <?php
    if (is_array($out)) {
        if (in_array("BUILD SUCCESSFUL", $out)) {
            $prefix="APK_DOWNLOAD_PATH_PREFIX_";
            foreach ($out as $line) {
                $pos = strpos($line, $prefix);
                if ($pos !== false) {
                    $href_path=str_replace($prefix, "http://172.16.10.207/", $line);
                    $apk_name=basename($line);
                    echo "<a href=\"$href_path\">$apk_name</a>";
                    echo "<br/>";
                }
            }
        }
        echo "<br/>";
        foreach ($out as $line) {
            echo $line . "<br/>";
        }
    }
    ?>
</p>
</body>
</html>
