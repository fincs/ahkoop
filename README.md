OOP preprocessor for AutoHotkey_L, version 1.1b - by fincs
==========================================================

This OOP preprocessor allows you to create OOP classes in a more friendly way (aka syntax sugar) that is compatible with both old AHK_L builds and AHK v1.1. This is done via processing the OOP script before running it in order to rewrite it to use the available AutoHotkey_L constructs.

## 0. Changelog

* version 1.1b
    * Added support for converting OOP scripts to AutoHotkey v1.1 class syntax.
* version 1.1a
    * Fixed destructor bug.
    * Added typeof() StdLib file.
* version 1.1
    * Added strong typing and properties.
* version 1.0
    * Initial release.

## 1. OOP files

In order to differentiate between OOP scripts and regular scripts the former have the .oop.ahk extension as opposed to just .ahk. Preprocessed files have the .pre.ahk extension.

## 2. Usage of the preprocessor

Drag & drop an .oop.ahk file to the preprocessor or run it with no parameters in order to convert all scripts in the current directory.

Alternatively you can drag & drop an .oop.ahk file to the RunOOP.ahk script in order to run the script after converting.

## 3. Language OOP extensions

### 3.1. Class definitions

A class looks like this:

    ; Base class
    class ClassName
    ; Derived class
    class ClassName inherits BaseClass
    
        ; Optional. If no parameters are desired you can omit the parentheses.
        .constructor(params...)
        {
            ; ...
        }
        
        ; Optional.
        .destructor
        {
            ; ...
        }
        
        ; Method definition. Ditto for the parentheses.
        method MethodName(params...)
        {
            ; ...
        }
        
        ; Property definition
        property PropName
            
            ; (Optional) Getter.
            get
            {
                ; ...
            }
            
            ; (Optional) Setter.
            set VarName
            {
                ; ...
            }
            
        endprop
    
    endclass

The object instance is accessed by the this variable.

### 3.2. Pseudo-operators

- Instantiating a class: `[new ClassName]`
- Instantiating a class with parameters: `[new ClassName](params...)`
- Getting the type of an object: `[typeof Var]`
- Calling the constructor of a derived class' base class: `[super]`
- Calling the constructor of a derived class' base class with parameters: `[super](params...)`

### 3.3. Strong typing

In order to ease dealing with different types a strong typing feature is available for class methods & constructors. Strong typing consists in checking the types of parameters before executing the method body. It is triggered by prepending a type name to the parameter (not supported in ByRef mode nor in variadic lists).
The following types can be used:

- Any class name.
- int, float, num, str, date and obj.

Example:

    method Enter(Person p, obj data)
    {
        ; ...
    }

Strong typing is also available for regular functions:

    strong Add(num a, num b)
    {
        return a + b
    }

### 3.4. Using classes in non-OOP scripts

You can #Include preprocessed OOP scripts in non-OOP scripts and use its classes. The OOP preprocessor exposes constructors as functions called like the class name, so you can create objects like this:

    obj := MyClass(constructor parameters...)

In order to access the type name you can use the included typeof.ahk StdLib file:

    obj := MyClass()
    MsgBox % typeof(obj)

### 3.5. Of AutoHotkey_L and AutoHotkey v1.1

Version 1.1b of this program added support for converting OOP scripts to AutoHotkey v1.1's class syntax. This thus renders this program useful for being easily compatible with both AutoHotkey v1.1 and old versions of AutoHotkey_L. The major incompatibility is that in AutoHotkey v1.1 the class name is stored under the field `__Class` instead of `__Type`. The provided typeof.ahk file takes care of this, and if you have done the right thing and relied on said supplied file, you shouldn't notice any problems.

Additionally, OOP_preprocessor.ahk calls either OOP_preprocessor_v1.ahk or OOP_preprocessor_v1.1.ahk depending on the AutoHotkey build used to run the script.

## 4. Known Issues

* Pseudo-operator processing affects string literals (except continuation sections).
* Class/endclass and property/endprop syntax is verbose.
