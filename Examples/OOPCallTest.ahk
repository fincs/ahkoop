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

; Include the preprocessed file
#Include Vehicle.pre.ahk

; Using OOP AHK_L objects from standard AHK_L
car := Vehicle()
msgbox % "typeof(car) = " typeof(car)
car.Enter(Person("John Smith"))
car.Enter(Person("John Doe"))
car.Enter(Person("Joe Bloggs"))
car.Travel("Nowhere")

#include ../Lib/typeof.ahk
