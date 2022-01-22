function DsListEnumerator(_dsList) : BaseEnumerator() constructor {
	_ds = _dsList;
	_position = -1;
	
    static MoveNext = function() {
        _position++;
        return (_position < ds_list_size(_ds));
    };

    static Reset = function() {
        _position = -1;
    };

	static GetCurrent = function() {
		return ds_list_find_value(_ds, _position);
	};
}