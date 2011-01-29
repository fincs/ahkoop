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

if 0 = 1
	Loop, %1%
		ConvertFile(A_LoopFileLongPath)
else
{
	MsgBox, 68, OOP preprocessor, Click Yes to convert all OOP scripts in the current directory.
	IfMsgBox, No
		ExitApp
	Loop, *.oop.ahk
		ConvertFile(A_LoopFileName)
}

ExitApp

ConvertFile(infname)
{
	StringReplace, outfname, infname, .oop.ahk, .pre.ahk, UseErrorLevel
	if ErrorLevel != 1
	{
		MsgBox, 16, OOP preprocessor, File doesn't end in .oop.ahk.
		return
	}else IfNotExist, %infname%
	{
		MsgBox, 16, OOP preprocessor, File does not exist.
		return
	}
	FileGetTime, t1, %infname%
	FileGetTime, t2, %infname%
	if(t2 > t1)
		return
	FileDelete, %outfname%
	fin := FileOpen(infname, "r`r`n")
	fout := FileOpen(outfname, "w`n", fin.Encoding)
	
	Convert(fin, fout)
	
	fin.Close(), fout.Close()
}

Convert(fin, fout)
{
	while !fin.AtEOF
	{
		line := RTrim(fin.ReadLine(), "`r`n")
		tline := RTrim(RegExReplace(Trim(line), "\s+;.*$"))
		if !RegExMatch(tline, "i)^class\s+?(.*)$", o)
		{
			Preprocess(fin, fout, line)
			continue
		}
		o2 := ""
		if RegExMatch(o1, "^(.*)\s+inherits\s+(.*)$", p)
			o1 := p1, o2 := p2
		ConvertClass(fin, fout, o1, o2)
	}
}

Preprocess(fin, fout, line, inh="")
{
	rline := Trim(line)
	if rline ~= "^\("
	{
		fout.WriteLine(line)
		while !fin.AtEOF
		{
			line := RTrim(fin.ReadLine(), "`r`n")
			if Trim(line) ~= "^\)"
				break
			fout.WriteLine(line)
		}
	}else if rline ~= "^/\*"
	{
		fout.WriteLine(line)
		while !fin.AtEOF
		{
			line := RTrim(fin.ReadLine(), "`r`n")
			if Trim(line) ~= "^\*/"
				break
			fout.WriteLine(line)
		}
	}else if RegExMatch(line, "i)^\s*strong\s+(.+?)\s*\((.*?)\)(.*)$", o)
	{
		WriteMethod(fout, "", o1, o2, o3)
		return
	}
	RegExMatch(line, "\s;(.*)$", comment)
	StringTrimRight, line, line, % StrLen(comment)
	
	fout.WriteLine(RegExReplace(RegExReplace(RegExReplace(RegExReplace(RegExReplace(line
		, "i)\[new\s+?(.+?)\]\(", "$1(")
		, "i)\[new\s+?(.+?)\]", "$1()")
		, "i)\[typeof\s+?(.+?)\]", "(($1).__Type)")
		, "i)\[super\]\(", "_" inh "__ctor(this,")
		, "i)\[super\]", "_" inh "__ctor(this)")
		. comment)
}

ConvertClass(fin, fout, classn, inh)
{
	baselist := """__Type"", """ classn """"
	propsetlist := "", propgetlist := ""
	hasCtor := false, hasDtor := false
	while !fin.AtEOF
	{
		line := RTrim(fin.ReadLine(), "`r`n")
		tline := Trim(line)
		fline := RTrim(RegExReplace(tline, "\s+;.*$"))
		if tline ~= "i)^endclass"
			break
		else if RegExMatch(tline, "i)^\.constructor\s*\((.*?)\)(.*)$", o)
			;fout.WriteLine("_" classn "__ctor(this" ((ctorprmcnt:=Count(o1)) ? ", " : "") o1 ")" o2)
			WriteMethod(fout, "_" classn "_", "_ctor", "this" ((ctorprmcnt:=Count(o1)) ? ", " : "") o1, o2)
			, hasCtor := true
		else if RegExMatch(tline, "i)^\.constructor(.*)$", o)
			fout.WriteLine("_" classn "__ctor(this)" o1)
			, hasCtor := true
		else if RegExMatch(tline, "i)^\.destructor(.*)$", o)
			fout.WriteLine("_" classn "__dtor(this)" o1), hasDtor := true
			, Append(baselist, """__Delete"", ""_" classn "__dtor_entry""")
		else if RegExMatch(tline, "i)^method\s+(.+?)\s*\((.*?)\)(.*)$", o)
			;fout.WriteLine("_" classn "_" o1 "(this" (Count(o2) ? ", " : "") o2 ")" o3)
			WriteMethod(fout, "_" classn "_", o1, "this" (Count(o2) ? ", " : "") o2, o3)
			, Append(baselist, """" o1 """, ""_" classn "_" o1 """")
		else if RegExMatch(tline, "i)^method\s+(.+?)(\s+.*)?$", o)
			fout.WriteLine("_" classn "_" o1 "(this)" o2)
			, Append(baselist, """" o1 """, ""_" classn "_" o1 """")
		else if RegExMatch(fline, "i)^property\s+(.*)$", o)
			ConvertProperty(fin, fout, classn, o1, propgetlist, propsetlist)
		else
			Preprocess(fin, fout, line, inh)
	}
	
	if propgetlist
	{
		Append(baselist, """__Get"", ""_" classn "__get""")
		fout.WriteLine("_" classn "__get(this, m)")
		fout.WriteLine("{")
		fout.WriteLine("`tstatic _m := Object(" propgetlist ")")
		fout.WriteLine("`tif _m[m]")
		fout.WriteLine("`t`treturn _m[m](this)")
		fout.WriteLine("}")
	}
	
	if propsetlist
	{
		Append(baselist, """__Set"", ""_" classn "__set""")
		fout.WriteLine("_" classn "__set(this, m, v)")
		fout.WriteLine("{")
		fout.WriteLine("`tstatic _m := Object(" propsetlist ")")
		fout.WriteLine("`tif _m[m]")
		fout.WriteLine("`t`treturn _m[m](this, v)")
		fout.WriteLine("}")
	}
	
	if inh
		Append(baselist, """base"", _" inh "__base()")
	fout.WriteLine("_" classn "__base()")
	fout.WriteLine("{")
	fout.WriteLine("`tstatic _base := Object(" baselist ")")
	fout.WriteLine("`treturn _base")
	fout.WriteLine("}")
	fout.WriteLine(classn (ctorprmcnt ? "(prm*)" : "()"))
	fout.WriteLine("{")
	;fout.WriteLine("`tstatic _base := Object(" baselist ")")
	fout.WriteLine("`tstatic _base := _" classn "__base()")
	fout.WriteLine("`tthis := Object(""__Inst"", 1, ""base"", _base)")
	if hasCtor
		fout.WriteLine("`t_" classn "__ctor(this" (ctorprmcnt ? ", prm*" : "") ")")
	else if inh
		fout.WriteLine("`t_" inh "__ctor(this)")
	fout.WriteLine("`treturn this")
	fout.WriteLine("}")
	if hasDtor
	{
		fout.WriteLine("_" classn "__dtor_entry(this)")
		fout.WriteLine("{")
		fout.WriteLine("`tif this.__Inst")
		fout.WriteLine("`t`t_" classn "__dtor(this)")
		fout.WriteLine("}")
	}
}

ConvertProperty(fin, fout, classn, prop, ByRef propgetlist, ByRef propsetlist)
{
	while !fin.AtEOF()
	{
		line := RTrim(fin.ReadLine(), "`r`n")
		tline := Trim(line)
		if tline ~= "i)^endprop"
			break
		else if RegExMatch(tline, "i)^get(.*)$", o)
			fout.WriteLine("_" classn "__get_" prop "(this)" o1)
			, Append(propgetlist, """" prop """, ""_" classn "__get_" prop """")
		else if RegExMatch(tline, "i)^set\s+([^\s{]+)(.*)$", o)
			fout.WriteLine("_" classn "__set_" prop "(this, ByRef " o1 ")" o2)
			, Append(propsetlist, """" prop """, ""_" classn "__set_" prop """")
		else
			Preprocess(fin, fout, line)
	}
}

WriteMethod(fout, p1, p2, prm, trailing)
{
	isStrong := false
	chk := Object()
	list := "", plist := ""
	StringReplace, prr, prm, ```,, ``?, All
	Loop, Parse, prr, `,
	{
		q := Trim(A_LoopField)
		StringReplace, q, q, ``?, ```,, All
		if RegExMatch(q, "^([^=]+)\s+([^=]+)(.*)?$", o)
		{
			if o1 = ByRef
				goto _no
			isStrong := true
			chk._Insert(Object("typ", o1, "var", o2, "ext", o3))
			Append(list, o2 o3)
			Append(plist, o2)
			continue
		}
		
		_no:
		Append(list, q)
		RegExMatch(q, "i)^(?:byref\s+)?([^=]+)(.*)$", o)
		Append(plist, o1)
	}
	if !isStrong
		fout.WriteLine(p1 p2 "(" prm ")" trailing)
	else
	{
		fout.WriteLine(p1 p2 "(" list ")")
		fout.WriteLine("{")
		fout.WriteLine("`terr := """"")
		for each, prm in chk
		{
			static typs := Object("int", "integer", "float", "float", "num", "number", "time", "time")
			iff := (A_Index > 1) ? "else if" : "if"
			var := prm.var, typ := prm.typ, typtyp := 0 ; class
			if typs[typ]
				typtyp := 1, typ := typs[typ] ; built-in
			else if typ = str
				typtyp := 2, typ := "string"
			else if typ = obj
				typtyp := 3, typ := "object"
			gosub _typ%typtyp%
			fout.WriteLine("`t`terr := """ var " should be of type " typ """")
			continue
			
			_typ0: ; class
			fout.WriteLine("`t" iff " (" var ".__Type) != """ typ """")
			return
			
			_typ1: ; built-in
			fout.WriteLine("`t" iff " " var " is not " typ)
			return
			
			_typ2: ; string
			fout.WriteLine("`t" iff " IsObject(" prm.var ")") ; anything non-string is an object
			return
			
			_typ3: ; object
			fout.WriteLine("`t" iff " !IsObject(" prm.var ")")
			return
		}
		fout.WriteLine("`tif err")
		fout.WriteLine("`t{")
		fout.WriteLine("`t`tMsgBox, 16,, Type mismatch:``n%err%")
		fout.WriteLine("`t`tExit")
		fout.WriteLine("`t}")
		fout.WriteLine("`treturn " p1 "_imp_" p2 "(" plist ")")
		fout.WriteLine("}")
		fout.WriteLine(p1 "_imp_" p2 "(" list ")" trailing)
	}
}

Count(list, delim=",")
{
	StringReplace, list, list, % delim, % delim, UseErrorLevel
	return Trim(list) ? (ErrorLevel+1) : 0
}

Append(ByRef list, item, delim=",")
{
	list .= (Count(list,delim) ? delim : "") " " item
}
