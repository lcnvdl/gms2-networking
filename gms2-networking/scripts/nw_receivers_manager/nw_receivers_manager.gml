function nw_ReceiversManager() constructor {
	receivers = ds_map_create();
	
	static Add = function(info) {
		ds_map_set(receivers, info.uuid, info);	
	};
	
	static Dispose = function() {
		ds_map_foreach(receivers, function(receiver) {
			ds_list_destroy(receiver.syncVariables);
		}, undefined);
		ds_map_destroy(receivers);
	};
	
	static Get = function(uuid) {
		var receiver = ds_map_find_value(receivers, uuid);
		return receiver;
	};
	
	static UpdateAll = function() {
		ds_map_foreach(receivers, function(receiver, receiverId) {
			if(instance_exists(receiver.instance)) {
				Update(receiver);
			}
			else {
				Delete(receiverId);
			}
		}, undefined);
	};
	
	static Update = function(receiver) {
		ds_list_foreach(receiver.syncVariables, function(v, i, _info) {
			if(!is_undefined(v.value)) {
				var _dt = global.nwNetworkManager._dt;
				var _syncDelay = global.nwNetworkManager.syncDelay
				var factor = _dt*2;
				if (_syncDelay > 0) {
					factor /= _syncDelay;	
				}
				
				if (v.name == "x") {
					if(v.value != _info.instance.x){
						_info.instance.x = damp(_info.instance.x, v.value, max(1, abs(_info.instance.x-v.value)*factor));
					}
				}
				else if (v.name == "y") {
					if(v.value != _info.instance.y){
						_info.instance.y = damp(_info.instance.y, v.value, max(1, abs(_info.instance.y-v.value)*factor));
					}
				}
				else if (v.name == "image_angle") {
					if(v.value != _info.instance.image_angle) {
						_info.instance.image_angle = damp_angle(_info.instance.image_angle, v.value, 360*factor);
					}
				}
				else if(variable_instance_exists(_info.instance, v.name)) {
					var currentValue = variable_instance_get(_info.instance, v.name);
					if(currentValue != v.value) {
						var newValue = v.value;
					
						if (v.smooth == SmoothType.Number) {
							newValue = damp(currentValue, newValue, max(1, abs(currentValue-newValue)*factor));
						}
						else if (v.smooth == SmoothType.Angle) {
							newValue = damp_angle(currentValue, newValue, 360*factor);
						}
					
						variable_instance_set(_info.instance, v.name, newValue);
					}
				}
			}
			else {
				show_debug_message(v.name+" IS UNDEFINED!!");	
			}
		}, receiver);
	};
	
	static UpdateOrCreate = function(info, socketOwnerOfSender) {	
		var existing = Get(info.uuid);
		
		if(is_undefined(existing)) {
			var objectIdx = asset_get_index(info.object);
			if (objectIdx <= 0) {
				objectIdx = nw_empty_object;	
			}
			
			var existingBrother = instance_find(objectIdx, 0);
			var currentLayer = (existingBrother == noone) ? global.nwNetworkManager.layer : existingBrother.layer;
			
			var instance = instance_create_layer(-100, -100, currentLayer, objectIdx);
	
			var recvInfo = {
				uuid: info.uuid, 
				instance: instance,
				object: info.object,
				dirty: true,
				syncVariables: ds_list_create()
			};
			
			if(global.nwNetworkManager.serverMode) {
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
				
				var ix = ds_list_findIndex(_syncVariables, function(_syncVar, _varName) {
					return _syncVar.name == _varName;
				}, varName);
				
				var syncVar = ds_list_find_value(_syncVariables, ix);
				syncVar.value = varVal;
				syncVar.dirty = true;
				
				show_debug_message(varName+"="+string(varVal));
				
				// variable_instance_set(_existing.instance, varName, varVal);
			}, { existing: existing } );
		}
	};
	
	static Delete = function(uuid) {
		var receiver = Get(receivers, uuid);
		if(!is_undefined(receiver)) {
			ds_list_destroy(receiver.syncVariables);
			ds_map_delete(receivers, uuid);
		}
	};
	
	static DestroyAndDelete = function(uuid) {
		var receiver = ds_map_find_value(receivers, uuid);
		if(!is_undefined(receiver)) {
			if (instance_exists(receiver.instance)) {
				instance_destroy(receiver.instance);	
			}
			
			Delete(uuid);
		}	
	};
}