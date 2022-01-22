function ArrayListEnumerator(_arrayList) : BaseEnumerator() constructor {
	_ds = _arrayList;
	_position = -1;
	
    static MoveNext = function() {
        _position++;
        return (_position < _ds.Length());
    };

    static Reset = function() {
        _position = -1;
    };

	static GetCurrent = function() {
		return _ds.Get(_position);
	};
}