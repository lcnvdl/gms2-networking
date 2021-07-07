function array_foreach(arr, fn) {
	for(var i = 0; i < array_length(arr); i++) {
		var val = array_get(arr, i);
		fn(val, i);	
	}
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