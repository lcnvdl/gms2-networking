function nw_rpc_instance_test() : GMLTest_Harness() constructor {
	rpcInstance = pointer_null;
	instanceMock = pointer_null;
	
	function setup() {
		instanceMock = {};
		rpcInstance = new nw_RpcInstance(instanceMock);
	}
	
	function tear_down() {
	}
}

test_f(nw_rpc_instance_test, "Register should work fine", function() {
	rpcInstance.Register("shotBullet", function(_args) {
	});
	
	gmltest_expect_true(variable_struct_exists(rpcInstance.rpcFunctions, "shotBullet"));
});

