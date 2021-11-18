function nw_receivers_manager_test() : GMLTest_Harness() constructor {
	manager = pointer_null;
	instance = pointer_null;
	
	function setup() {
		manager = new nw_ReceiversManager();
		global.nwNetworkManager = {
			serverMode: false,
			layer: -1
		};
		
		var info = new nw_Receiver();
		info.uuid = "uuid-rv1";
		info.AddSyncVarInt("x", 1);
		info.AddSyncVarInt("y", 1);
		manager.Add(info);
	}
	
	function tear_down() {
		if(!is_ptr(instance) && instance_exists(instance)) {
			instance_destroy(instance);
			instance = pointer_null;
		}
		manager.Dispose();
	}
}

test_f(nw_receivers_manager_test, "nw_receivers_manager Add should work fine", function() {
	var existing = manager.Get("uuid-rv1");

	gmltest_expect_eq("uuid-rv1", existing.uuid);
});

test_f(nw_receivers_manager_test, "nw_receivers_manager ReceiveDataFromSender should add a receiver if it doesn't exists", function() {
	var info = new nw_Receiver();
	info.uuid = "uuid-rv2";
	info.object = "zzz_none";
	info.layerName = "Instances";
	
	var receiver = manager.ReceiveDataFromSender(info, undefined);
	var result = receiver.instance;

	gmltest_expect_not_null(result);
	gmltest_expect_true(instance_exists(result));
	gmltest_expect_true(result.nwRecv);
	
	instance_destroy(result);
});

test_f(nw_receivers_manager_test, "nw_receivers_manager DestroyAndDelete should not fail if the receiver doesn't exists", function() {
	 manager.DestroyAndDelete("uuid-rvX");
	gmltest_expect_true(true);
});

test_f(nw_receivers_manager_test, "nw_receivers_manager ReceiveDataFromSender should create a new receiver if it doesn't exists", function() {
	var info = {
		uuid: "uuid-rvY",
		object: "xyz",
		layerName: "Instances",
		variables: {
			x: 10,
			y: 100
		},
		syncVariables: {
			x: { name: "x", type: SV_INTEGER, smooth: true },
			y: { name: "y", type: SV_INTEGER, smooth: true }
		}
	};
	
	var recv = manager.ReceiveDataFromSender(info, undefined);
	
	instance = recv.instance;
	
	gmltest_expect_true(instance_exists(instance));
	gmltest_expect_eq(info.uuid, instance.nwUuid);
	gmltest_expect_eq(nw_empty_object, instance.object_index);
	gmltest_expect_eq(10, instance.x);
	gmltest_expect_eq(100, instance.y);
});

test_f(nw_receivers_manager_test, "nw_receivers_manager ReceiveDataFromSender should update a receiver if it exists", function() {
	var info = {
		uuid: "uuid-rv1",
		variables: {
			x: 10,
			y: 100
		}
	};
	
	var receiver = manager.Get(info.uuid);
	instance = instance_create_layer(0, 0, "Instances", nw_empty_object);
	manager._AttachReceiverToInstance_OnlyForTesting(receiver, instance);
	
	var recv = manager.ReceiveDataFromSender(info, undefined);
	
	gmltest_expect_eq(info.uuid, instance.nwUuid);
	
	gmltest_expect_eq(0, instance.x);
	gmltest_expect_eq(0, instance.y);
	gmltest_expect_eq(10, recv.GetSyncVar("x").GetValue());
	gmltest_expect_eq(100, recv.GetSyncVar("y").GetValue());
});
