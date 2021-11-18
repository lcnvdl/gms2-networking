function nw_sync_variable_test() : GMLTest_Harness() constructor {
	svInt = pointer_null;
	svText = pointer_null;
	svTextGlobal = pointer_null;
	
	function setup() {
		svInt = new cm_SyncVariable("mInt", SV_INTEGER);
		svText = new cm_SyncVariable("mText", SV_TEXT);
		svTextGlobal = new cm_SyncVariable("global.textGlobal", SV_TEXT);
	}
	
	function tear_down() {
	}
}

test_f(nw_sync_variable_test, "nw_sync_variable_test.IsNumeric should work fine", function() {
	gmltest_expect_true(svInt.IsNumeric());
	gmltest_expect_false(svText.IsNumeric());
});

test_f(nw_sync_variable_test, "nw_sync_variable_test.IsGlobal should work fine", function() {
	gmltest_expect_true(svTextGlobal.IsGlobal());
	gmltest_expect_false(svText.IsGlobal());
	gmltest_expect_false(svInt.IsGlobal());
});

test_f(nw_sync_variable_test, "nw_sync_variable_test.IsDifferent (int) should work fine", function() {
	svInt.SetValue(10);
	gmltest_expect_true(svInt.IsDifferent(11));
	gmltest_expect_false(svInt.IsDifferent(10));
	gmltest_expect_true(svInt.IsDifferent(10.9));
	gmltest_expect_false(svInt.IsDifferent(10.1));
});

test_f(nw_sync_variable_test, "nw_sync_variable_test.AddSerializer (text) should save the new value internally", function() {
	svText.AddSerializer({
		Serialize: function(text) {
			return "T-" + text;	
		},
		Deserialize: function(text) {
			return string_delete(text, 1, 2);
		}, 
	});
	
	svText.SetValue("hola");
	
	var realValue = svText.value;
	var result = svText.GetValue();

	gmltest_expect_eq("T-hola", realValue);
	gmltest_expect_eq("hola", result);
});