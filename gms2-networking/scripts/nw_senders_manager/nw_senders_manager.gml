function nw_SendersManager() constructor {
	senders = ds_map_create();
	
	static Update = function() {
		ds_map_foreach(senders, function(sender, senderId) {	
			if (!sender.Exists()) {
				global.nwNetworkManager.emitSenderDelete(senderId);
				Delete(senderId);
			}
			else {
				_UpdateSenderInstance(sender);
			
				if(sender.dirty) {
					var dirtyValues = sender.GetAllDirtyValues(true);
					var packageToSend = sender.ToPackage(dirtyValues);
					
					global.nwNetworkManager.emitSenderUpdate(packageToSend, sender.instance.x, sender.instance.y);
			
					sender.dirty = false;
				}
			}
		}, undefined);
	};
	
	static _UpdateSenderInstance = function(sender) {
		ds_list_foreach(sender.syncVariables, function(syncVar, __i, _sender) {
			if (syncVar.name == "x") {
				if(syncVar.IsDifferent(_sender.instance.x)) {
					syncVar.SetValue(round(_sender.instance.x));
					_sender.instance.x = syncVar.value;
					_sender.dirty = true;
				}
			}
			else if (syncVar.name == "y") {
				if(syncVar.IsDifferent(_sender.instance.y)) {
					syncVar.SetValue(round(_sender.instance.x));
					_sender.instance.y = syncVar.value;
					_sender.dirty = true;
				}
			}
			else if (syncVar.name == "image_angle") {
				if(syncVar.IsDifferent(_sender.instance.image_angle)) {
					syncVar.SetValue(round(_sender.instance.image_angle));
					_sender.instance.image_angle = syncVar.value;
					_sender.dirty = true;
				}
			}
			else if(variable_instance_exists(_sender.instance, syncVar.name)) {
				var currentValue = variable_instance_get(_sender.instance, syncVar.name);
				if(syncVar.IsDifferent(currentValue)) {
					if(syncVar.type == SV_INTEGER) {
						syncVar.SetValue(round(currentValue));	
						//	Save the rounded value
						variable_instance_set(_sender.instance, syncVar.name, syncVar.value);
					}
					else {
						syncVar.SetValue(currentValue);
					}
					
					_sender.dirty = true;
				}
			}
		}, sender);
	};
	
	static Register = function(instance, _uuid) {
		var newUuid;
		
		if(is_undefined(_uuid)) {
			newUuid = getUuid();	
		}
		else {
			newUuid = _uuid;
		}
		
		instance.nwSender = true;
		instance.nwUuid = newUuid;
	
		var sender = new cm_Sender();
		sender.Initialize(newUuid, instance);
	
		sender.AddSyncVarInt("x", 1);
		sender.AddSyncVarInt("y", 1);
		sender.AddSyncVarInt("depth", 0);
		sender.AddSyncVarInt("image_angle", 5);
		sender.AddSyncVarInt("image_single", 0);
		sender.AddSyncVarInt("sprite_index", 0);
		sender.AddSyncVarNumber("image_xscale", 0.01);
		sender.AddSyncVarNumber("image_yscale", 0.01);
		sender.AddSyncVarNumber("image_alpha", 0.01);
		sender.AddSyncVarBoolean(sender, "visible");

		ds_map_set(senders, newUuid, sender);
		
		return newUuid;
	};
	
	static Exists = function(uuid) {
		var existingAsSender = _sendersMgr.Get(info.uuid);
		return !is_undefined(existingAsSender);
	};
	
	static Get = function(uuid) {
		return ds_map_find_value(senders, uuid);	
	};
	
	static GetFromInstance = function(instance) {
		return ds_map_find_value(senders, instance.nwUuid);	
	};
	
	static SetAllDirty = function() {
		ds_map_foreach(senders, function(sender){
			sender.SetDirty();
		}, undefined);
	};
	
	static Delete = function(uuid) {
		var sender = ds_map_find_value(senders, uuid);
		if(!is_undefined(sender)) {
			sender.Dispose();
			ds_map_delete(senders, uuid);
		}
	};
	
	static Dispose = function() {
		ds_map_foreach(senders, function(sender) {
			sender.Dispose();
		}, undefined);
		ds_map_destroy(senders);	
	};
}

