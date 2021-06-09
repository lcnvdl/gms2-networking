function nw_Receiver() constructor {
	uuid = "";
	dirty = false;
	object = undefined;
	instance = undefined;
	syncVariables = ds_list_create();
	settings = {};
	
	static GetClient = function() {
		return settings[$ "client"];	
	};
	
	static SetClient = function(socket) {
		settings[$ "client"] = socket;	
	};
	
	static GetSyncVar = function(varName) {
		var ix = ds_list_findIndex(syncVariables, function(_syncVar, __i, _varName) {
			return _syncVar.name == _varName;
		}, varName);
		
		if (ix == -1) {
			return undefined;	
		}
				
		var syncVar = ds_list_find_value(syncVariables, ix);	
		return syncVar;
	};
	
	static AddSyncVar = function(variable) {
		ds_list_add(syncVariables, variable);	
		return variable;
	};
	
	static Deserialize = function(info, instance) {
		uuid = info.uuid;
		instance = info.instance;
		object = info.object;
		dirty = true;
	};
	
	static Exists = function() {
		return instance_exists(instance);	
	};
	
	static DestroyInstance = function() {
		if (instance_exists(instance)) {
			instance_destroy(instance);	
		}	
	};
	
	static Dispose = function() {
		DestroyInstance();
		ds_list_destroy(syncVariables);	
	};
}
