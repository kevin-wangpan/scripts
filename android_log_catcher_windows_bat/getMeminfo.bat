@echo off
:top
echo still running
adb shell dumpsys meminfo com.huawei.android.launcher >> HwLauncher_meminfo.log
ping -n 4 127.1>nul
goto top
