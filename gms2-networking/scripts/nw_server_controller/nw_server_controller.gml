function nw_ServerController() constructor {
	validators = {};
	
	static RegisterValidator = function(objectIndex, fn) {
		validators[$ objectIndex] = fn;
	};
	
	static UnregisterValidator = function(objectIndex) {
		if(variable_struct_exists(validators, objectIndex)) {
			variable_struct_remove(validators, objectIndex);
		}
	};
	
	static ClearValidators = function() {
		validators = {};	
	};
	
	static ValidateValue = function(objectIndex, syncVarName, newValue, oldValue) {
		if (variable_struct_exists(validators, objectIndex)) {
			var fn = validators[$ objectIndex];
			
			return fn(syncVarName, newValue, oldValue);
		}
		
		return true;
	};
	
	static Dispose = function() {
		validators = pointer_null;
	};
}
