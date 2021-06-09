function cm_SyncVariable(_name, _type) constructor {
	if(!is_string(_name)) {
		throw "SyncVar name must be a string.";	
	}
	
	name = _name;
	type = _type;
	value = undefined;
	binding = SyncVarBinding.Regular;
	_dirty = false;
	settings = {};
	
	//	Two-way binding. If signal is false, the sender can send the value.
	static IsSignaled = function() {
		return variable_struct_exists(settings, "signal") &&
			settings[$ "signal"] == true;
	};
	
	static SetSignal = function(v) {
		settings[$ "signal"] = v;
	};
	
	static SetValue = function(v) {
		value = v;
		
		if (binding != SyncVarBinding.TwoWay || !IsSignaled()) {
			_dirty = true;
		}
	};
	
	//	TODO	Unused. It needs to be called.
	static SetSmooth = function(v) {
		settings[$ "smooth"] = v;
		return self;
	};
	
	static GetDelta = function() {
		if(!variable_struct_exists(settings, "delta")) {
			return 0;	
		}
		
		return settings[$ "delta"];
	};
	
	static SetDelta = function(v) {
		settings[$ "delta"] = v;
		return self;
	};
	
	static GetBinding = function() {
		return binding;
	};
	
	static SetBinding = function(_binding) {
		binding = _binding;
		return self;
	};
	
	static IsDirty = function() {
		return _dirty;	
	};

	static SetDirty = function() {
		_dirty = true;
		return self;
	};

	static ClearDirty = function() {
		_dirty = false;
		return self;
	};
	
	static IsNumeric = function() {
		return type == SV_INTEGER || type == SV_NUMBER;
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
			else if(type == SV_INTEGER) {
				return round(instanceValue) != round(value);	
			}
			else {
				return instanceValue != value;	
			}
		}
		
		return instanceValue != value;
	};
	
	static Serialize = function() {
		var result = {
			name: name,
			type: type,
			value: value,
			binding: binding
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
