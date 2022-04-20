function string_split(separator, text){
	var slot = 0;
	var splits; //array to hold all splits
	var str2 = ""; //var to hold the current split we're working on building

	var i;
	for (i = 1; i < (string_length(text)+1); i++) {
	    var currStr = string_copy(text, i, 1);
	    if (currStr == separator) {
	        splits[slot] = str2; //add this split to the array of all splits
	        slot++;
	        str2 = "";
	    } else {
	        str2 = str2 + currStr;
	        splits[slot] = str2;
	    }
	}
	
	return splits;
}

function string_join_args() {
	var finalText = "";
	var chain = argument[0];

	for (var i = 1; i < argument_count; i += 1) {
		if(i > 1) {
			finalText += chain;	
		}
		
	   if (is_string(argument[i])) {
	       finalText += argument[i];
	   } else {
	       finalText += string(argument[i]);
	   }
	}
	
	return finalText;
}

function string_join(chain, stringArray){
	var finalText = "";

	for(var i = 0; i < array_length(stringArray); i++) {
		if(i > 0) {
			finalText += chain;	
		}
		
		finalText += stringArray[i];
	}
	
	return finalText;
}

/// @function string_trim(text, side, char)
/** 
* Removes leading and trailing matches of a string.
* @param {string} text - Text to trim.
* @param {string} [side='both'] - "left", "right" or "both". Uses "both" when empty.
* @param {string} [char=' '] - Character to remove. Uses the " " character (space) when empty.
* @return {string} Trimmed text.
*/
function string_trim() {
	var str = string(argument[0]);
	var side = "both";
	var char = " ";
	
	if argument_count >= 2 { 
		if (argument[1] == "left" || argument[1] == "right" || argument[1] == "both")
		side = argument[1];
	}
	
	if argument_count == 3 { 
		char = string(argument[2]);
	}
	
	var newString = str;
	if (side == "left" || side == "both") {
		var _start = 0;
		for(var i = 1; i <= string_length(newString); i++) {
			if (string_char_at(newString, i) != char) {
				_start = i - 1;
				break;
			}
		}
		if (_start != 0) {
			newString = string_delete(newString, 1, _start);
		}
	}
	
	if (side == "right" || side == "both") {
		var _end = 0
		for(var i = string_length(newString); i > 0; i--) {
			if (string_char_at(newString, i) != char) {
				_end = i + 1;
				break;
			}
		}
		
		if (_end != 0) {
			newString = string_delete(newString, _end, string_length(newString));
		}
	}

	return newString;
}

function string_ends_with_char(str, endChar) {
	return string_char_at(str, string_length(str)) == endChar;
}

function string_starts_with(str, text) {
	return string_pos(text, str) == 1;
}

function string_ends_with(str, text) {
	var expectedIndex = 1 + string_length(str) - string_length(text);
	return string_pos(text, str) == expectedIndex;
}