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

class Duck
	method Quack
	{
		MsgBox Quaaaaaack!
	}
	method Feathers
	{
		MsgBox The duck has white and gray feathers.
	}
endclass

class Person
	method Quack
	{
		MsgBox The person imitates a duck.
	}
	method Feathers
	{
		MsgBox The person takes a feather from the ground and shows it.
	}
	method Name
	{
		MsgBox John Smith
	}
endclass

InTheForest(obj)
{
	MsgBox % "Type: " [typeof obj]
	obj.Quack()
	obj.Feathers()
}

InTheForest([new Duck])
InTheForest([new Person])
