#!bin/bash
#做dimen的转换
#三个参数：第一个基准dimen文件的路径，第二个表示source的dpi，第三个表示目标dpi
echo "$1"

#获取文件名前缀
name_prefix=`basename $1 .xml`
echo "name_prefix=$name_prefix"

sed -i  "s/\">/\">:/g" "$1"
sed -i  "s/dp<\/dimen>/:dp<\/dimen>/g" "$1"
sed -i  "s/sp<\/dimen>/:sp<\/dimen>/g" "$1"
sed -i  "s/dip<\/dimen>/:dip<\/dimen>/g" "$1"
awk -F ":" -v param2=$2 -v param3=$3 '$1!=""{printf "%s",$1} $2==""{printf "\n"} $2!=""&&param3==""{printf "%.6g%s\n",$2*param2,$3} $2!=""&&param3!=""{printf "%.6g%s\n",$2*param3/param2,$3}' "$1" > abc.txt

mv ./abc.txt $1
