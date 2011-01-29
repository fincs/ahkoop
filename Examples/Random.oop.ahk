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

gen := [new Random]
Loop, 3
	msgbox % gen.Number
gen.Min := 1
gen.Max := 10
Loop, 3
	msgbox % gen.Number

class Random
	.constructor
	{
		this.l1 := 0, this.l2 := 2147483647
	}
	property Number
		get
		{
			Random, v, % this.l1, % this.l2
			return v
		}
	endprop
	property Min
		set	v
		{
			if v is number
				return this.l1 := v
		}
		get
		{
			return this.l1
		}
	endprop
	property Max
		set v
		{
			if v is number
				return this.l2 := v
		}
		get
		{
			return this.l2
		}
	endprop
	property Seed
		set v
		{
			if v is integer
			if v between 0 and 4294967295
			{
				Random,, %v%
				return v
			}
		}
	endprop
endclass
