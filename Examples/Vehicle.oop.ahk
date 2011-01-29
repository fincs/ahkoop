
; Some example objects

class Person
	.constructor(str name)
	{
		this.name := name
	}
	
	method GetName()
	{
		return this.name
	}
endclass

class Vehicle
	.constructor
	{
		this.passengers := Object()
	}
	
	method Enter(Person person)
	{
		this.passengers._Insert(person)
	}
	
	method Travel(place)
	{
		text := "Trip to " place "`n`nPassengers:"
		for each, person in this.passengers
			text .= "`n" person.GetName()
		MsgBox %text%
		this.passengers := Object()
	}
endclass
