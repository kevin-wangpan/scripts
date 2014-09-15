::@y00185015#20111222# version 0.3
::修订内容：增加 以时间为 名称保存 文件
::@y00185925#20111223# version 0.4
::修订内容：增加Ducati Log文件，重新组织目录及文件名
::@y00185925#20111223# version 0.41
::修订内容：增加dropbox,anr文件，重新组织目录及文件名

echo 当前时间是：%time% 即 %time:~0,2%点%time:~3,2%分%time:~6,2%秒%time:~9,2%厘秒

set date_time="%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%"
set Folder="Logs_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%"
mkdir %Folder%

::adb remount

adb shell  cat /sys/kernel/debug/boardid/id > %Folder%/boardid.txt
adb shell  dmesg > %Folder%/dmesg.txt
adb shell  logcat -v time -d -b radio > %Folder%/logcat_ril.txt
adb shell  logcat -v time -d -b radio -s AT > %Folder%/logcat_at.txt
adb shell  logcat -v time -d -s IMCdownload > %Folder%/IMCdownload.txt
adb shell  logcat -v time -d -s nvm_server > %Folder%/nvm_server.txt
adb shell  logcat -v time -d > %Folder%/logcat.txt

adb shell  cat /sys/kernel/debug/remoteproc/omap-rproc.1/version > %Folder%/log_ducati.txt
adb shell  cat /sys/kernel/debug/remoteproc/omap-rproc.1/trace1 >> %Folder%/log_ducati.txt

adb pull   /data/dontpanic/apanic_console %Folder%/apanic_console.txt
adb pull   /data/dontpanic/apanic_threads %Folder%/apanic_threads.txt
adb pull   /data/logs			%Folder%/%date_time%.txt
adb pull   /data/android_logs		%Folder%/
adb pull   /data/system/dropbox         %Folder%/dropbox
adb pull   /data/tombstones             %Folder%/tombstones
adb pull   /data/anr                    %Folder%/anr 




adb shell  bugreport > %Folder%/bug_report.txt

adb shell "rm /data/dontpanic/*"
adb shell "rm /data/system/dropbox/*"
adb shell "rm /data/corefile/*"
adb shell "rm /data/tombstones/*"
adb shell "rm /data/anr/*"
adb shell "rm /data/logs/*.*"
adb shell "rm /data/android_logs/*.*"
pause
