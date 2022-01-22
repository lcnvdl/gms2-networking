function path_set_separator(sep) {
	global.__path_separator = sep;	
}

function path_get_separator() {
	if(!variable_global_exists("__path_separator")) {
		global.__path_separator = "\\";
	}
	
	return global.__path_separator;	
}

function path_join() {
	var finalPath = "";
	
	for(var i = 0; i < argument_count; i++) {
		if (finalPath != "" && string_char_at(finalPath, string_length(finalPath)) != path_get_separator()) {
			finalPath += path_get_separator();	
		}
		
		finalPath += argument[i];
	}
	
	return finalPath;
}