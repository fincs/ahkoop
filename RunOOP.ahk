;
; File encoding:  UTF-8
; Platform:  Windows XP/Vista/7
; Author:    A.N.Other <myemail@nowhere.com>
;
; Script description:
;	Template script
;

#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir, %A_ScriptDir%

if 0 = 1
{
	RunWait, "%A_AhkPath%" OOP_preprocessor.ahk "%1%"
	StringReplace, a, 1, .oop.ahk, .pre.ahk, All
	IfExist, %a%
		RunWait, "%A_AhkPath%" /ErrorStdOut "%a%"
}else
	MsgBox, Usage: %A_ScriptName% ScriptFile.oop.ahk
