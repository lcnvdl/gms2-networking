function nw_networkManager_test() : GMLTest_Harness() constructor {
	entity = pointer_null;
	
	function setup() {
		global.nwNetworkManagerFactory = function() { return getMockNetworkEngine(); };
		entity = instance_create_depth(0, 0, 0, nw_network_manager);
	}
	
	function tear_down() {
		instance_destroy(entity);
	}
}

test_f(nw_networkManager_test, "nw_network_manager create instance should work", function() {
	gmltest_expect_eq(entity, global.nwNetworkManager);
});
