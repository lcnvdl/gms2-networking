enum NwMessageType {
	syncObjectCreate,
	syncObjectUpdate,
	syncObjectDelete,
	syncClientLocation,
	syncPackage,
	///	@deprecated
	rpcCall,
	///	@deprecated
	rpcCallExecute,
	///	@deprecated
	rpcCallReplicate,
	///	@deprecated
	rpcCallReply,
	//	Server-sender to Client-receivers
	rpcSenderBroadcastCall,
	//	Client-sender to Server-Receiver (then Client-receivers)
	rpcSenderBroadcastReplicate,
	//	Client-sender to Server-receiver
	rpcSenderFunctionCall,
	//	Server-receiver replies to Client-Sender
	rpcSenderFunctionReply
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

enum RpcFunctionCallerAllowance {
	Client,
	Server,
	Sender,
	Receiver,
	Owner,
	Everyone
}

enum RpcFunctionExecutor {
	Client,
	Server,
	Sender,
	Receiver,
	Owner,
	Everyone
}