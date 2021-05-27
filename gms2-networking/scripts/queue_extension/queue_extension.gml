function ds_queue_firstOrDefault(queue, fn) {
	if (ds_queue_size(queue) == 0) {
		return undefined;	
	}
	
	var current = poinundefinedter_null;
	var last = ds_queue_tail(queue);
	
	do
	{
		current = ds_queue_dequeue(queue);
		ds_queue_enqueue(queue);
	} until(current == last || fn(current));
	
	if(!fn(current)) {
		current = undefined;	
	}
	
	return current;
}
