function _nw_smooth_update_entity(syncVar, _instance) {
	if(!is_undefined(syncVar.value)) {
		var _dt = global.nwNetworkManager._dt;
		var _syncDelay = global.nwNetworkManager.syncDelay
		var factor = _dt*2;
		if (_syncDelay > 0) {
			factor /= _syncDelay;	
		}
				
		if (syncVar.name == "x") {
			if(syncVar.value != _instance.x){
				_instance.x = damp(_instance.x, syncVar.value, max(1, abs(_instance.x-syncVar.value)*factor));
			}
		}
		else if (syncVar.name == "y") {
			if(syncVar.value != _instance.y){
				_instance.y = damp(_instance.y, syncVar.value, max(1, abs(_instance.y-syncVar.value)*factor));
			}
		}
		else if (syncVar.name == "image_angle") {
			if(syncVar.value != _instance.image_angle) {
				_instance.image_angle = damp_angle(_instance.image_angle, syncVar.value, 360*factor);
			}
		}
		else if(variable_instance_exists(_instance, syncVar.name)) {
			var currentValue = variable_instance_get(_instance, syncVar.name);
			if(currentValue != syncVar.value) {
				var newValue = syncVar.value;
				
				if(syncVar.type == SV_INTEGER ||
					syncVar.type == SV_DECIMAL) {
					if (variable_struct_exists(syncVar, "smooth")) {
						if (syncVar.smooth == SmoothType.Number) {
							newValue = damp(currentValue, newValue, max(1, abs(currentValue-newValue)*factor));
						}
						else if (syncVar.smooth == SmoothType.Angle) {
							newValue = damp_angle(currentValue, newValue, 360*factor);
						}
					}
				}
					
				variable_instance_set(_instance, syncVar.name, newValue);
			}
		}
	}
	else {
		show_debug_message(syncVar.name + " IS UNDEFINED!!");	
	}
}