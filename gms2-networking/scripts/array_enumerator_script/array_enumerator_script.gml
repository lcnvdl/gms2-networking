function ArrayEnumerator(_array) : BaseEnumerator() constructor {
	_ds = _array;
	_position = -1;
	
    static MoveNext = function() {
        _position++;
        return (_position < array_length(_ds));
    };

    static Reset = function() {
        _position = -1;
    };

	static GetCurrent = function() {
		return _ds[_position];
	};
}