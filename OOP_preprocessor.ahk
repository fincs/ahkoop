#NoEnv
#NoTrayIcon

if 0 = 1
	cmd = "%1%"

if A_AhkVersion >= 1.1.00.00
	file = %A_ScriptDir%\OOP_preprocessor_v1.1.ahk
else
	file = %A_ScriptDir%\OOP_preprocessor_v1.ahk

RunWait, "%file%" %cmd%
