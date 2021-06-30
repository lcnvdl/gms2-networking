//	Globals
global.nwNetworkManager = id;
global.nwNetworkManagerFactory = function() { return getGmlNetworkEngine(); };

//	Delta time
_dt = 0;

//	Socket ID
serverSocket = -1;

//	Is server?
serverMode = false;

//	Is offline?
offline = true;

//	Where to connect?
networkSettings = {
	ip: "127.0.0.1",
	port: 3456
};

//
_clientsMgr = new nw_ClientsManager();
_sendersMgr = new nw_SendersManager();
_receiversMgr = new nw_ReceiversManager();
_serverController = undefined;

lastSync = 0;
nwCamera = noone
nwCamX = 0;
nwCamY = 0;

engine = undefined;

//	Events
evListener(id);

//	Public functions
#region Public functions

function startServer() {
	try {
		assert_is_true(offline, "The game already has an open connection.");
		
		_createEngineInstance();
		_serverController = new nw_ServerController();
		serverSocket = engine.serve(networkSettings.port);
		serverMode = true;
		offline = false;
		evCall(EV_SERVER_CONNECT);
	}
	catch(err) {
		show_error(err, false);
		serverSocket = -1;
	}

	return serverSocket;
}

function startClient() {
	try {
		assert_is_true(offline, "The game already has an open connection.");
		
		_createEngineInstance();
		serverSocket = engine.connect(networkSettings.ip, networkSettings.port);
		serverMode = false;
		offline = false;
		evCall(EV_CLIENT_CONNECT);
	}
	catch(err) {
		show_error(err, false);
		serverSocket = -1;
	}

	return serverSocket;
}

function nwSetCamera(obj) {
	nwCamera = obj;
}

function getSendersManager() {
	return _sendersMgr;	
}

function getServerController() {
	return _serverController;	
}

function nwRegisterObjectAsSyncSender(instance, _uuid, _opts) {
	var newId = _sendersMgr.Register(instance, _uuid, _opts);
	_syncNow();
	
	return newId;
}

function nwSendBroadcast(_name, _data) {
	assert_is_not_undefined(_data);
	assert_is_string(_name);
	
	var _package = {
		name: _name,
		data: _data
	};
	
	nwBroadcast(NwMessageType.syncPackage, _package);
}

function nwSend(_socket, _name, _data) {
	assert_is_not_undefined(_socket);
	assert_is_not_undefined(_data);
	assert_is_string(_name);
	
	var _package = {
		name: _name,
		data: _data
	};
	
	engine.send(sendBuffer, _socket, NwMessageType.syncPackage, _package);
}

function callRpcFunction(instanceUuid, fnName, fnArgs, isFirstCall, callback) {
	var existing = undefined;
	var _uuid = instanceUuid;
	with(all) {
		if(variable_instance_exists(id, "nwUuid")) {
			if(nwUuid == _uuid) {
				existing = id;	
			}
		}
	}
	
	if (!is_undefined(existing)) {
		var rpc = existing.rpcFunctions[$ fnName];
		var isSender = _sendersMgr.Exists(_uuid);
		var isReceiver = !isSender;
		
		if (rpc.allowance == RpcFunctionCallerAllowance.Everyone ||
			(rpc.allowance == RpcFunctionCallerAllowance.Client && nw_is_client()) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Server && nw_is_server()) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Owner && id == existing) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Receiver && isReceiver) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Sender && isSender)
		) {
			if (!variable_instance_exists(existing, "rpcWaiters")) {
				existing.rpcWaiters = {};
			}
			
			for(var i = 0; i < array_length(rpc.executors); i++) {
				var executor = rpc.executors[i];
				var package = {
					id: getUuid(),
					instance: instanceUuid, 
					name: fnName, 
					args: fnArgs,
					from: -1,
					to: executor
				};

				var waitForReply = false;
				
				if (executor == RpcFunctionExecutor.Owner) {
					if (id == existing) {
						rpc.Call(fnArgs);
					}
				}
				else if (executor == RpcFunctionExecutor.Client) {
					if (nw_is_client()) {
						rpc.Call(fnArgs);
						if (isFirstCall) {
							package.from = RpcFunctionExecutor.Client;
							engine.send(sendBuffer, _socket, NwMessageType.rpcCall, package);
						}
					}
					else {
						package.from = RpcFunctionExecutor.Server;
						nwBroadcast(NwMessageType.rpcCall, package);
						waitForReply = true;
					}
				}
				else if (executor == RpcFunctionExecutor.Server) {
					if (nw_is_server()) {
						rpc.Call(fnArgs);
					}
					else {
						if (isFirstCall) {
							package.from = RpcFunctionExecutor.Client;
							engine.send(sendBuffer, _socket, NwMessageType.rpcCall, package);
							waitForReply = true;
						}
					}
				}
				else if (executor == RpcFunctionExecutor.Receiver) {
					if (isReceiver) {
						rpc.Call(fnArgs);
					}
					else {	//	Sender
						if (nw_is_client()) {
							package.from = RpcFunctionExecutor.Sender;
							engine.send(sendBuffer, _socket, NwMessageType.rpcCall, package);
							waitForReply = true;
						}
						else if (nw_is_server()) {
							package.from = RpcFunctionExecutor.Sender;
							nwBroadcast(NwMessageType.rpcCall, package);	
							waitForReply = true;
						}
					}
				}
				else if (executor == RpcFunctionExecutor.Sender) {
					if (isSender) {
						rpc.Call(fnArgs);
					}
				}
			
				if (waitForReply) {
					existing.rpcWaiters[$ package.id] = { package: package, callback: callback, timeout: 30000 };
				}
			}
		}
	}
	
	return -1;
}

function registerRpcFunction(instance, name, fnCall, _opts) {
	if (!variable_instance_exists(instance, "nwUuid")) {
		throw "The instance must be a sender or a receiver";	
	}
	
	if (!variable_instance_exists(instance, "rpcFunctions")) {
		instance.rpcFunctions = {};
	}
	
	instance.rpcFunctions[$ name] = new nw_RpcFunction(name, fnCall, _opts);
}

#endregion	//	Public functions

//	Internal functions
#region Internal functions

function emitSenderUpdate(packageToSend, senderX, senderY) {
	if(serverMode) {
		//	TODO Ver de donde sacar X e Y
		nwBroadcastByDistance(
			NwMessageType.syncObjectUpdate, 
			packageToSend, 
			senderX,
			senderY);
		// nwBroadcast(NwMessageType.syncObjectUpdate, packageToSend);
	}
	else {
		//	TODO	Do it with some credentials
		engine.send(sendBuffer, serverSocket, NwMessageType.syncObjectUpdate, packageToSend);
	}
}

function emitSenderDelete(senderId) {
	if(serverMode) {
		nwBroadcast(NwMessageType.syncObjectDelete, { uuid: senderId });
	}
	else {
		//	TODO	Do it with some credentials
		engine.send(sendBuffer, serverSocket, NwMessageType.syncObjectDelete, { uuid: senderId });
	}
}

function nwBroadcastByDistance(msgId, data, _x, _y) {
	show_debug_message("broadcast by distance " + string (msgId) + ":" + json_stringify(data));
	
	ds_list_foreach(_clientsMgr.clients, function(client, index, args) {
		var clientInfo = args.mgr.GetInfo(client);
		
		if (point_distance(args.X, args.Y, clientInfo.X, clientInfo.Y) <= clientInfo.Range) {
			engine.send(sendBuffer, client, args.msgId, args.data);
		}
	}, { msgId: msgId, data: data, mgr: _clientsMgr, X: _x, Y: _y })	
}

function nwBroadcast(msgId, data) {
	show_debug_message("broadcast " + string (msgId) + ":" + json_stringify(data));
	
	ds_list_foreach(_clientsMgr.clients, function(client, index, args) {
		engine.send(sendBuffer, client, args.msgId, args.data);
	}, { msgId: msgId, data: data })	
}


function addNewClient(clientSocket) {
	//	"Global" Calls because of the transaction scope
	_clientsMgr.Add(clientSocket);
			
	if (!clientsWillUseCamera) {
		//	TODO	Ver si quitar
		_sendersMgr.SetAllDirty();
		_syncNow();
	}
}

function _addNewClient(clientSocket) {
	assert_is_not_undefined(clientSocket);
	global.nwNetworkManager.addNewClient(clientSocket);
}

#endregion	//	Internal functions

//	Private functions
#region Private functions

function _syncNow() {
	lastSync = 0;	
}

function _createEngineInstance() {
	engine = global.nwNetworkManagerFactory();
	sendBuffer = engine.createBuffer(2048, buffer_fixed, 1);
	
	assert_is_false(sendBuffer < 0, "Error creating a buffer.");
}

function _manageSocketServerEvent(asyncLoad) {
	var eventType = ds_map_find_value(asyncLoad, "type");
	var eventSocket = ds_map_find_value(asyncLoad, "socket");
	
	if(is_undefined(eventSocket)) {
		eventSocket = ds_map_find_value(asyncLoad, "id");	
	}

	switch(eventType) {
		case network_type_connect: {
			_addNewClient(eventSocket);
			self.evCallWithArgs(EV_SOCKET_CONNECT, { socket: eventSocket });
		}
		break
	
		case network_type_disconnect: {
			self.evCallWithArgs(EV_SOCKET_DISCONNECT, { socket: eventSocket });
			_nwDestroyAllInstancesOfClient(eventSocket);
			_clientsMgr.Remove(eventSocket);
		}
		break;
	
		case network_type_data:	{
			var buffer = ds_map_find_value(asyncLoad, "buffer");
			_onReceiveServerPacket(buffer, eventSocket);
		}
		break;
	}
}


function _manageSocketClientEvent(asyncLoad) {
	var eventType = ds_map_find_value(asyncLoad, "type");
	// var eventSocket = ds_map_find_value(asyncLoad, "socket");

	switch(eventType) {
		case network_type_data:	{
			var buffer = ds_map_find_value(asyncLoad, "buffer");
			var pck = engine.receive(buffer);
			_nwClientProcessPackage(pck);
		}
		break;
		case network_type_disconnect: {
			self.evCallWithArgs(EV_SOCKET_DISCONNECT, {});
			
			//	TODO	Remove this
			show_message("Servidor desconectado!");
			game_end();
		}
		break;
	}
}

function _nwClientProcessPackage(pck) {
	if (pck.id == NwMessageType.syncPackage) {
		var _socket = global.nwNetworkManager.serverSocket;
		self.evCallWithArgs("recv-" + pck.data.name, { socket: _socket, data: pck });
	}
	else if (pck.id == NwMessageType.syncObjectCreate) {
	}
	else if (pck.id == NwMessageType.rpcCall) {
	}
	else if (pck.id == NwMessageType.syncObjectDelete) {
		_receiversMgr.DestroyAndDelete(pck.data.uuid);
	}
	else if (pck.id == NwMessageType.syncObjectUpdate)  {
		if(!_sendersMgr.Exists(pck.data.uuid)) {
			_receiversMgr.ReceiveDataFromSender(pck.data, undefined);
		}
	}
	
	self.evCallWithArgs("client-receive", pck);
}

function _nwDestroyAllInstancesOfClient(socket) {
	ds_map_foreach(_receiversMgr.receivers, function(receiver, _uuid) {
		global.nwNetworkManager._receiversMgr.DestroyAndDelete(_uuid);
		global.nwNetworkManager.nwBroadcast(NwMessageType.syncObjectUpdate, { uuid: _uuid });	
	}, undefined);
}

function _onReceiveServerPacket(buffer, socket) {
	var pck = engine.receive(buffer);
	
	if (pck.id == NwMessageType.syncPackage) {
		self.evCallWithArgs("recv-" + pck.data.name, { socket: socket, data: pck });
	}
	else if (pck.id == NwMessageType.syncObjectCreate) {
	}
	else if (pck.id == NwMessageType.rpcCall) {
	}
	else if (pck.id == NwMessageType.syncClientLocation) {
		var data = _clientsMgr.GetInfo(socket);
		data.X = pck.data.X;
		data.Y = pck.data.Y;
	}
	else if (pck.id == NwMessageType.syncObjectDelete) {
		_receiversMgr.DestroyAndDelete(pck.data.uuid);
		nwBroadcast(pck.id, pck.data);	
	}
	else if (pck.id == NwMessageType.syncObjectUpdate)  {
		if(!_sendersMgr.Exists(pck.data.uuid)) {
			_receiversMgr.ReceiveDataFromSender(pck.data, socket);
			//	TODO	Validate data
			nwBroadcast(pck.id, pck.data);
		}
		else {
			//	TODO	Update senders
		}
	}
	
	self.evCallWithArgs(EV_SERVER_RECEIVE_PCK, pck);
}

#endregion	//	Private functions




