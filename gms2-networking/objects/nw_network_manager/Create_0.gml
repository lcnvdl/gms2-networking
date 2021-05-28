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
clients = ds_list_create();
clientsInfo = ds_map_create();
senders = ds_map_create();
receivers = ds_map_create();

lastSync = 0;
syncDelay = 0.5;
nwCamera = noone
nwCamX = 0;
nwCamY = 0;

clientsWillUseCamera = false;

selectedEngine = 0;

//engine = getNetworkEngine();
//sendBuffer = engine.createBuffer(2048, buffer_fixed, 1);

//	Events

evListener(id);

//	Global network
#region Network related functions
function _syncNow() {
	lastSync = 0;	
}

function _createEngineInstance() {
	engine = getNetworkEngine(selectedEngine);
	sendBuffer = engine.createBuffer(2048, buffer_fixed, 1);	
}

function _nwMakePackage(info, valuesToSend) {
	var syncVariables = {};
	
	ds_list_foreach(info.syncVariables, function(syncVar, idx, _variables) {
		var syncVarData = syncVar.Serialize();
		var finalValue = { type: syncVarData.type };
		
		if(variable_struct_exists(syncVarData, "smooth")) {
			finalValue.smooth = syncVarData.smooth;
		}
		else {
			finalValue.smooth = true;	
		}
		
		_variables[$ syncVarData.name] = finalValue;
	}, syncVariables);
	
	var packageToSend = { 
		uuid: info.uuid, 
		object: info.object,
		syncVariables: syncVariables,
		variables: valuesToSend
	};
	
	return packageToSend;
}
#endregion

#region Receivers
function _updateReceivers() {
	ds_map_foreach(receivers, function(receiver, receiverId) {
		if(instance_exists(receiver.instance)) {
			_nwReceiverEndStep(receiver.instance);
		}
		else {
			_nwDeleteReceiver(receiverId);
		}
	}, undefined);
}

function _nwDeleteReceiver(uuid) {
	var receiver = ds_map_find_value(receivers, uuid);
	if(!is_undefined(receiver)) {
		ds_list_destroy(receiver.syncVariables);
		ds_map_delete(receivers, uuid);
	}
}

function _nwReceiverEndStep(instance) {
	var info = ds_map_find_value(receivers, instance.nwUuid);
	
	ds_list_foreach(info.syncVariables, function(v, i, _info) {
		if(!is_undefined(v.value)) {
			if (v.name == "x") {
				if(v.value != _info.instance.x){
					_info.instance.x = damp(_info.instance.x, v.value, max(1, abs(_info.instance.x-v.value)*_dt*2/syncDelay));
				}
			}
			else if (v.name == "y") {
				if(v.value != _info.instance.y){
					_info.instance.y = damp(_info.instance.y, v.value, max(1, abs(_info.instance.y-v.value)*_dt*2/syncDelay));
				}
			}
			else if (v.name == "image_angle") {
				if(v.value != _info.instance.image_angle) {
					_info.instance.image_angle = damp_angle(_info.instance.image_angle, v.value, 360*_dt*2/syncDelay);
				}
			}
			else if(variable_instance_exists(_info.instance, v.name)) {
				var currentValue = variable_instance_get(_info.instance, v.name);
				if(currentValue != v.value) {
					var newValue = v.value;
					
					if (v.smooth == SmoothType.Number) {
						newValue = damp(currentValue, newValue, max(1, abs(currentValue-newValue)*_dt*2/syncDelay));
					}
					else if (v.smooth == SmoothType.Angle) {
						newValue = damp_angle(currentValue, newValue, 360*_dt*2/syncDelay);
					}
					
					variable_instance_set(_info.instance, v.name, newValue);
				}
			}
		}
		else {
			show_debug_message(v.name+" IS UNDEFINED!!");	
		}
	}, info);
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
	
	ds_map_set(receivers, uuid, info);
}

function _nwRemoveReceiver(uuid) {
	var info = ds_map_find_value(receivers, uuid);
	if(!is_undefined(info)) {
		if (instance_exists(info.instance)) {
			instance_destroy(info.instance);	
		}
			
		_nwDeleteReceiver(uuid);
	}
}

function _nwUpdateOrCreateReceiver(info, socketOwnerOfSender) {
	var existingAsSender = ds_map_find_value(senders, info.uuid);
	
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

#endregion

#region Senders
function _nwDeleteSender(uuid) {
	var sender = ds_map_find_value(senders, uuid);
	if(!is_undefined(sender)) {
		sender.Dispose();
		ds_map_delete(senders, uuid);
	}
}

function _updateSenders() {
	ds_map_foreach(senders, function(sender, senderId) {		
		if (!sender.Exists()) {
			if(serverMode) {
				nwBroadcast(NwMessageType.syncObjectDelete, { uuid: senderId });
			}
			else {
				//	TODO	Do it with some credentials
				engine.send(sendBuffer, serverSocket, NwMessageType.syncObjectDelete, { uuid: senderId });
			}
			_nwDeleteSender(senderId);
		}
		else {
			_nwSenderEndStep(sender.instance);
			
			if(sender.dirty) {
				var dirtyValues = sender.GetAllDirtyValues(true);
				
				var packageToSend = _nwMakePackage(sender, dirtyValues);
				
				if(serverMode) {
					//	TODO Ver de donde sacar X e Y
					nwBroadcastByDistance(
						NwMessageType.syncObjectUpdate, 
						packageToSend, 
						sender.instance.x,
						sender.instance.y);
					// nwBroadcast(NwMessageType.syncObjectUpdate, packageToSend);
				}
				else {
					//	TODO	Do it with some credentials
					engine.send(sendBuffer, serverSocket, NwMessageType.syncObjectUpdate, packageToSend);
				}
			
				sender.dirty = false;
			}
		}
	}, undefined);
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

function nwAllSendersSetDirty() {
	ds_map_foreach(senders, function(sender){
		sender.SetDirty();
	}, undefined);
}

function nwSenderSetDirty(uuid) {
	var info = ds_map_find_value(senders, uuid);
	info.SetDirty();
}

function nwRegisterObjectAsSyncSender(obj, uuid) {
	obj.nwSender = true;
	obj.nwUuid = uuid;
	
	var sender = new cm_Sender();
	sender.Initialize(uuid, obj);
	
	_addSyncVarInt(sender, "x", 1);
	_addSyncVarInt(sender, "y", 1);
	_addSyncVarInt(sender, "depth", 0);
	_addSyncVarInt(sender, "image_angle", 5);
	_addSyncVarInt(sender, "image_single", 0);
	_addSyncVarInt(sender, "sprite_index", 0);
	_addSyncVarNumber(sender, "image_xscale", 0.01);
	_addSyncVarNumber(sender, "image_yscale", 0.01);
	_addSyncVarNumber(sender, "image_alpha", 0.01);
	_addSyncVar(sender, "visible", "boolean");

	ds_map_set(senders, uuid, sender);
	
	_syncNow();
}

#endregion // Senders

#region Sync variables
function _addSyncVarInt(info, name, delta) {
	var syncVar = new cm_SyncVariable(name, "integer");
	syncVar.SetDelta(delta);
	info.AddSyncVar(syncVar);
}

function _addSyncVar(info, name, type) {
	var syncVar = new cm_SyncVariable(name, type);
	info.AddSyncVar(syncVar)
}

function nwAddSyncVarNumber(uuid, name, delta) {
	var info = ds_map_find_value(senders, uuid);
	_addSyncVarNumber(info, name, delta);
}

function _addSyncVarNumber(info, name, delta) {
	var syncVar = new cm_SyncVariable(name, "number");
	syncVar.SetDelta(delta);
	info.AddSyncVar(syncVar);
}

function nwGetSyncVar(uuid, name) {
	var sender = ds_map_find_value(senders, uuid);
	if (is_undefined(sender)) {
		return pointer_null;	
	}
	
	return sender.GetSyncVar(name);
}

function nwSetVarSmooth(uuid, name, enable) {
	var sVar = nwGetSyncVar(uuid, name);
	if(sVar != pointer_null) {
		sVar.SetSmooth(enable);
	}
}

#endregion

//	Server

function nwBroadcastByDistance(msgId, data, _x, _y) {
	show_debug_message("broadcast by distance " + string (msgId) + ":" + json_stringify(data));
	
	ds_list_foreach(clients, function(client, index, args) {
		var clientInfo = ds_map_find_value(args.clientsInfo, client);
		
		if (point_distance(args.X, args.Y, clientInfo.X, clientInfo.Y) <= clientInfo.Range) {
			engine.send(sendBuffer, client, args.msgId, args.data);
		}
	}, { msgId: msgId, data: data, clientsInfo: clientsInfo, X: _x, Y: _y })	
}

function nwBroadcast(msgId, data) {
	show_debug_message("broadcast " + string (msgId) + ":" + json_stringify(data));
	
	ds_list_foreach(clients, function(client, index, args) {
		engine.send(sendBuffer, client, args.msgId, args.data);
	}, { msgId: msgId, data: data })	
}

function _addNewClient(clientSocket) {
	//	"Global" Calls because of the transaction scope
	ds_list_add(network_manager_o.clients, clientSocket);
	ds_map_add(network_manager_o.clientsInfo, clientSocket, { X: -1, Y: -1, Range: 2000 });
			
	if (!network_manager_o.clientsWillUseCamera) {
		//	TODO	Ver si quitar
		nwAllSendersSetDirty();
		_syncNow();	
	}
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
			
			ds_list_delete(clients, ds_list_find_index(clients, eventSocket));
			ds_map_delete(clientsInfo, eventSocket);
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
		var data = ds_map_find_value(clientsInfo, socket);
		data.X = pck.data.X;
		data.Y = pck.data.Y;
	}
	else if (pck.id == NwMessageType.syncObjectDelete) {
		_nwRemoveReceiver(pck.data.uuid);
		nwBroadcast(pck.id, pck.data);	
	}
	else if (pck.id == NwMessageType.syncObjectUpdate)  {
		_nwUpdateOrCreateReceiver(pck.data, socket);
	}
	
	self.evCallWithArgs("server-receive", pck);
}

function _nwDestroyAllInstancesOfClient(socket) {
	ds_map_foreach(receivers, function(receiver, uuid) {
		network_manager_o._nwRemoveReceiver(uuid);
		network_manager_o.nwBroadcast(NwMessageType.syncObjectUpdate, { uuid: uuid });	
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

