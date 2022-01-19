function nw_clientInfo_test() : GMLTest_Harness() constructor {
	entity = pointer_null;
	
	function setup() {
		entity = new nw_ClientInfo();
	}
	
	function tear_down() {
		entity.Dispose();
	}
}

test_f(nw_clientInfo_test, "nw_ClientInfo AddWatchPoint should work fine", function() {
	entity.AddWatchPoint("Main", 5, 5, 10);
	gmltest_expect_true(entity.CanViewPoint(5, 5, true));
	gmltest_expect_true(entity.CanViewPoint(6, 6, true));
	gmltest_expect_true(entity.CanViewPoint(10, 10, true));
	gmltest_expect_false(entity.CanViewPoint(15, 15, true));
});

test_f(nw_clientInfo_test, "nw_ClientInfo CanViewPoint should return false if requireWatchpoints is true", function() {
	gmltest_expect_false(entity.CanViewPoint(5, 5, true));
});


test_f(nw_clientInfo_test, "nw_ClientInfo CanViewPoint should return true if requireWatchpoints is false", function() {
	gmltest_expect_true(entity.CanViewPoint(5, 5, false));
});

