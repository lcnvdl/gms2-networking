function cm_SyncVariable(_name, _type) constructor {
	name = _name;
	type = _type;
	value = undefined;
	_dirty = false;
	settings = {};
	
	static SetValue = function(v) {
		value = v;
		_dirty = true;
	};
	
	static SetSmooth = function(v) {
		settings[$ "smooth"] = v;	
	};
	
	static GetDelta = function() {
		if(!variable_struct_exists(settings, "delta")) {
			return 0;	
		}
		
		return settings[$ "delta"];
	};
	
	static SetDelta = function(v) {
		settings[$ "delta"] = v;	
	};
	
	static IsDirty = function() {
		return _dirty;	
	};

	static SetDirty = function() {
		_dirty = true;
	};

	static ClearDirty = function() {
		_dirty = false;
	};
	
	static IsNumeric = function() {
		return type == "integer" || type == "number";
	};
	
	static IsDifferent = function(instanceValue) {
		if (is_undefined(value)) {
			return true;	
		}
		
		if (IsNumeric()) {
			var delta = GetDelta();
			if (delta > 0) {
				return abs(instanceValue - value) >= delta;
			}
			else if(type == "integer") {
				return round(instanceValue) != round(value);	
			}
			else {
				return instanceValue != value;	
			}
		}
		
		return instanceValue != value;
	};
	
	static Deserialize = function(data) {
		
	};
	
	static Serialize = function() {
		var result = {
			name: name,
			type: type,
			value: value,
			_dirty: _dirty // Necesario??
		};
		
		struct_foreach(settings, function(settingVal, settingKey, _result) {
			_result[$ settingKey] = settingVal;
		}, result);
		
		return result;
	};
	
	static ToString = function() {
		var json =  json_stringify(Serialize());
		json = string_replace_all(json, ",", ",\n");
		return json;	
	};
}
