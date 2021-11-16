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