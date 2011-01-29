;
; File encoding:  UTF-8
; Platform:  Windows XP/Vista/7
; Author:    A.N.Other <myemail@nowhere.com>
;
; Script description:
;	Template script
;

#NoEnv
SendMode Input
SetWorkingDir, %A_ScriptDir%

MsgBox % "2 + 3 = " Add(2, 3)
; MsgBox % Add("in", "valid")

strong Add(num a, num b)
{
	return a + b
}

val1 := [new Value]
val1.val := "Hello"

val2 := [new Value]
val2.val := "World"

val3 := [new Value]
val3.val := "Hello"

msgbox % val1.CompareTo(val2)
msgbox % val1.CompareTo(val3)
msgbox % val1.CompareTo("wewww")

class Value
	property val
		set v
		{
			return this._val := v
		}
		get
		{
			return this._val
		}
	endprop
	method CompareTo(Value o)
	{
		return this._val = o._val
	}
endclass
