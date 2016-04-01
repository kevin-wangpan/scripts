#!/bin/sh

#sleep 5
ftp_dir="/data/www/ci/citest/apk/"$1
apk_path_dir="ci/citest/apk/"$1
src=$2
needSign=$3
channels=$4
url_host=$5

echo "ftp_dir = $ftp_dir<br/>"
echo "src = $src<br/>"
echo "needSign = $needSign<br/>"
echo "channels = $channels<br/>"
echo "url_host = $url_host<br/>"
#exit 0

#设置环境变量
export JAVA_HOME="/usr/local/jdk1.7.0_67"
export ANDROID_HOME="/home/wangpan/AndroidHome/android-sdk-linux"

#更新git仓库
repo_dir="/data/www/ci/citest/src"
repo_root="sudaibear"
git_clone_cmd="git clone git@git.sudaibear.com:android/sudaibear.git"

#echo "$ftp_dir" | grep -q "Video"
#if [ $? -eq 0 ]
#then
#git_clone_cmd="git clone git@192.168.0.150:video.git"
#repo_root="video"
#fi


cd $repo_dir

current_dir="$PWD"
echo "current_dir="$current_dir"<br/>  repo_dir="$repo_dir"<br/>"

#whoami
echo "<br/>"

if [ $current_dir = $repo_dir ]
then
	if [ -d $repo_root ]
	then
	rm -rf $repo_root
	eval $git_clone_cmd
	cd $repo_root
	else
	eval $git_clone_cmd
	cd $repo_root
	fi
else
mkdir $repo_dir
eval $git_clone_cmd
cd $repo_root
fi

#更新代码
git checkout -f $src
git pull

echo "更新代码完成<br/>";

#修改渠道
if [ ! -z "$channels" -a "$channels" != " " ]
then
    IFS=', ' read -r -a array <<< "$channels"
    for element in ${array[@]}
    do
        # echo $element
        sed -i "/productFlavors {/a${element}" app/build.gradle
    done
fi

#修改host
if [ ! -z "$url_host" -a "$url_host" != " " ]; then
    #在符合pattern的行前加上//
    sed -i 's/^.*public static final String BASE_SERVER_ADDRESS /\/\//g' app/src/main/java/com/ufenqi/bajieloan/net/api/Api.java
    #在符合pattern的行的下方添加一行
    sed -i "/app-test.sudaibear.com/apublic static final String BASE_SERVER_ADDRESS = \"${url_host}\";" app/src/main/java/com/ufenqi/bajieloan/net/api/Api.java
    #gsed -i "s/https:\/\/app-test.sudaibear.com\/v1\/apis/${url_host}/g" app/src/main/java/com/ufenqi/bajieloan/net/api/Api.java
fi
echo "修改参数完成, 开始编译<br/>";


./gradlew clean
echo "clean 完成<br/>";

if [ $needSign -eq 1 ]
then
    echo "开始编译release版本<br/>";
    ./gradlew assembleRelease
    echo "编译release版本完成<br/>";
    destination_dir=$ftp_dir/Release/
    apk_path_dir=$apk_path_dir/Release/
    test -d "$destination_dir" || mkdir -p "$destination_dir" && cp ./app/build/outputs/apk/release/*.apk "$destination_dir"
    apk_files=`ls ./app/build/outputs/apk/release/*.apk`
else
    echo "开始编译debug版本<br/>";
    ./gradlew assembleDebug
    echo "编译debug版本完成<br/>";
    destination_dir=$ftp_dir/Debug/
    apk_path_dir=$apk_path_dir/Debug/
    test -d "$destination_dir" || mkdir -p "$destination_dir" && cp ./app/build/outputs/apk/debug/*.apk "$destination_dir"
    apk_files=`ls ./app/build/outputs/apk/debug/*.apk`
fi

echo "apk_path_dir="$apk_path_dir
echo "apk_files="$apk_files

for element in ${apk_files[@]}
do
    apk_name=`basename $element`
    echo "APK_DOWNLOAD_PATH_PREFIX_"$apk_path_dir$apk_name
done


echo "<br/><br/>"
