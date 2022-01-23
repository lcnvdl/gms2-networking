function DsMapEnumerator(_map) : OrderedEnumerator() constructor {
	_ds = _map;
	_position = -1;
	_currentKey = undefined;
	
    static MoveNext = function() {
		if (++_position == 0) {
			_currentKey = ds_map_find_first(_ds);
		}
		else {
			_currentKey = ds_map_find_next(_ds, _currentKey);
		}
        return (_position < ds_map_size(_ds));
    };

    static Reset = function() {
        _position = -1
		_currentKey = undefined;
    };

	static GetCurrent = function() {
		if (_position == -1) {
			return undefined;	
		}
		
		return { key: _currentKey, value:ds_map_find_value(_ds, _currentKey) };
	};
}