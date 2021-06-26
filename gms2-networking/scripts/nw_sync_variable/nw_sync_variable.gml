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
	
	_isGlobal = undefined;
	_realName = undefined;
	
	static _CalculateRealName = function() {
		_isGlobal = string_pos("global.", name) == 1 || string_pos("global__", name);
		_realName = _isGlobal ? string_replace(name, "global.", "") : name;
		_realName = _isGlobal ? string_replace(_realName, "global__", "") : name;
	};
	
	static GetName = function() {
		return _realName;
	};
	
	static IsGlobal = function() {
		return _isGlobal;	
	};
	
	static SetValue = function(v) {
		value = v;
		_dirty = true;
	};
	
	static ValueExists = function(_instance) {
		if(_isGlobal) {
			return variable_global_exists(_realName);
		}
		else {
			return variable_instance_exists(_instance, _realName);
		}
	};
	
	static ApplyCustomValue = function(_instance, _value) {
		if(_isGlobal) {
			variable_global_set(_realName, _value);
		}
		else {
			variable_instance_set(_instance, _realName, _value);	
		}
	};
	
	static ApplyValue = function(_instance) {
		if(_isGlobal) {
			variable_global_set(_realName, value);
		}
		else {
			variable_instance_set(_instance, _realName, value);	
		}
	};
	
	static ReadValue = function(_instance) {
		if (_isGlobal) {
			return variable_global_get(_realName);
		}
		else {
			return variable_instance_get(_instance, _realName);
		}
	};
	
	static SetValueFromServer = function(v) {
		assert_equals(binding, SyncVarBinding.TwoWay);
		
		value = v;
	};
	
	static SendToServer = function(v) {
		assert_equals(binding, SyncVarBinding.TwoWay);
		
		settings[$ "tw_dirty"] = true;
		return self;
	};
	
	static CanSendValue = function() {
		if (binding == SyncVarBinding.TwoWay) {
			if (!settings[$ "tw_dirty"]) {
				return false;	
			}
		}
		
		if (binding == SyncVarBinding.Server) {
			if (nw_is_client()) {
				return false;
			}
		}
		
		return _dirty;	
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
		
		if (binding == SyncVarBinding.TwoWay) {
			settings[$ "tw_dirty"] = false;
		}
		
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
		
		if (binding == SyncVarBinding.TwoWay) {
			settings[$ "tw_dirty"] = false;
		}
		
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
	
	static Deserialize = function(data) {
		struct_foreach(data, function(settingVal, settingKey, _obj) {
			_obj[$ settingKey] = settingVal;
		}, self);
		
		_CalculateRealName();
		
		return self;
	};
	
	static Serialize = function() {
		var result = {
			name: name,
			type: type,
			value: value
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
	
	_CalculateRealName();
}
