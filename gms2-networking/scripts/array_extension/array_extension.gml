function array_foreach(arr, fn) {
	var i;
	for(i = 0; i < array_length(arr); i++) {
		var val = array_get(arr, i);
		fn(val, i);	
	}
}

function array_find_index(arr, value) {
	for(var i = 0; i < array_length(arr); i++) {
		if (array_get(arr, i) == value) {
			return i;	
		}
	}
	
	return -1;
}

function array_findIndex(arr, fn, args) {
	for(var i = 0; i < array_length(arr); i++) {
		var val = array_get(arr, i);
		var result = fn(val, i, args);
		if (result) {
			return i;	
		}
	}
	
	return -1;
}

///	@function array_to_list(array)
/** 
* Returns the array as a struct with all its values inside numeric keys
* @author D'Andrëw Box (GM-ARRAYS)
* @param {[]} array - Array to convert.
* @return {*} lIST.
*/
function array_to_list(_array) {
	var _new_ds_list = ds_list_create();
	for (var i = 0; i < array_length(_array); i++) {
		_new_ds_list[| i] = _array[i];
	}
	
	return _new_ds_list;
}

///	@function array_to_struct(array)
/** 
* Returns the array as a struct with all its values inside numeric keys
* @author D'Andrëw Box (GM-ARRAYS)
* @param {[]} array - Array to convert.
* @return {*} Struct.
*/
function array_to_struct(_array) {
	var _new_struct = {};
	for (var i = 0; i < array_length(_array); i++) {
		variable_struct_set(_new_struct, i, _array[i]);
	}
	
	return _new_struct;
}