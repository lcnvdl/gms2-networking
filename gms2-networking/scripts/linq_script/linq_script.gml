//	Functions

function GetStructureOf(x) {
	var result = x;
	
	if(is_array(x)) {
		result = new ArrayList(x);	
	}
	else if(is_struct(x)) {
		result = new Dictionary(x);
	}
	else if(ds_exists(x, ds_type_list)) {
		result = new ArrayList(ds_list_toArray(x));
		
		if (argument_count == 1 || argument[1]) {
			ds_list_destroy(x);
		}
	}
	else if(ds_exists(x, ds_type_map)) {
		result = new Dictionary(ds_map_to_struct(x));
		
		if (argument_count == 1 || argument[1]) {
			ds_map_destroy(x);
		}
	}
	
	return result;
}

function GetEnumeratorOf(x){
	if (!is_struct(x)) {
		if(is_array(x)) {
			return new ArrayEnumerator(x);
		}
		else if(ds_exists(x, ds_type_list)) {
			return new DsListEnumerator(x);
		}
		else if(ds_exists(x, ds_type_queue)) {
			return new DsQueueEnumerator(x);
		}
		else if(ds_exists(x, ds_type_map)) {
			return new DsMapEnumerator(x);
		}
	}
	
	return x.GetEnumerator();
}

//	Alias

function GetDS(x) {
	return GetStructureOf(x);	
}

function GetLinq(_x) {
	return GetEnumeratorOf(GetStructureOf(_x));
}