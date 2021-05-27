function struct_foreach(struct, fn, _args) {
    var names = variable_struct_get_names(struct)
    var size = variable_struct_names_count(struct);
    
    for (var i = 0; i < size; i++) {
        var name = names[i];
        var element = variable_struct_get(struct, name);
        fn(element, name, _args);
    }
}

