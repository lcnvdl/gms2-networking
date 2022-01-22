function ArrayList(_arr) constructor {
	_data = is_array(_arr) ? _arr : [];
	
	static Add = function(value) {
		array_push(_data, value);
	};
	
	static Push = function(value) {
		Add(value);
	};
	
	static Get = function(idx) {
		return _data[idx];
	};
	
	static Clear = function() {
		_data = [];	
	};
	
	static Length = function() {
		return array_length(_data);	
	};
	
	static Find = function(lambda) {
		return array_findIndex(_data, lambda, self);
	};
	
	static FindIndex = function(value) {
		return array_find_index(_data, value);
	};
	
	static Sort = function() {
		if (argument_count > 0) {
			array_sort(_data, argument0);
		}
		else {
			array_sort(_data, true);
		}
	};
	
	static Set = function(idx, value) {
		_data[idx] = value;
	};
	
	static Clone = function() {
		var newArray = [];
		array_copy(newArray, 0, _data, 0, array_length(_data));
		return new ArrayList(newArray);
	};
	
	static GetEnumerator = function() {
		return new ArrayListEnumerator(Clone());
	};
	
	static ToString = function() {
		return json_stringify(_data);	
	};
}