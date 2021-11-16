function nw_server_controller_test() : GMLTest_Harness() constructor {
	serverController = pointer_null;
	
	function setup() {
		serverController = new nw_ServerController();
	}
	
	function tear_down() {
		serverController.Dispose();
	}
}

test_f(nw_server_controller_test, "nw_ServerController ValidateValue should return true if it doesn't have validations", function() {
	var objIdx = 1;
	var result = serverController.ValidateValue(objIdx, "name", "Pepe", "Pepo");
	gmltest_expect_true(result);
});


test_f(nw_server_controller_test, "nw_ServerController UnregisterValidator should work fine", function() {
	var objIdx = 2;
	
	serverController.RegisterValidator(objIdx, function() { return false; });
	var result = serverController.ValidateValue(objIdx, "name", "Pepe", "Pepo");
	
	gmltest_expect_false(result);
	
	serverController.UnregisterValidator(objIdx);
	result = serverController.ValidateValue(objIdx, "name", "Pepe", "Pepo");
	
	gmltest_expect_true(result);
});

