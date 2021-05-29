function ds_list_toArray(list) {
	var arr = array_create(ds_list_size(list));
	
	ds_list_foreach(list, function(v, i) {
		arr[i] = v;
	}, undefined);
	
	return arr;
}

function ds_list_removeAll(list, fn, args) {
	var toRemove = ds_list_create();
	
	while(ds_list_findIndex(list, fn, args) >= 0) {
		var ix = ds_list_findIndex(list, fn, args);
		ds_list_delete(list, ix);
	}
	
	ds_list_destroy(toRemove);
}

function ds_list_findIndex(list, fn, args) {
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


