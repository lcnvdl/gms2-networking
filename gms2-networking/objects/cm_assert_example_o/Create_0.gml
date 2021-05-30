//	Is-string assert
assert_is_string("hello");
show_debug_message("Is string assert | Happy case: success");	

try {
	assert_is_string(21);
}
catch(err) {
	show_debug_message("Is string assert | Unhappy case: success");
}

//	Equals assert
assert_equals(object_index, cm_assert_example_o);
show_debug_message("Equals assert | Happy case: success");	

try {
	assert_equals(object_index, noone);
}
catch(err) {
	show_debug_message("Equals assert | Unhappy case: success");
}
