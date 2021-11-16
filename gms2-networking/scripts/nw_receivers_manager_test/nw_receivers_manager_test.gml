function nw_receivers_manager_test() : GMLTest_Harness() constructor {
	manager = pointer_null;
	
	function setup() {
		manager = new nw_ReceiversManager();
		global.nwNetworkManager = {
			serverMode: false,
			layer: -1
		};
	}
	
	function tear_down() {
		manager.Dispose();
	}
}

test_f(nw_receivers_manager_test, "nw_receivers_manager Add should work fine", function() {
	var info = new nw_Receiver();
	info.uuid = "uuid-rv1";
	manager.Add(info);
	var existing = manager.Get("uuid-rv1");

	gmltest_expect_eq("uuid-rv1", existing.uuid);
});

test_f(nw_receivers_manager_test, "nw_receivers_manager ReceiveDataFromSender should add a receiver if it doesn't exists", function() {
	var info = new nw_Receiver();
	info.uuid = "uuid-rv2";
	info.object = "zzz_none";
	info.layerName = "Instances";
	
	var result = manager.ReceiveDataFromSender(info, undefined);

	gmltest_expect_not_null(result);
	gmltest_expect_true(instance_exists(result));
	gmltest_expect_true(result.nwRecv);
	
	instance_destroy(result);
});

