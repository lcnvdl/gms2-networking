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

enum SyncVarBinding {
	//	From sender to receivers
	Regular,
	//	TODO From server to sender and receivers
	Server,
	//	TODO From sender to receivers, from server to sender
	TwoWay
}