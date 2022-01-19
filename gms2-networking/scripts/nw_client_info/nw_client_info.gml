function nw_ClientInfo(_socket) constructor {
	watchPoints = ds_map_create();
	socket = _socket;
	
	static AddWatchPoint = function(_name, _x, _y, _range) {
		ds_map_add(watchPoints, _name, { X: _x, Y: _y, Range: _range });
	};
	
	static GetWatchPoint = function(name) {
		return ds_map_find_value(watchPoints, name);
	};
	
	/*static GetWatchPointAt = function(idx) {
		if (idx >= CountWatchPoints()) {
			return undefined;
		}
		
		return ds_list_find_value(watchPoints, idx);
	};*/
	
	static CountWatchPoints = function() {
		return ds_map_size(watchPoints);	
	};
	
	static CanViewPoint = function(_x, _y, _requireWatchPoints) {
		if (CountWatchPoints() == 0) {
			return !_requireWatchPoints;
		}
		
		for (var k = ds_map_find_first(watchPoints); !is_undefined(k); k = ds_map_find_next(watchPoints, k)) {
			var wp = watchPoints[? k];
			
			if (point_distance(wp.X, wp.Y, _x, _y) <= wp.Range) {
				return true;
			}
		}
		
		return false;
	};
	
	static Dispose = function() {
		ds_map_destroy(watchPoints);
	};
}