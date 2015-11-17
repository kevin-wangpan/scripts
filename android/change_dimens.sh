#!bin/bash
#做dimen的转换
#可以有两个参数：第一个基准dimen文件的路径，第二个要做乘法的index
#或者用三个参数：第一个参数同上，第二个表示source的dpi，第三个表示目标dpi
echo "$1"
name_suffix=temp
if [ $# == 2 ];then
  name_suffix=$2
  echo "2 params, multiply index=$2"
elif [ $# == 3 ];then
  multi_index=`echo "scale=5;$3/$2"|bc`
  name_suffix=$3
  echo "3 params, source dpi=$2, destination dpi=$3, multiply index=$multi_index"
else
  echo "invalid params: $# params"
  exit 0
fi

#获取文件名前缀
name_prefix=`basename $1 .xml`
echo "name_prefix=$name_prefix"

sed -i "" "s/\">/\">:/g" "$1"
sed -i "" "s/dp<\/dimen>/:dp<\/dimen>/g" "$1"
sed -i "" "s/sp<\/dimen>/:sp<\/dimen>/g" "$1"
sed -i "" "s/dip<\/dimen>/:dip<\/dimen>/g" "$1"
awk -F ":" -v param2=$2 -v param3=$3 '$1!=""{printf "%s",$1} $2==""{printf "\n"} $2!=""&&param3==""{printf "%.6g%s\n",$2*param2,$3} $2!=""&&param3!=""{printf "%.6g%s\n",$2*param3/param2,$3}' "$1" > ~/Desktop/${name_prefix}_sw${name_suffix}dp.xml 
sed -i "" "s/\">:/\">/g" "$1"
sed -i "" "s/:dp<\/dimen>/dp<\/dimen>/g" "$1"
sed -i "" "s/:sp<\/dimen>/sp<\/dimen>/g" "$1"
sed -i "" "s/:dip<\/dimen>/dip<\/dimen>/g" "$1"

