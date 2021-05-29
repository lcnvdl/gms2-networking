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
syncDelay = 0.5;
nwCamera = noone
nwCamX = 0;
nwCamY = 0;

clientsWillUseCamera = false;

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


//	DEPRECCATED
function nwRegisterObjectAsSyncReceiver(obj, uuid) {
	obj.nwRecv = true;
	obj.nwUuid = uuid;
	obj.nwInfo = undefined;
	
	var info = { 
		uuid: uuid, 
		instance: obj,
		dirty: true,
		syncVariables: ds_list_create()
	};
	
	_receiversMgr.Add(info);
}

function _nwUpdateOrCreateReceiver(info, socketOwnerOfSender) {
	var existingAsSender = _sendersMgr.Get(info.uuid);
	
	if(is_undefined(existingAsSender)) {
		var existing = ds_map_find_value(receivers, info.uuid);
		
		if(is_undefined(existing)) {
			var objectIdx = asset_get_index(info.object);
			if (objectIdx < 0) {
				objectIdx = empty_object_o;	
			}
			
			var instance = instance_create(-100, -100, objectIdx);
	
			var recvInfo = {
				uuid: info.uuid, 
				instance: instance,
				object: info.object,
				dirty: true,
				syncVariables: ds_list_create()
			};
			
			if(serverMode) {
				recvInfo.client = socketOwnerOfSender;
			}
			
			struct_foreach(info.syncVariables, function(varVal, varName, _args) {
				var _recvInfo = _args.recvInfo;
				var _info = _args.info;
				var _instance = _args.instance;
				var _value = _info.variables[$ varName];
				
				ds_list_add(_recvInfo.syncVariables, { 
					name: varName,
					type: varVal.type,
					smooth: varVal.smooth,
					value: _value, 
					dirty: false });
				
				if (is_undefined(_value)) {
					show_debug_message(varName+" IGNORED (undefined)");
				}
				else {
					show_debug_message(varName+" set to "+string(_value));
					variable_instance_set(_instance, varName, _value);
				}
			}, {recvInfo:recvInfo, info:info, instance: instance});
			
			instance.nwRecv = true;			//	Remove?
			instance.nwUuid = info.uuid;	//	Remove?
			instance.nwInfo = recvInfo;		//	Remove?
			
			ds_map_add(receivers, info.uuid, recvInfo);
		}
		else {
			existing.dirty = true;
			
			//	TODO	Assign syncVariables
			struct_foreach(info.variables, function(varVal, varName, _args) {
				var _existing = _args.existing;
				var _syncVariables = _existing.syncVariables;
				
				var ix = ds_list_findIndex(_syncVariables, function(_varName, _syncVar) {
					return _syncVar.name == _varName;
				}, varName);
				
				var syncVar = ds_list_find_value(_syncVariables, ix);
				syncVar.value = varVal;
				syncVar.dirty = true;
				
				show_debug_message(varName+"="+string(varVal));
				
				// variable_instance_set(_existing.instance, varName, varVal);
			}, { existing: existing } );
		}
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

function _nwSenderEndStep(instance) {
	var info = ds_map_find_value(senders, instance.nwUuid);
	
	ds_list_foreach(info.syncVariables, function(v, i, _info) {
		if (v.name == "x") {
			if(v.IsDifferent(_info.instance.x)) {
				v.value = round(_info.instance.x);
				_info.instance.x = v.value;
				v._dirty = true;
				_info.dirty = true;
			}
		}
		else if (v.name == "y") {
			if(v.IsDifferent(_info.instance.y)) {
				v.value = round(_info.instance.y);
				_info.instance.y = v.value;
				v._dirty = true;
				_info.dirty = true;
			}
		}
		else if (v.name == "image_angle") {
			if(v.IsDifferent(_info.instance.image_angle)) {
				v.value = round(_info.instance.image_angle);
				_info.instance.image_angle = v.value;
				v._dirty = true;
				_info.dirty = true;
			}
		}
		else if(variable_instance_exists(_info.instance, v.name)) {
			var currentValue = variable_instance_get(_info.instance, v.name);
			if(v.IsDifferent(currentValue)) {
				if(v.type == "integer") {
					v.value = round(currentValue);	
					//	Save the rounded value
					variable_instance_set(_info.instance, v.name, v.value);
				}
				else {
					v.value = currentValue;
				}
				v._dirty = true;
				_info.dirty = true;
			}
		}
	}, info);
}

function nwSenderSetDirty(uuid) {
	var info = ds_map_find_value(senders, uuid);
	info.SetDirty();
}

function getSendersManager() {
	return _sendersMgr;	
}

function nwRegisterObjectAsSyncSender(instance, uuid) {
	_sendersMgr.Register(instance, uuid);
	_syncNow();
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
		nwAllSendersSetDirty();
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
		_receiversMgr.UpdateOrCreate(pck.data, socket);
	}
	
	self.evCallWithArgs("server-receive", pck);
}

function _nwDestroyAllInstancesOfClient(socket) {
	ds_map_foreach(_receiversMgr.receivers, function(receiver, uuid) {
		global.nwNetworkManager._receiversMgr.DestroyAndDelete(uuid);
		global.nwNetworkManager.nwBroadcast(NwMessageType.syncObjectUpdate, { uuid: uuid });	
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
		_nwRemoveReceiver(pck.data.uuid);
	}
	else if (pck.id == NwMessageType.syncObjectUpdate)  {
		_nwUpdateOrCreateReceiver(pck.data, undefined);
	}
	
	self.evCallWithArgs("client-receive", pck);
}

