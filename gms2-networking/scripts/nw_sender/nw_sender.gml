function cm_Sender() constructor {
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
	};
	
	static GetSyncVar = function(varName) {
		var ix = ds_list_findIndex(syncVariables, function(_name, val) {
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
	
	static EndStep = function(sender) {
	};
	
	static ToPackage = function(variablesToSend) {
		var reducedSyncVariables = {};
	
		ds_list_foreach(syncVariables, function(syncVar, idx, _reducedSyncVariables) {
			var data = syncVar.Serialize();
			var reducedSyncVar = { type: data.type };
		
			if(variable_struct_exists(data, "smooth")) {
				reducedSyncVar.smooth = data.smooth;
			}
			else {
				reducedSyncVar.smooth = true;	
			}
		
			_reducedSyncVariables[$ data.name] = reducedSyncVar;
		}, reducedSyncVariables);
	
		var packageToSend = { 
			uuid: uuid, 
			object: object,
			syncVariables: reducedSyncVariables,
			variables: variablesToSend
		};
	
		return packageToSend;
	};
}