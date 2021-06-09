function nw_Sender() constructor {
	uuid = "";
	dirty = false;
	object = undefined;
	instance = undefined;
	syncVariables = ds_list_create();
	
	static Initialize = function(_uuid, _instance) {
		uuid = _uuid;
		dirty = true;
		instance = _instance;
		object = object_get_name(_instance.object_index);
	};
	
	static Exists = function() {
		return instance_exists(instance);	
	};
	
	static Dispose = function() {
		ds_list_destroy(syncVariables);	
	};
	
	static GetAllDirtyValues = function(clear) {
		var allValues = {};
		
		ds_list_foreach(syncVariables, function(syncVariable, idx, _args) {
			if(syncVariable.IsDirty()) {
				_args.allValues[$ syncVariable.name] = syncVariable.value;
				
				if(_args.clear) {
					syncVariable.ClearDirty();
				}
			}
		}, { allValues: allValues, clear: clear });
		
		return allValues;
	};
	
	/*static GetAllValues = function() {
		var allValues = {};
		
		ds_list_foreach(syncVariables, function(syncVariable, idx, _struct) {
			_struct[$ syncVariable.name] = syncVariable.value;
		}, allValues);
		
		return allValues;
	};*/
	
	static AddSyncVar = function(variable) {
		ds_list_add(syncVariables, variable);	
		return variable;
	};
	
	static AddSyncVarInt = function(name, delta) {
		var syncVar = new cm_SyncVariable(name, SV_INTEGER);
		syncVar.SetDelta(delta);
		return AddSyncVar(syncVar);
	};
	
	static AddSyncVarText = function(name) {
		var syncVar = new cm_SyncVariable(name, SV_TEXT);
		return AddSyncVar(syncVar);
	};
	
	static AddSyncVarNumber = function(name, delta) {
		var syncVar = new cm_SyncVariable(name, SV_INTEGER);
		syncVar.SetDelta(delta);
		return AddSyncVar(syncVar);
	};
	
	static AddSyncVarBoolean = function(name) {
		var syncVar = new cm_SyncVariable(name, SV_BOOLEAN);
		return AddSyncVar(syncVar);
	};
	
	static GetSyncVar = function(varName) {
		var ix = ds_list_findIndex(syncVariables, function(val, __i, _name) {
			return val.name == _name;
		}, varName);
	
		if (ix == -1) {
			return pointer_null;	
		}
	
		return ds_list_find_value(syncVariables, ix);	
	};
	
	static SetDirty = function() {
		dirty = true;
		ds_list_foreach(syncVariables, function(syncVar) {
			syncVar.SetDirty();
		}, undefined);	
	};
	
	static UpdateSyncVariableFromSender = function(syncVar) {
		assert_is_true(
			(syncVar.binding == SyncVarBinding.Regular || syncVar.binding == SyncVarBinding.TwoWay || nw_is_server()), 
			"Wrong binding type");
		
		var this = self;
			
		if (syncVar.name == "x") {
			if(syncVar.IsDifferent(this.instance.x)) {
				syncVar.SetValue(round(this.instance.x));
				this.instance.x = syncVar.value;
				this.dirty = true;
			}
		}
		else if (syncVar.name == "y") {
			if(syncVar.IsDifferent(this.instance.y)) {
				syncVar.SetValue(round(this.instance.y));
				this.instance.y = syncVar.value;
				this.dirty = true;
			}
		}
		else if (syncVar.name == "image_angle") {
			if(syncVar.IsDifferent(this.instance.image_angle)) {
				syncVar.SetValue(round(this.instance.image_angle));
				this.instance.image_angle = syncVar.value;
				this.dirty = true;
			}
		}
		else if(variable_instance_exists(this.instance, syncVar.name)) {
			var currentValue = variable_instance_get(this.instance, syncVar.name);
			if(syncVar.IsDifferent(currentValue)) {
				if(syncVar.type == SV_INTEGER) {
					syncVar.SetValue(round(currentValue));	
					//	Save the rounded value
					variable_instance_set(this.instance, syncVar.name, syncVar.value);
				}
				else {
					syncVar.SetValue(currentValue);
				}
					
				this.dirty = true;
			}
		}
	};
	
	static UpdateTwoWaySyncVariableFromServer = function(syncVar) {		
		if (nw_is_server()) {
			return;
		}
		
		assert_is_true(syncVar.binding == SyncVarBinding.TwoWay, "Wrong binding type");
		
		var this = self;
		
		syncVar.SetSignal(true);
			
		if (syncVar.name == "x") {
			if(syncVar.IsDifferent(this.instance.x)) {
				syncVar.SetValue(round(this.instance.x));
				this.instance.x = syncVar.value;
			}
		}
		else if (syncVar.name == "y") {
			if(syncVar.IsDifferent(this.instance.y)) {
				syncVar.SetValue(round(this.instance.y));
				this.instance.y = syncVar.value;
			}
		}
		else if (syncVar.name == "image_angle") {
			if(syncVar.IsDifferent(this.instance.image_angle)) {
				syncVar.SetValue(round(this.instance.image_angle));
				this.instance.image_angle = syncVar.value;
			}
		}
		else if(variable_instance_exists(this.instance, syncVar.name)) {
			var currentValue = variable_instance_get(this.instance, syncVar.name);
			if(syncVar.IsDifferent(currentValue)) {
				if(syncVar.type == SV_INTEGER) {
					syncVar.SetValue(round(currentValue));	
					//	Save the rounded value
					variable_instance_set(this.instance, syncVar.name, syncVar.value);
				}
				else {
					syncVar.SetValue(currentValue);
				}
			}
		}
	};
	
	static EndStep = function(sender) {
		//	TODO	Ver si eliminar.
	};
	
	static staticToPackage = function(_self, variablesToSend) {
		var reducedSyncVariables = {};
	
		ds_list_foreach(_self.syncVariables, function(syncVar, idx, _reducedSyncVariables) {
			var data = syncVar.Serialize();
			var reducedSyncVar = { type: data.type };
		
			if(variable_struct_exists(data, "smooth")) {
				reducedSyncVar.smooth = data.smooth;
			}
			else {
				//	TODO	Esto no debería enviarse. Se debería interpretar "del otro lado".
				reducedSyncVar.smooth = true;	
			}
		
			_reducedSyncVariables[$ data.name] = reducedSyncVar;
		}, reducedSyncVariables);
		
		var packageToSend = { 
			uuid: _self.uuid, 
			object: _self.object,
			syncVariables: reducedSyncVariables,
			variables: variablesToSend
		};
	
		return packageToSend;
	};
}