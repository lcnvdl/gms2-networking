function instance_create(x, y, obj) {
	return instance_create_layer(x, y, layer, obj);
}

function instance_get_width() {
	return bbox_right - bbox_left;
}

function instance_get_height() {
	return bbox_bottom - bbox_top;
}

function instance_get_all(objectIndex) {
	var list = ds_list_create();
	
	with (objectIndex)
	{
	    ds_list_add(list, id);
	}
	
	return list;
}
