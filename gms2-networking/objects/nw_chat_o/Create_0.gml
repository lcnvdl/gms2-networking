chat = ds_list_create();
chatText = "";

subscription = -1;

if(nw_is_server()) {
	subscription = nw_subscribe_receive("chat", function(__subscriptionArgs, _package) {
		var msg = _package.data.msg;
		ds_list_add(chat, msg);
		nw_broadcast("on-chat", { msg: msg });
		generateChatText();
	}, undefined);
}
else {
	subscription = nw_subscribe_receive("on-chat", function(__subscriptionArgs, _package) {
		var msg = _package.data.msg;
		ds_list_add(chat, msg);
		generateChatText();
	}, undefined);
}

function generateChatText() {
	chatText = "";
	
	for(var i = ds_list_size(chat) - 1; i >= 0; i--) {
		chatText += "\n" + ds_list_find_value(chat, i);
	}
}