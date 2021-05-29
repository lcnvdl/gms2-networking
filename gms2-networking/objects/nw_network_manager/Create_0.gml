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

lastSync = 0;
nwCamera = noone
nwCamX = 0;
nwCamY = 0;

engine = undefined;

//	Events
evListener(id);

//	Global network
function _syncNow() {
	lastSync = 0;	
}

function _createEngineInstance() {
	engine = global.nwNetworkManagerFactory();
	sendBuffer = engine.createBuffer(2048, buffer_fixed, 1);	
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

function getSendersManager() {
	return _sendersMgr;	
}

function nwRegisterObjectAsSyncSender(instance, _uuid) {
	var newId = _sendersMgr.Register(instance, _uuid);
	_syncNow();
	
	return newId;
}

//	Server

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
	global.nwNetworkManager.addNewClient(clientSocket);
}

function nwManageSocketServerEvent(asyncLoad) {
	var eventType = ds_map_find_value(asyncLoad, "type");
	var eventSocket = ds_map_find_value(asyncLoad, "socket");

	switch(eventType) {
		case network_type_connect: {
			_addNewClient(eventSocket);
		}
		break
	
		case network_type_disconnect: {
			_nwDestroyAllInstancesOfClient(eventSocket);
			_clientsMgr.Remove(eventSocket);
		}
		break;
	
		case network_type_data:	{
			var buffer = ds_map_find_value(asyncLoad, "buffer");
			onReceiveServerPacket(buffer, eventSocket);
		}
		break;
	}
}

function nwSetCamera(obj) {
	nwCamera = obj;
}

function onReceiveServerPacket(buffer, socket) {
	var pck = engine.receive(buffer);
	
	if (pck.id == NwMessageType.syncObjectCreate) {
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
		if(!_sendersMgr.Exists(info.uuid)) {
			_receiversMgr.UpdateOrCreate(pck.data, socket);
		}
	}
	
	self.evCallWithArgs("server-receive", pck);
}

function _nwDestroyAllInstancesOfClient(socket) {
	ds_map_foreach(_receiversMgr.receivers, function(receiver, _uuid) {
		global.nwNetworkManager._receiversMgr.DestroyAndDelete(_uuid);
		global.nwNetworkManager.nwBroadcast(NwMessageType.syncObjectUpdate, { uuid: _uuid });	
	}, undefined);
}

//	Client

function nwManageSocketClientEvent(asyncLoad) {
	var eventType = ds_map_find_value(asyncLoad, "type");
	var eventSocket = ds_map_find_value(asyncLoad, "socket");

	switch(eventType) {
		case network_type_data:
		{
			var buffer = ds_map_find_value(asyncLoad, "buffer");
			onReceiveClientPacket(buffer, eventSocket);
		}
		break;
		case network_type_disconnect: {
			show_message("Servidor desconectado!");
			game_end();
		}
		break;
	}
}

function onReceiveClientPacket(buffer, socket) {
	var pck = engine.receive(buffer);
	
	_nwClientProcessPackage(pck);
}

function _nwClientProcessPackage(pck) {
	if (pck.id == NwMessageType.syncPackage) {
		
	}
	else if (pck.id == NwMessageType.syncObjectCreate) {
	}
	else if (pck.id == NwMessageType.syncObjectDelete) {
		_receiversMgr.DestroyAndDelete(pck.data.uuid);
	}
	else if (pck.id == NwMessageType.syncObjectUpdate)  {
		if(!_sendersMgr.Exists(pck.data.uuid)) {
			_receiversMgr.UpdateOrCreate(pck.data, undefined);
		}
	}
	
	self.evCallWithArgs("client-receive", pck);
}

