function nw_sender_test() : GMLTest_Harness() constructor {
	sender = pointer_null;
	instance = pointer_null;
	
	function setup() {
		instance = instance_create_depth(0,0,0, nw_empty_object);
		sender = new nw_Sender();
		sender.Initialize(getUuid(), instance);
		sender.AddSyncVarInt("x", 1);
		sender.AddSyncVarInt("y", 1);
	}
	
	function tear_down() {
		sender.Dispose();
		instance_destroy(instance);
	}
}

test_f(nw_sender_test, "nw_sender GetSyncVar should return null if doesn't exists", function() {
	var result = sender.GetSyncVar("var");
	gmltest_expect_true(is_ptr(result));
});

test_f(nw_sender_test, "nw_sender AddSyncVarStruct should add a serializer", function() {
	var result = sender.AddSyncVarStruct("inventory");
	var counter = result.CountSerializers();
	gmltest_expect_eq(1, counter);
});

test_f(nw_sender_test, "nw_sender GetSyncVar should work fine", function() {
	var result = sender.GetSyncVar("x");
	gmltest_expect_true(!is_ptr(result));
	gmltest_expect_eq("x", result.name);
	gmltest_expect_eq(SyncVarBinding.Regular, result.binding);
});

