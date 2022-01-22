function DictionaryEnumerator(_dictionary) : BaseEnumerator() constructor {
	_ds = _dictionary;
	_position = -1;
	
    static MoveNext = function() {
        _position++;
        return (_position < _ds.Count());
    };

    static Reset = function() {
        _position = -1;
    };

	static GetCurrent = function() {
		return _ds.GetAt(_position);
	};
}