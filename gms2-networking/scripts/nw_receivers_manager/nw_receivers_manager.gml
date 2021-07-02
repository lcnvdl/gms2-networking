function nw_ReceiversManager() constructor {
	receivers = ds_map_create();
	
	static Add = function(info) {
		ds_map_set(receivers, info.uuid, info);	
	};
	
	static Dispose = function() {
		if (!is_undefined(receivers)) {
			ds_map_foreach(receivers, function(receiver) {
				receiver.Dispose();
			}, undefined);
			ds_map_destroy(receivers);
			receivers = undefined;
		}
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
				//	TODO	Send value	
			}
		}, receiver);
	};
	
	static ReceiveDataFromSender = function(info, socketOwnerOfSender) {	
		var existing = Get(info.uuid);
		
		if (global.nwNetworkManager.serverMode) {
			assert_is_not_undefined(socketOwnerOfSender);
		}
		else {
			assert_is_undefined(socketOwnerOfSender);
		}
		
		if(is_undefined(existing)) {
			var objectIdx = asset_get_index(info.object);
			if (objectIdx < 0) {
				objectIdx = nw_empty_object;	
			}
			
			var existingBrother = instance_find(objectIdx, 0);
			var currentLayer = (existingBrother == noone) ? global.nwNetworkManager.layer : existingBrother.layer;
			
			var instance = undefined;
			
			if (existingBrother != noone && objectIdx != nw_empty_object) {
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
				instance = instance_create_layer(-100, -100, currentLayer, objectIdx);
			}
			
			CreateAndAttachReceiverToInstance(info, instance);
		}
		else {
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
		}
	};
	
	static CreateAndAttachReceiverToInstance = function(info, instance) {
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
				
			if (is_undefined(_value)) {
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