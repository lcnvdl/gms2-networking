/// @function assert_equals(value, expected, message*);
function assert_equals() {
	var current = argument0;
	var expected = argument1;
	var msg;
	
	if (argument_count == 3) {
		msg = argument2;	
	}
	else {
		msg = "Equals assertion failed.";
	}
	
	if (current != expected) {
		throw msg;	
	}
}

/// @function assert_is_string(value, message*);
function assert_is_string() {
	var current = argument0;
	var msg;
	
	if (argument_count == 2) {
		msg = argument1;	
	}
	else {
		msg = "Is string assertion failed.";
	}
	
	if (!is_string(current)) {
		throw msg;	
	}
}

/// @function assert_is_number(value, message*);
function assert_is_number() {
	var current = argument0;
	var msg;
	
	if (argument_count == 2) {
		msg = argument1;	
	}
	else {
		msg = "Is number assertion failed.";
	}
	
	if (!is_real(current)) {
		throw msg;	
	}
}

/// @function assert_is_array(value, message*);
function assert_is_array() {
	var current = argument0;
	var msg;
	
	if (argument_count == 2) {
		msg = argument1;	
	}
	else {
		msg = "Is number assertion failed.";
	}
	
	if (!is_array(current)) {
		throw msg;	
	}
}

/// @function assert_is_struct(value, message*);
function assert_is_struct() {
	var current = argument0;
	var msg;
	
	if (argument_count == 2) {
		msg = argument1;	
	}
	else {
		msg = "Is number assertion failed.";
	}
	
	if (!is_struct(current)) {
		throw msg;	
	}
}

