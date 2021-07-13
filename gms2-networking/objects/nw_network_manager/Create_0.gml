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
_rpcMgr = new nw_RpcManager();
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

function nwSendBroadcastExclude(_name, _data, exclude) {
	assert_is_not_undefined(_data);
	assert_is_string(_name);
	assert_is_array(exclude);
	
	var _package = {
		name: _name,
		data: _data
	};
	
	nwBroadcastExclude(NwMessageType.syncPackage, _package, exclude);
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

function nwCustomSend(_socket, _type, _data) {
	assert_is_not_undefined(_socket);
	assert_is_not_undefined(_data);
	assert_is_not_undefined(_type);
	
	engine.send(sendBuffer, _socket, _type, _data);
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

function rpcInitialize(instanceIndex) {
	if (!variable_instance_exists(instanceIndex, "nwRpc")) {
		instanceIndex.nwRpc = new nw_RpcInstance(instanceIndex);
	}
}

function rpcRegisterFunction(instanceIndex, fnName, fnCallback) {
	_validateRpcArgs(instanceIndex, fnName);

	rpcInitialize(instanceIndex);
	
	instanceIndex.nwRpc.Register(fnName, fnCallback);
}

function rpcSelfCall(instanceIndex, fnName, fnArgs, fnCallback) {
	_validateRpcArgs(instanceIndex, fnName);
	
	var result = instanceIndex.nwRpc.CallFunction(fnName, fnArgs);
	var response = new nw_RPCResponse();
	response.SetData(result);
	
	var pck = response.Serialize();
	
	fnCallback(pck.data, pck.isValid, pck);
}

function rpcReceiverCall(instanceIndex, fnName, fnArgs, fnCallback) {
	_validateRpcArgs(instanceIndex, fnName);
	
	nw_assert_is_receiver(instanceIndex);
	
	var _uuid = nw_instance_get_uuid(instanceIndex);
	var _replyTo = getUuid();

	instanceIndex.nwRpc.AddWaiter(_replyTo, fnCallback);
	
	if (nw_is_server()) {
		var receiver = nw_instance_get_receiver(instanceIndex);
		var receiverSocket = receiver.GetClient();
		
		nwCustomSend(receiverSocket, NwMessageType.rpcReceiverFunctionCall, { id: _uuid, fn: fnName, args: fnArgs, replyTo: _replyTo });
	}
	else {
		nwCustomSend(nw_get_socket(), NwMessageType.rpcReceiverFunctionCall, { id: _uuid, fn: fnName, args: fnArgs, replyTo: _replyTo });
	}
}

function rpcSenderCall(instanceIndex, fnName, fnArgs, fnCallback) {
	_validateRpcArgs(instanceIndex, fnName);
	
	nw_assert_is_sender(instanceIndex);
	assert_is_true(nw_is_client(), "The RPC from senders can only be called in Client-Side.");
	
	var _uuid = nw_instance_get_uuid(instanceIndex);
	var _replyTo = getUuid();

	instanceIndex.nwRpc.AddWaiter(_replyTo, fnCallback);
	
	nwCustomSend(nw_get_socket(), NwMessageType.rpcSenderFunctionCall, { id: _uuid, fn: fnName, args: fnArgs, replyTo: _replyTo });
}

function _validateRpcArgs(instanceIndex, fnName) {
	assert_is_not_undefined(instanceIndex, "The instance index must be defined");
	assert_is_string(fnName, "The function name must be a string");
}

function rpcSenderBroadcast(instanceIndex, fnName, fnArgs, fnCallback) {
	_validateRpcArgs(instanceIndex, fnName);
	
	var _uuid = nw_instance_get_uuid(instanceIndex);
	assert_is_not_undefined(_uuid);
	
	if (nw_is_server()) {
		nwBroadcast(NwMessageType.rpcSenderBroadcastCall, { id: _uuid, fn: fnName, args: fnArgs });
	}
	else {
		nwCustomSend(nw_get_socket(), NwMessageType.rpcSenderBroadcastReplicate, { id: _uuid, fn: fnName, args: fnArgs });
	}
	
	if(!is_undefined(fnCallback)) {
		fnCallback();
	}
}

function cleanUpNetworkManager() {
	//	Sockets
	if (!is_undefined(engine)) {
		engine.destroyBuffer(sendBuffer);
		engine.destroySocket(serverSocket);
	}

	//	Server controller
	if (!is_undefined(_serverController)) {
		_serverController.Dispose();
		_serverController = undefined;
	}

	//	Senders and receivers
	_sendersMgr.Dispose();
	_receiversMgr.Dispose();

	//	Clients (connections)
	_clientsMgr.Dispose();

	//	Events
	cleanUpSubscriptions();

	//	Finish
	offline = true;
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

function nwBroadcastExclude(msgId, data, socketsToExclude) {
	show_debug_message("broadcast (xclude) " + string (msgId) + ":" + json_stringify(data));
	
	ds_list_foreach(_clientsMgr.clients, function(client, index, args) {
		var idx = array_findIndex(args.xclude, function(v, i, _client) {
			return v == _client;
		}, client);
		
		if (idx == -1) {
			engine.send(sendBuffer, client, args.msgId, args.data);
		}
	}, { msgId: msgId, data: data, xclude: socketsToExclude })	
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

	switch(eventType) {
		case network_type_data:	{
			var buffer = ds_map_find_value(asyncLoad, "buffer");
			var pck = engine.receive(buffer);
			_nwClientProcessPackage(pck);
		}
		break;
		case network_type_disconnect: {
			self.evCallWithArgs(EV_SOCKET_DISCONNECT, {});
		}
		break;
	}
}

function _nwDestroyAllInstancesOfClient(socket) {
	ds_map_foreach(_receiversMgr.receivers, function(receiver, _uuid) {
		global.nwNetworkManager._receiversMgr.DestroyAndDelete(_uuid);
		global.nwNetworkManager.nwBroadcast(NwMessageType.syncObjectUpdate, { uuid: _uuid });	
	}, undefined);
}

function _nwClientProcessPackage(pck) {
	if (pck.id == NwMessageType.syncPackage) {
		var _socket = global.nwNetworkManager.serverSocket;
		var _eventPackage = pck.data;
		self.evCallWithArgs("recv-" + _eventPackage.name, { socket: _socket, data: _eventPackage.data });
	}
	else if (pck.id == NwMessageType.syncObjectCreate) {
	}
	else if (pck.id == NwMessageType.rpcReceiverFunctionCallFindSender) {
		_rpcMgr.FindSenderAndReply(pck.data);
	}
	else if (pck.id == NwMessageType.rpcSenderBroadcastCall) {
		_rpcMgr.BroadcastCall(pck.data);
	}
	else if (pck.id == NwMessageType.rpcSenderFunctionReply) {
		_rpcMgr.ReceiveReply(pck.data);
	}
	else if (pck.id == NwMessageType.rpcReceiverFunctionReply) {
		_rpcMgr.ReceiveReply(pck.data);
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

function _onReceiveServerPacket(buffer, socket) {
	var pck = engine.receive(buffer);
	
	if (pck.id == NwMessageType.syncPackage) {
		var _eventPackage = pck.data;
		self.evCallWithArgs("recv-" + _eventPackage.name, { socket: socket, data: _eventPackage.data });
	}
	else if (pck.id == NwMessageType.syncObjectCreate) {
	}
	else if (pck.id == NwMessageType.rpcSenderBroadcastCall) {
		_rpcMgr.BroadcastCall(pck.data);
	}
	else if (pck.id == NwMessageType.rpcSenderBroadcastReplicate) {
		_rpcMgr.BroadcastCall(pck.data);
		_rpcMgr.BroadcastReplicate(pck.data, socket);
	}
	else if (pck.id == NwMessageType.rpcReceiverFunctionCall) {
		//	Receiver (client or server) calls to Sender (server or client)
		_rpcMgr.ReceiverCallToSender(pck.data, socket);
	}
	else if (pck.id == NwMessageType.rpcReceiverFunctionReply) {
		_rpcMgr.ReceiveReply(pck.data);
	}
	else if (pck.id == NwMessageType.rpcSenderFunctionCall) {
		//	Sender (client) calls to receiver (server)
		_rpcMgr.SenderCallToReceiver(pck.data, socket);
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




