function DsQueueEnumerator(_queue) : BaseEnumerator() constructor {
	_ds = _queue;
	_position = -1;
	_first = ds_queue_head(_ds);
	
	if (is_undefined(_first) && ds_queue_size(_ds) > 0) {
		throw "Undefined element in queue";	
	}
	
    static MoveNext = function() {
        _position++;
		
		var canMove = _position < ds_queue_size(_ds);
		
		if(!ds_queue_empty(_ds) && canMove) {
			ds_queue_enqueue(_ds, ds_queue_dequeue(_ds));
		}
		
        return canMove;
    };

    static Reset = function() {
		if(_position == -1) {
			return;	
		}
		
		if (is_undefined(_first)) {
			//	BUG: _first value turns into undefined
			_first = ds_queue_head(_ds);
		}
		
		var antiLoop = 0;
		
		while(ds_queue_size(_ds) > 1 && ds_queue_tail(_ds) != _first) {
			var first = ds_queue_dequeue(_ds);
			ds_queue_enqueue(_ds, first);
			if (antiLoop ++ > ds_queue_size(_ds)) {
				throw "Anti-Loop protection";	
			}
		}
		
		_position = -1;
    };

	static GetCurrent = function() {
		if (_position == -1 || _position >= ds_queue_size(_ds)) {
			return undefined;	
		}
		
		return ds_queue_tail(_ds);
	};
}