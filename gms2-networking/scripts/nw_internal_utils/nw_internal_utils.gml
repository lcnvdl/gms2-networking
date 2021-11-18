function _nw_smooth_update_entity(syncVar, _instance) {
	//	TODO	syncVar.value != x || No debería usar IsDifferent() ??
	
	var value = syncVar.GetValue();
	
	if(!is_undefined(value) && !is_ptr(value)) {
		var _dt = global.nwNetworkManager._dt;
		var _syncDelay = global.nwNetworkManager.syncDelay
		var factor = _dt*2;
		if (_syncDelay > 0) {
			factor /= _syncDelay;	
		}
				
		if (syncVar.name == "x") {
			if(value != _instance.x) {
				_instance.x = damp(_instance.x, value, max(1, abs(_instance.x-value)*factor));
			}
		}
		else if (syncVar.name == "y") {
			if(value != _instance.y){
				_instance.y = damp(_instance.y, value, max(1, abs(_instance.y-value)*factor));
			}
		}
		else if (syncVar.name == "image_angle") {
			if(value != _instance.image_angle) {
				_instance.image_angle = damp_angle(_instance.image_angle, value, 360*factor);
			}
		}
		else if(syncVar.ValueExists(_instance)) {
			var currentValue = syncVar.ReadValue(_instance);
			if(currentValue != value) {
				var newValue = value;
				
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
				
				syncVar.ApplyCustomValue(_instance, newValue);
			}
		}
	}
	else {
		// show_debug_message(syncVar.name + " not setted in receiver (because of the undefined)");	
	}
}