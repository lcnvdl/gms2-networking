enum NwMessageType {
	syncObjectCreate,
	syncObjectUpdate,
	syncObjectDelete,
	syncClientLocation,
	syncPackage
}

enum SmoothType {
	None = 0,
	Number = 1,
	Angle = 2
}

#macro SV_BOOLEAN "boolean"
#macro SV_INT "integer"
#macro SV_INTEGER "integer"
#macro SV_NUMBER "number"
#macro SV_DECIMAL "number"
#macro SV_TEXT "string"
#macro SV_STRING "string"