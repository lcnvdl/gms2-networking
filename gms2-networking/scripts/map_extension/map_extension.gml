function ds_map_foreach(map, fn, _args) {
	for (var k = ds_map_find_first(map); !is_undefined(k); k = ds_map_find_next(map, k)) {
	  var v = map[? k];
	  fn(v, k, _args);
	}
}

function auto_ds_map(_cb) {
	var ds = ds_map_create();
	try {
		_cb(ds);
	}
	finally {
		ds_map_destroy(ds);
	}
}