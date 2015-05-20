#!/bin/bash
#在debug和release模式间切换:
#  1. 修改百度的key;

#BaiduDebugKey=b3FoWKRsMBFGNlYZmHGGSB0C
#BaiduReleaseKey=kjMxq3M4a6NAf2QaeKTATLlt

helpMessage="\n
go help: 显示帮助\n
go debug: 切换到debug\n
go release: 切换到release\n"

if [ $# == 0 ];then
	echo -e $helpMessage
	exit 0
fi

if [ $1 == "help" ];then
	echo -e $helpMessage
	exit 0
fi

if [ $1 == "debug" ];then
	if [ $(uname) == Darwin ];then
		sed -i "" 's/android:value="kjMxq3M4a6NAf2QaeKTATLlt"/android:value="b3FoWKRsMBFGNlYZmHGGSB0C"/g' AndroidManifest.xml
	else
		sed -i 's/android:value="kjMxq3M4a6NAf2QaeKTATLlt"/android:value="b3FoWKRsMBFGNlYZmHGGSB0C"/g' AndroidManifest.xml
	fi
	exit 0
fi

if [ $1 == "release" ];then
	if [ $(uname) == Darwin ];then
		sed -i "" 's/android:value="b3FoWKRsMBFGNlYZmHGGSB0C"/android:value="kjMxq3M4a6NAf2QaeKTATLlt"/g' AndroidManifest.xml
	else
		sed -i  's/android:value="b3FoWKRsMBFGNlYZmHGGSB0C"/android:value="kjMxq3M4a6NAf2QaeKTATLlt"/g' AndroidManifest.xml
	fi
	exit 0
fi

echo -e $helpMessage
