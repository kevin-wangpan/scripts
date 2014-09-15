#!/bin/bash

#当传递第三个参数为NULL时，只是建立父目录，并不拷贝文件
function copy_files()
{
	source_file_list=$1
	target_dir=$2
	copy_file_flag=$3

	if [[ ! -d .repo ]];then
		echo "Not a repo project!"
		exit 1
	fi
	
	for oneline in `cat ${source_file_list}`
	do
		if [[ $copy_file_flag != "NULL" && ! -e ${oneline} ]];then
			echo "$oneline does not exists!"
			exit 1
		fi
		
		file_parent_dir=$(dirname ${oneline})
		file_name=$(basename ${oneline})
		mkdir -p ${target_dir}/${file_parent_dir}
		if [[ $copy_file_flag != "NULL" ]];then
			cp -rf ${oneline} ${target_dir}/${file_parent_dir}/${file_name}
			if [[ "$?" != "0" ]];then
				echo "Copy $oneline listed in $source_file_list to $target_dir failed!"
				exit 1
			fi
		fi
	done
	
}

function extract_commit_info()
{
	local git_path=$1
	pushd $git_path
	git status
	if [[ "$?" != "0" ]];then
		echo "$commit_dir is not a git repository,please check!"
		exit 1
	fi

	modify_git_path=${git_path//\//\\/}
	#对新增、删除和修改的文件进行处理
	git status -s | grep "^??" | cut -d" " -f2 | sed "s/^/${modify_git_path}&/g" >> $workspace/new_file.cfg
	git status -s | grep "^\ M" | cut -d" " -f3 | sed "s/^/${modify_git_path}&/g" >> $workspace/modify_file.cfg
	git status -s | grep "^\ D" | cut -d" " -f3 | sed "s/^/${modify_git_path}&/g" >> $workspace/delete_file.cfg
	
	popd
}

function make_new_old()
{
	pushd "$commit_dir"
	#生成new文件夹
	echo "*****Create New Dir Begins******"
	#处理新增文件
	copy_files $workspace/new_file.cfg ${new_dir}
	copy_files $workspace/new_file.cfg ${old_dir} "NULL"
	#处理删除文件
	copy_files $workspace/delete_file.cfg ${new_dir} "NULL"
	#处理修改文件
	copy_files $workspace/modify_file.cfg ${new_dir}
	echo "*****Create New Dir Ends******"

	#生成old文件夹
	echo "*****Create Old Dir Begins******"
	repo forall -c 'git stash'
	#处理删除文件
	copy_files $workspace/delete_file.cfg ${old_dir}
	#处理修改文件
	copy_files $workspace/modify_file.cfg ${old_dir}
	echo "*****Create Old Dir Ends******"

	repo forall -c 'git stash pop --index'
}

#建立工作目录	
current_dir=$PWD
workspace=$current_dir/../workspace
commit_dir=$current_dir/../..

if [[ ! -d $commit_dir/.repo ]];then
	echo "Please place the tools in the correct place!"
	exit 1
fi

rm -rf ${workspace}
mkdir -p ${workspace}

python general_parse_xml.py ../config.xml $workspace
sed -i 's,\\,/,g' $workspace/config.cfg
#为取值两边加上双引号
sed -i -e "s,=,=\",g" -e "s,$,&\",g" $workspace/config.cfg
source $workspace/config.cfg

current_date=$(date +%Y%m%d)
dts_dir_name=$current_dir/../${DTS}-${name}-${current_date}
old_dir=${dts_dir_name}/old/${middle_dir}
new_dir=${dts_dir_name}/new/${middle_dir}
rm -rf ${dts_dir_name}
rm -rf ${dts_dir_name}.tar.gz
mkdir -p "${old_dir}" "${new_dir}"

if [[ $? == "0" ]];then
	echo "Your DTS dir: $dts_dir_name is successfully created!"
else
	echo "Error in make DTS dir,please check!"
	exit 1
fi

#进入开发者进行修改的目录,并检查git仓是否有修改
pushd "$commit_dir"
repo status -j 4
echo "Please check the files listed above:"
echo "-m : modified files"
echo "-- : new files"
echo "-d : deleted files"
echo "Is the information correct?(y/n)"
unset answer
read answer
if [[ $answer == "y" ]];then
	repo status -j 4 | grep "^project" | cut -d" " -f2 > $workspace/repo_status.cfg
else
	echo "The upload is aborted!"
	exit 1
fi

#生成提交文件信息列表
for i in `cat $workspace/repo_status.cfg`
do
	extract_commit_info "$i"
done

#生成old和new文件夹，并拷贝文件
make_new_old

#把所有git仓进行提交
for j in `cat $workspace/repo_status.cfg`
do
	pushd $j
	git add --all
	git commit -m "DTS:$DTS
	Description:$Description
	APPx:$APPx
	Feature or Bugfix:$FeatureorBugfix"
	
	popd
done

#执行upload操作
export no_proxy=rnd-hap.huawei.com,10.107.123.187,android.huawei.com,10.107.123.183,10.112.128.40,10.72.16.172,10.107.123.51
git config --global review.10.107.123.187:8080.autoupload true
git config --global review.android.huawei.com:8080.autoupload true
git config --global review.rnd-hap.huawei.com:8080.autoupload true

repo upload

if [[ $flag == "yes" ]];then
	tar -zcv -f ${dts_dir_name}.tar.gz ${dts_dir_name}
	smbclient $server_path -U china/${domain_user}%"${domain_password}" -c "put ${dts_dir_name}.tar.gz ${DTS}-${name}-${current_date}.tar.gz"
	pushd $current_dir
	dts_server_path=$(echo $server_path | sed 's,/,\\,g')
	python mail.py "${dts_server_path}\\${DTS}-${name}-${current_date}.tar.gz" "" "auto_new_old_tool" "$email_receiver"
fi





