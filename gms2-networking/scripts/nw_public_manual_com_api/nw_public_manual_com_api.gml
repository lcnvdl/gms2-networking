/**
* @file Manual-Communication API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_send(_name, _data) {
	nw_send_to(nw_get_socket(), _name, _data);
}

function nw_send_to(_socket, _name, _data) {
	assert_is_not_undefined(_socket);
	assert_is_string(_name);
	global.nwNetworkManager.nwSend(_socket, _name, _data);
}

function nw_broadcast(_name, _data) {
	assert_is_string(_name);
	assert_is_true(nw_is_server());
	global.nwNetworkManager.nwSendBroadcast(_name, _data);
}

function nw_subscribe_receive(_name, _fn, _args) {
	assert_is_string(_name);
	var sid = global.nwNetworkManager.evSubscribe("recv-"+_name, _fn, _args);
	return sid;
}
