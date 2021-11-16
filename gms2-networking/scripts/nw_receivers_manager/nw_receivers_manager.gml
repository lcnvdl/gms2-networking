function nw_ReceiversManager() constructor {
	receivers = ds_map_create();
	
	static Dispose = function() {
		if (!is_undefined(receivers)) {
			ds_map_foreach(receivers, function(receiver) {
				receiver.Dispose();
			}, undefined);
			ds_map_destroy(receivers);
			receivers = undefined;
		}
	};
	
	static Add = function(info) {
		ds_map_set(receivers, info.uuid, info);	
	};
	
	static Get = function(_uuid) {
		var receiver = ds_map_find_value(receivers, _uuid);
		return receiver;
	};
	
	static Update = function() {
		ds_map_foreach(receivers, function(receiver, receiverId) {
			if(instance_exists(receiver.instance)) {
				_UpdateReceiver(receiver);
			}
			else {
				DestroyAndDelete(receiverId);
			}
		}, undefined);
	};
	
	static _UpdateReceiver = function(receiver) {
		ds_list_foreach(receiver.syncVariables, function(syncVar, __i, _receiver) {
			if (syncVar.binding != SyncVarBinding.Server) {
				_nw_smooth_update_entity(syncVar, _receiver.instance);
			}
			else {
				//	TODO	Send value (for the other binding types)
			}
		}, receiver);
		
		//	Rpc
		if (variable_instance_exists(receiver, "nwRpc")) {
			receiver.nwRpc.Update(global.nwNetworkManager._dt);
		}
	};
	
	static ReceiveDataFromSender = function(info, socketOwnerOfSender) {	
		var existing = Get(info.uuid);
		
		if (global.nwNetworkManager.serverMode) {
			assert_is_not_undefined(socketOwnerOfSender, 
				"Server Mode: socketOwnerOfSender cannot be undefined");
		}
		else {
			assert_is_undefined(socketOwnerOfSender, 
				"Client Mode: socketOwnerOfSender must be undefined (is only for servers)");
		}
		
		if(is_undefined(existing)) {
			return _CreateNewReceiverFromReceivedMessage(info, socketOwnerOfSender);
		}
		else {
			return _UpdateExistingReceiverFromMessage(info, socketOwnerOfSender, existing);
		}
	};
	
	static _UpdateExistingReceiverFromMessage = function(info, socketOwnerOfSender, existing) {
		existing.dirty = true;
			
		//	TODO	Assign syncVariables
		struct_foreach(info.variables, function(varVal, varName, _existing) {
			var syncVar = _existing.GetSyncVar(varName);
				
			assert_is_not_undefined(syncVar, "The variable " + varName + " is missing.");
				
			//	Server validators
			if (nw_is_server() && instance_exists(_existing.instance)) {
				var svController = global.nwNetworkManager.getServerController();
				if (!svController.ValidateValue(_existing.instance.object_index, varName, varVal, syncVar.value)) {
					show_debug_message("New value for " + varName + " rejected by server validator.");
					return;
				}
			}
				
			//	New sync var value
			syncVar.SetValue(varVal);
				
			show_debug_message(varName + "=" + string(varVal));
		}, existing);
		
		return existing;
	};
	
	static _CreateNewReceiverFromReceivedMessage = function(info, socketOwnerOfSender) {
		var objectIdx = asset_get_index(info.object);
		if (objectIdx < 0) {
			objectIdx = nw_empty_object;	
		}
			
		var currentLayer = layer_get_id(info.layerName);
		if (currentLayer == -1) {
			currentLayer = global.nwNetworkManager.layer;	
		}
		
		if (currentLayer == -1) {
			var existingBrother = instance_find(objectIdx, 0);
			if (existingBrother != noone) {
				currentLayer = existingBrother.layer;
			}
		}
			
		var instance = undefined;
			
		if (currentLayer != -1 && objectIdx != nw_empty_object) {
			var withSameId = -1;
			var targetUuid = info.uuid;
				
			with(objectIdx) {
				if (variable_instance_exists(id, "nwUuid")) {
					if(nwUuid == targetUuid) {
						withSameId = id;	
					}
				}
			}
				
			instance = withSameId;
		}
			
		if(is_undefined(instance) || instance == -1) {
			assert_is_true(currentLayer > -1, "Couldn't find a layer");
			instance = instance_create_layer(-100, -100, currentLayer, objectIdx);
		}
			
		_CreateAndAttachReceiverToInstance(info, instance, socketOwnerOfSender);
		
		return instance;
	};
	
	static _CreateAndAttachReceiverToInstance = function(info, instance, socketOwnerOfSender) {
		if (variable_instance_exists(instance, "nwInfo")) {
			return false;	
		}
		
		var newReceiver = new nw_Receiver();
		newReceiver.Deserialize(info, instance);
			
		if(global.nwNetworkManager.serverMode) {
			newReceiver.SetClient(socketOwnerOfSender);
		}
			
		//	TODO	Validate values using ServerController
		struct_foreach(info.syncVariables, function(varVal, varName, _args) {
			var _recvInfo = _args.recvInfo;
			var _info = _args.info;
			var _instance = _args.instance;
			var _value = _info.variables[$ varName];
				
			var _syncVar = new cm_SyncVariable(varName, varVal.type);
				
			_recvInfo.AddSyncVar(_syncVar.Deserialize({ 
				smooth: varVal.smooth,
				value: _value
			}));
				
			if (is_undefined(_value) || is_ptr(_value)) {
				show_debug_message(varName + " ignored creating a new receiver - empty initial value");
			}
			else {
				show_debug_message(varName + " set to " + string(_value));
					
				_syncVar.ApplyCustomValue(_instance, _value);
			}
		}, { recvInfo: newReceiver, info: info, instance: instance });
			
		instance.nwRecv = true;
		instance.nwUuid = info.uuid;
		instance.nwInfo = newReceiver;
			
		if (variable_instance_exists(instance, "nwOnCreateReceiver")) {
			instance.nwOnCreateReceiver(newReceiver);	
		}
		
		ds_map_add(receivers, info.uuid, newReceiver);
		
		return true;
	};
	
	static DestroyAndDelete = function(_uuid) {
		var receiver = Get(_uuid);
		if(!is_undefined(receiver)) {
			receiver.Dispose();			
			ds_map_delete(receivers, _uuid);
		}	
	};
}