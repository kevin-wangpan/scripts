#!bin/bash
#修改Android的dimens资源
#两个参数：
#	1. 基准文件
#	2. 基准文件里面的dimension要乘以的系数
sed -i "" "s/\">/\">:/g" "$1"
sed -i "" "s/dp<\/dimen>/:dp<\/dimen>/g" "$1"
sed -i "" "s/sp<\/dimen>/:sp<\/dimen>/g" "$1"
sed -i "" "s/dip<\/dimen>/:dip<\/dimen>/g" "$1"
awk -F ":" -v hhh=$2 '$1!=""{printf "%s",$1} $2==""{printf "\n"} $2!=""{printf "%f%s\n",$2*hhh,$3}' "$1" > ~/Desktop/dimens_$2.xml 
sed -i "" "s/\">:/\">/g" "$1"
sed -i "" "s/:dp<\/dimen>/dp<\/dimen>/g" "$1"
sed -i "" "s/:sp<\/dimen>/sp<\/dimen>/g" "$1"
sed -i "" "s/:dip<\/dimen>/dip<\/dimen>/g" "$1"

