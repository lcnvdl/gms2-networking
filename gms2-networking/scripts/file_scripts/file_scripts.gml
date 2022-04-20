function file_write_all_text(filename, content) {
	var stream = file_text_open_write(filename);
	file_text_write_string(stream, content);
	file_text_close(stream);
}

function file_append_all_text(filename, content) {
	var stream = file_text_open_append(filename);
	file_text_write_string(stream, content);
	file_text_close(stream);
}

function file_read_all_text(filename) {
	var stream = file_text_open_read(filename);
	var content = "";
	
	while(!file_text_eof(stream)) {
		content += file_text_read_string(stream);
		
		if(!file_text_eof(stream)) {
			file_text_readln(stream);
			content += "\n";
		}
	}
	
	file_text_close(stream);
	
	return content;
}

/// @function file_copy_dir(source, target, attributes)
/** 
* Copies contents from source directory to target directory.
* Add fa_directory to attributes for recursive copying.
* @param {*} list - List to convert.
* @return {[]} Array.
*/
function file_copy_dir(source, target, attributes) {
	var fname, i, file, files, from, to;

	if (!directory_exists(target)) {
		directory_create(target);
	}

	files = 0;
	for (fname = file_find_first(source + "/*.*", attributes); fname != ""; fname = file_find_next()) {
			if (fname == ".") continue;
			if (fname == "..") continue;
			
			file[files] = fname;
			files ++;
	}

	file_find_close();
	
	i = 0;
	repeat (files) {
			fname = file[i];
			i += 1;
			from = source + "/" + fname;
			to = target + "/" + fname;
			if (directory_exists(from)) {
					file_copy_dir(from, to, attributes);
			} else {
					file_copy(from, to);
			}
	}
}

function file_find_all(directory, filter) {
	if(directory_exists(directory)) {
		var files = ds_list_create();
		var file = file_find_first(directory + "\\" + filter, 0);
		
		while (file != "") {
			ds_list_add(files, file);
			file = file_find_next();
		}
	
		file_find_close();
	}

	return pointer_null;
}