#!bin/bash
#配置参数
DESTINATION_DIMENS=(320 360 400 410 600 720);
#文件名包含下面字符串的文件才会被处理
DIMEN_FILE_NAME_PREFIX_SUFFIX="dimen";

CURRENT_PATH=`pwd`;
VALUES_PARENT_PATH=${CURRENT_PATH}/../app/res;
VALUES_PATH=${VALUES_PARENT_PATH}/values;


#begin
#三个参数
#  1. 源文件路径
#  2. 目标dpi如720
#  3. 目标文件的存储路径
function trans_dimen()
{

	echo "param1=$1, param2=$2, param3=$3"
	if [ $# != 3 ];then
		echo "参数个数应为3个"
		exit 0
	fi

	#系数
	multi_index=`echo "scale=5;$2/360"|bc`;

	#文件名
	desti_file_name=`basename $1`

	sed -i "" "s/\">/\">:/g" "$1"
	sed -i "" "s/dp<\/dimen>/:dp<\/dimen>/g" "$1"
	sed -i "" "s/sp<\/dimen>/:sp<\/dimen>/g" "$1"
	sed -i "" "s/dip<\/dimen>/:dip<\/dimen>/g" "$1"
	awk -F ":" -v param_multi=$multi_index '$1!=""{printf "%s",$1}

		$2==""{printf "\n"} 

		$2!=""&&$2*param_multi == 0{printf "%s", $2; printf "%s\n", $3}
		
		$2!=""&&$2*param_multi != 0 {printf "%.6g%s\n",$2*param_multi,$3}' "$1" > $3/$desti_file_name 
	sed -i "" "s/\">:/\">/g" "$1"
	sed -i "" "s/:dp<\/dimen>/dp<\/dimen>/g" "$1"
	sed -i "" "s/:sp<\/dimen>/sp<\/dimen>/g" "$1"
	sed -i "" "s/:dip<\/dimen>/dip<\/dimen>/g" "$1"
}
#end



#1st create destination values folders if not existing
for des_value in ${DESTINATION_DIMENS[*]};
do
	des_value_folder=${VALUES_PARENT_PATH}/values-sw"$des_value"dp;
	if [ ! -d des_value_folder ];
    then	
		mkdir $des_value_folder;
	fi
done


#2ed
for child in ${VALUES_PATH}/*;
do
	file_name=`basename $child`;
	if [[ $file_name =~ $DIMEN_FILE_NAME_PREFIX_SUFFIX ]]; then
		for des_value in ${DESTINATION_DIMENS[*]};
		do
			des_value_folder=${VALUES_PARENT_PATH}/values-sw"$des_value"dp;
			if [ ! -d des_value_folder ];
			then	
				mkdir $des_value_folder;
			fi
			trans_dimen $child $des_value $des_value_folder
		done
		echo $file_name;
	fi
done
