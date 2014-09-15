#!/bin/bash

#�����ݵ���������ΪNULLʱ��ֻ�ǽ�����Ŀ¼�����������ļ�
function copy_files()
{
	source_file_list=$1
	target_dir=$2
	copy_file_flag=$3

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

function make_new_old()
{
	pushd "$commit_dir"
	#����new�ļ���
	echo "*****Create New Dir Begins******"
	#���������ļ�
	copy_files $workspace/new_file.cfg ${new_dir}
	copy_files $workspace/new_file.cfg ${old_dir} "NULL"
	#����ɾ���ļ�
	copy_files $workspace/delete_file.cfg ${new_dir} "NULL"
	#�����޸��ļ�
	copy_files $workspace/modify_file.cfg ${new_dir}
	echo "*****Create New Dir Ends******"

	#����old�ļ���
	echo "*****Create Old Dir Begins******"
	git stash
	#����ɾ���ļ�
	copy_files $workspace/delete_file.cfg ${old_dir}
	#�����޸��ļ�
	copy_files $workspace/modify_file.cfg ${old_dir}
	echo "*****Create Old Dir Ends******"

	git stash pop --index
}

#��������Ŀ¼	
current_dir=$PWD
workspace=$current_dir/../workspace

rm -rf ${workspace}
mkdir -p ${workspace}

python general_parse_xml.py ../config.xml $workspace
sed -i 's,\\,/,g' $workspace/config.cfg
#Ϊȡֵ���߼���˫����
sed -i -e "s,=,=\",g" -e "s,$,&\",g" $workspace/config.cfg
source $workspace/config.cfg

if [[ "$git_dir_path" == "NULL" ]];then
	echo "git_dir_path in config.xml cann't be blank,please check!"
	exit 1
fi

commit_dir=$current_dir/../../$git_dir_path

if [[ ! -d "$commit_dir" ]];then
	echo "$git_dir_path does not exists!"
	exit 1
fi

current_date=$(date +%Y%m%d)
dts_dir_name=$current_dir/../${DTS}-${name}-${current_date}
old_dir=${dts_dir_name}/old/$middle_dir
new_dir=${dts_dir_name}/new/$middle_dir
rm -rf ${dts_dir_name}
rm -rf ${dts_dir_name}.tar.gz
mkdir -p "${old_dir}" "${new_dir}"

if [[ $? == "0" ]];then
	echo "Your DTS dir: $dts_dir_name is successfully created!"
else
	echo "Error in make DTS dir,please check!"
	exit 1
fi

#���뿪���߽����޸ĵ�Ŀ¼,�����git���Ƿ����޸�
pushd "$commit_dir"
git status -s
echo "Please check the files listed above:"
echo "M : modified files"
echo "?? : new files"
echo "D : deleted files"
echo "Is the information correct?(y/n)"
unset answer
read answer
if [[ $answer != "y" ]];then
	echo "The push is aborted!"
	exit 1
fi

git status -s | grep "^??" | cut -d" " -f2 >> $workspace/new_file.cfg
git status -s | grep "^\ M" | cut -d" " -f3 >> $workspace/modify_file.cfg
git status -s | grep "^\ D" | cut -d" " -f3 >> $workspace/delete_file.cfg

#����old��new�ļ��У��������ļ�
make_new_old

#git�ֽ����ύ

pushd "$commit_dir"
git add --all
git commit -m "DTS:$DTS
Description:$Description
APPx:$APPx
Feature or Bugfix:$FeatureorBugfix"
popd


#ִ��upload����
export no_proxy=rnd-hap.huawei.com,10.107.123.187,android.huawei.com,10.107.123.183,10.112.128.40,10.72.16.172,10.107.123.51
git config --global review.10.107.123.187:8080.autoupload true
git config --global review.android.huawei.com:8080.autoupload true
git config --global review.rnd-hap.huawei.com:8080.autoupload true

local_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
if [[ $local_branch == "(no branch)" ]];then
	echo "No branch in local!"
	exit 1
fi

remote_origin=$(git config --list | grep "branch.${local_branch}.remote" | cut -d"=" -f2)
remote_branch=$(git config --list | grep "branch.${local_branch}.merge" | cut -d"=" -f2)

git push ${remote_origin} ${local_branch}:refs/for/${remote_branch}

if [[ $flag == "yes" ]];then
	tar -zcv -f ${dts_dir_name}.tar.gz ${dts_dir_name}
	smbclient $server_path -U china/${domain_user}%"${domain_password}" -c "put ${dts_dir_name}.tar.gz ${DTS}-${name}-${current_date}.tar.gz"
	pushd $current_dir
	dts_server_path=$(echo $server_path | sed 's,/,\\,g')
	python mail.py "${dts_server_path}\\${DTS}-${name}-${current_date}.tar.gz" "" "auto_new_old_tool" "$email_receiver"
fi





