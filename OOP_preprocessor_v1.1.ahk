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
		, "i)\[typeof\s+?(.+?)\]", "(($1).__Class)")
		, "i)\[super\]\(", "base.__New(")
		, "i)\[super\]", "base.__New()")
		. comment)
}

ConvertClass(fin, fout, classn, inh)
{
	fout.WriteLine("class " classn (inh ? " extends " inh : ""))
	fout.WriteLine("{")
	propsetlist := "", propgetlist := ""
	while !fin.AtEOF
	{
		line := RTrim(fin.ReadLine(), "`r`n")
		tline := Trim(line)
		fline := RTrim(RegExReplace(tline, "\s+;.*$"))
		if tline ~= "i)^endclass"
			break
		else if RegExMatch(tline, "i)^\.constructor\s*\((.*?)\)(.*)$", o)
			WriteMethod(fout, "", "__New", o1, o2, "`t", "this.")
		else if RegExMatch(tline, "i)^\.constructor(.*)$", o)
			fout.WriteLine("`t__New()" o1)
		else if RegExMatch(tline, "i)^\.destructor(.*)$", o)
			fout.WriteLine("`t__Delete()" o1)
		else if RegExMatch(tline, "i)^method\s+(.+?)\s*\((.*?)\)(.*)$", o)
			WriteMethod(fout, "", o1, o2, o3, "`t", "this.")
		else if RegExMatch(tline, "i)^method\s+(.+?)(\s+.*)?$", o)
			fout.WriteLine("`t" o1 "()" o2)
		else if RegExMatch(fline, "i)^property\s+(.*)$", o)
			ConvertProperty(fin, fout, classn, o1, propgetlist, propsetlist)
		else
			Preprocess(fin, fout, line, inh)
	}
	
	if propgetlist
	{
		fout.WriteLine("`t__Get(m)")
		fout.WriteLine("`t{")
		fout.WriteLine("`t`tif (m != ""base"") && ObjHasKey(this.base, (q:=""__get_"" m))")
		fout.WriteLine("`t`t`treturn this[q]()")
		fout.WriteLine("`t}")
	}
	
	if propsetlist
	{
		fout.WriteLine("`t__Set(m, ByRef v)")
		fout.WriteLine("`t{")
		fout.WriteLine("`t`tif ObjHasKey(this.base, (q:=""__set_"" m))")
		fout.WriteLine("`t`t`treturn this[q](v)")
		fout.WriteLine("`t}")
	}
	
	fout.WriteLine("}")
	fout.WriteLine("")
	fout.WriteLine(classn "(prm*)")
	fout.WriteLine("{")
	fout.WriteLine("`tglobal " classn)
	fout.WriteLine("`treturn new " classn "(prm*)")
	fout.WriteLine("}")
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
			fout.WriteLine("`t__get_" prop "()" o1), propgetlist := true
		else if RegExMatch(tline, "i)^set\s+([^\s{]+)(.*)$", o)
			fout.WriteLine("`t__set_" prop "(ByRef " o1 ")" o2), propsetlist := true
		else
			Preprocess(fin, fout, line)
	}
}

WriteMethod(fout, p1, p2, prm, trailing, ind="", pre="")
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
		fout.WriteLine(ind p1 p2 "(" prm ")" trailing)
	else
	{
		list := LTrim(list, " "), plist := LTrim(plist, " ")
		fout.WriteLine(ind p1 p2 "(" list ")")
		fout.WriteLine(ind "{")
		fout.WriteLine(ind "`terr := """"")
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
			fout.WriteLine(ind "`t`terr := """ var " should be of type " typ """")
			continue
			
			_typ0: ; class
			fout.WriteLine(ind "`t" iff " (" var ".__Class) != """ typ """")
			return
			
			_typ1: ; built-in
			fout.WriteLine(ind "`t" iff " " var " is not " typ)
			return
			
			_typ2: ; string
			fout.WriteLine(ind "`t" iff " IsObject(" prm.var ")") ; anything non-string is an object
			return
			
			_typ3: ; object
			fout.WriteLine(ind "`t" iff " !IsObject(" prm.var ")")
			return
		}
		fout.WriteLine(ind "`tif err")
		fout.WriteLine(ind "`t{")
		fout.WriteLine(ind "`t`tMsgBox, 16,, Type mismatch:``n%err%")
		fout.WriteLine(ind "`t`tExit")
		fout.WriteLine(ind "`t}")
		fout.WriteLine(ind "`t" (p2 != "__New" ? "return " : "") pre p1 "_imp_" p2 "(" plist ")")
		fout.WriteLine(ind "}")
		fout.WriteLine(ind p1 "_imp_" p2 "(" list ")" trailing)
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
