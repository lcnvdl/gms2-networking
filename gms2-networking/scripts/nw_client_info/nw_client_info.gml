function nw_ClientInfo(_socket) constructor {
	watchPoints = ds_list_create();
	socket = _socket;
	
	static AddWatchPoint = function(_x, _y, _range) {
		ds_list_add(watchPoints, { X: _x, Y: _y, Range: _range });
		var index = ds_list_size(watchPoints) - 1;
		return index;
	};
	
	static CanViewPoint = function(_x, _y, _requireWatchPoints) {
		var sz = ds_list_size(watchPoints);
		if(sz == 0) {
			return !_requireWatchPoints;
		}
		
		for(var i = 0; i < sz; i++) {
			var wp = ds_list_find_value(watchPoints, i);
			
			if (point_distance(wp.X, wp.Y, _x, _y) <= wp.Range) {
				return true;
			}
		}
		
		return false;
	};
	
	static Dispose = function() {
		ds_list_destroy(watchPoints);
	};
}