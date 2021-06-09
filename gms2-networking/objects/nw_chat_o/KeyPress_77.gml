var text = get_string("Send new message", "");

if (text != "") {
	//	Show
	ds_list_add(chat, text);
	
	while(ds_list_size(chat) > 50) {
		ds_list_delete(chat, 0);	
	}
	
	generateChatText();
	
	//	Send
	if (nw_is_server()) {
		nw_broadcast("on-chat", { msg: text });
	}
	else {
		nw_send("chat", { msg: text });
	}
}