function nw_clientsManagerTest_test() : GMLTest_Harness() constructor {
	entity = pointer_null;
	
	function setup() {
		entity = new nw_ClientsManager({ requireWatchPoints: false });
	}
	
	function tear_down() {
		entity.Dispose();
	}
}

test_f(nw_clientsManagerTest_test, "nw_ClientsManager Add should work fine", function() {
	var socket = 10;
	entity.Add(socket);
	var info = entity.GetInfo(socket);
	gmltest_expect_true(info.socket == socket);
});
