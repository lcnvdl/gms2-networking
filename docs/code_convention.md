# Code Convention

## ISOLATED FUNCTIONS

### + Public functions:
1.	Snake case

### + Arguments:
1.	Camel case (preferred)
2.  Camel case starting with underscore (if the name has already been used)
3.	Camel case starting with DOUBLE underscore (unused parameters)


## STRUCTS AND OBJECTS

### + Struct methods:
1.	Pascal case (public methods)
2.	Pascal case starting with underscore (private / protected methods)

### + Constructor parameters:
1.	Camel case starting with underscore

### + Struct fields:
1.	Camel case (public fields)
2.	Camel case starting with underscore (private / protected fields)

## ENUMS

### + Enum name:
1.	Pascal case

### + Enum values:
1.	Pascal case

## MACROS

### + Macro name:
1.	Snake case (uppercase)

## CONDITIONS
```
if (myCondition || myOtherCondition) {
	show_debug_message("This is good");
}
```

## LOOPS
```
while (myCondition) {
	show_debug_message("This is good");
}
```

## NAMESPACES

You can use namespaces as prefix. The prefixes should start with lower case.
Also, it is allowed to use an underscore after the namespace prefix. The only 
rule here is that you have to be consistent.

Example:
```
//	Without namespace
enum CarColors {
	Red,
	Blue,
	Green
}

//	With namespace
enum nwCarColors {
	Red,
	Blue,
	Green
}

//	With namespace (optional underscore separation)
enum nw_CarColors {
	Red,
	Blue,
	Green
}
```
