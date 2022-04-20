function nw_Receiver() constructor {
	uuid = "";
	dirty = false;
	object = undefined;
	instance = undefined;
	layerName = undefined;
	syncVariables = ds_list_create();
	settings = {};
	
	static GetClient = function() {
		return settings[$ "client"];	
	};
	
	static SetClient = function(socket) {
		settings[$ "client"] = socket;	
	};
	
	static GetSyncVar = function(varName) {
		var ix = ds_list_findIndexOf(syncVariables, function(_syncVar, __i, _varName) {
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
	
	static AddSyncVarInt = function(name, delta) {
		var syncVar = new cm_SyncVariable(name, SV_INTEGER);
		syncVar.SetDelta(delta);
		return AddSyncVar(syncVar);
	};
	
	static AddSyncVarText = function(name) {
		var syncVar = new cm_SyncVariable(name, SV_TEXT);
		return AddSyncVar(syncVar);
	};
	
	static AddSyncVarStruct = function(name) {
		var syncVar = new cm_SyncVariable(name, SV_STRUCT);
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
	
	static Deserialize = function(info, _instance) {
		uuid = info.uuid;
		instance = _instance;
		object = info.object;
		layerName = info.layerName;
		dirty = true;
	};
	
	static Exists = function() {
		return !is_undefined(instance) && instance_exists(instance);	
	};
	
	static DestroyInstance = function() {
		if (Exists(instance)) {
			instance_destroy(instance);	
		}	
	};
	
	static Dispose = function() {
		DestroyInstance();
		ds_list_destroy(syncVariables);	
	};
}
