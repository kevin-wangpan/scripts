@echo off
:top
echo still running
adb shell procrank|findstr com.huawei.android.launcher>> launcher.log
goto top
