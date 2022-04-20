/// @function ds_list_toArray(list)
/** 
* Converts a ds_list into an array.
* @param {*} list - List to convert.
* @return {[]} Array.
*/
function ds_list_toArray(list) {
	var arr = array_create(ds_list_size(list));
	
	ds_list_foreach(list, function(v, i) {
		arr[i] = v;
	}, undefined);
	
	return arr;
}

function ds_list_removeAll(list, fn, args) {
	while(ds_list_findIndexOf(list, fn, args) >= 0) {
		var ix = ds_list_findIndexOf(list, fn, args);
		ds_list_delete(list, ix);
	}
}

function ds_list_findIndexOfValue(list, fn, args) {
	var i;
	for(i = 0; i < ds_list_size(list); i++) {
		var result = fn(ds_list_find_value(list, i), i, args);
		if (!is_undefined(result) && result != pointer_null) {
			return i;	
		}
	}
	
	return -1;
}

function ds_list_findIndexOf(list, fn, args) {
	var i;
	for(i = 0; i < ds_list_size(list); i++) {
		var result = fn(ds_list_find_value(list, i), i, args);
		if (result) {
			return i;	
		}
	}
	
	return -1;
}

function ds_list_findIndex(list, fn, args) {
	show_debug_message("DEPRECATED: Use findIndexOfValue or findIndexIf");
	var i;
	for(i = 0; i < ds_list_size(list); i++) {
		var result = fn(ds_list_find_value(list, i), i, args);
		if (!is_undefined(result) && result != pointer_null) {
			return i;	
		}
	}
	
	return -1;
}

function ds_list_firstOrDefault(list, fn, args) {
	var i;
	for(i = 0; i < ds_list_size(list); i++) {
		var result = fn(ds_list_find_value(list, i), i, args);
		if  (!is_undefined(result)) {
			return result;	
		}
	}
	
	return undefined;
}

function ds_list_foreach(list, fn, args) {
	for(var i = 0; i < ds_list_size(list); i++) {
		var v = ds_list_find_value(list, i);
		fn(v, i, args);	
	}
}

function auto_ds_list(_cb) {
	var list = ds_list_create();
	try {
		_cb(list);
	}
	finally {
		ds_list_destroy(list);
	}
}

