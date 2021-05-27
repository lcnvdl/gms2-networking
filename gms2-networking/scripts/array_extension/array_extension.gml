function array_foreach(arr, fn) {
	var i;
	for(i = 0; i < array_length(arr); i++) {
		var val = array_get(arr, i);
		fn(val, i);	
	}
}
