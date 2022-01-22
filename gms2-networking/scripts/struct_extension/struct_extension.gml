function struct_foreach(struct, fn, _args) {
    var names = variable_struct_get_names(struct)
    var size = variable_struct_names_count(struct);
    
    for (var i = 0; i < size; i++) {
        var name = names[i];
        var element = variable_struct_get(struct, name);
        fn(element, name, _args);
    }
}

function struct_secure_save(filename, struct) {
	var str = json_stringify(struct);
	file_write_all_text(filename, str);
}

function struct_secure_load(filename) {
	return json_parse(file_read_all_text(filename));	
}
