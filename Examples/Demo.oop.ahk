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

class Message
	.constructor(message="Hello World!")
	{
		this.when    := A_TickCount
		this.message := message
	}
	
	.destructor
	{
		if [typeof this] != "Message"
			MsgBox Message destructor!
	}
	
	method Display
	{
		MsgBox % this.message
	}
	
	method SetNew(message)
	{
		this.message := message
	}
endclass

class CloneOfMessage inherits Message
	.constructor
	{
		[super]("Message clone object!")
	}
endclass

class Useless
	method AmIUseless
	{
		type := [typeof this]
		MsgBox % (type = "Useless" ? "Yeah" : "No") ", I'm " type "..."
	}
endclass

class Useful inherits Useless
	.constructor
	{
		MsgBox % [typeof this] " object instantiated!"
	}
endclass

class EvenMoreUseful inherits Useful
	method AddNums(num a, num b)
	{
		return a + b
	}
endclass

msg1 := [new Message] ; Usage: [new ClassName]
msg1.Display()
msg2 := [new Message]("True OOP!") ; Parameters are also accepted.
msg2.Display()

clone := [new CloneOfMessage]
clone.Display()

useless := [new Useless]
useless.AmIUseless()

useful := [new EvenMoreUseful]
msgbox % "2 + 2 = " useful.AddNums(2, 2)
useful.AmIUseless()
