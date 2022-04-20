function choose2(a, b, aPossibilities) {
	if(irandom(100) <= aPossibilities) {
		return a;
	}
	else {
		return b;
	}
}

function damp(current, target, delta) {
	var d = target - current;
	if (abs(d) <= delta) {
		return target;
	}
	else {
		return current + sign(d) * delta;
	}
}

function smooth_damp(current, target, dampSpeed) {
	if (dampSpeed < 0 || dampSpeed > 1) {
		throw "Smooth damp speed must be a value between [0, 1].";
	}
	
	var d = target - current;
	if (abs(d) < 0.0005)
	{
	   return target;
	}
	else 
	{
	   return current + sign(d) * abs(d) * dampSpeed;
	}
}

function damp_angle(current, _target, delta) {
	var tempdir;
	var target = round(_target) mod 360;
	var angle = round(current) mod 360;
	var diff = abs(target-angle);
	
	if (diff > 180)
	{
	    if (target > 180)
	    {
	        tempdir = target - 360;
	        if (abs(tempdir - angle) > delta)
	        {
	            angle -= delta;
	        }
	        else
	        {
	            angle = target;
	        }
	    }
	    else
	    {
	        tempdir = target + 360;
	        if (abs(tempdir - angle) > delta)
	        {
	            angle += delta;
	        }
	        else
	        {
	            angle = target;
	        }
	    }
	}
	else
	{
	    if (diff > delta)
	    {
	        if (target > angle)
	        {
	            angle += delta;
	        }
	        else
	        {
	            angle -= delta;
	        }
	    }
	    else
	    {
	        angle = target;
	    }
	}
	
	return angle;
}

///	@function ichance(posibilities)
/** 
* @param {real} posibilities - Possibilities to be true (0-100).
* @return {boolean} True or false.
*/
function chance(posibilities) {
	return random(100) < posibilities;	
}

///	@function ichance(posibilities)
/** 
* @param {integer} posibilities - Possibilities to be true (0-100).
* @return {boolean} True or false.
*/
function ichance(posibilities) {
	return irandom(100) < floor(posibilities);	
}

///	@function choose_weighted(value1, weight1, ...)
function choose_weighted() {
    var n = 0;
    for (var i = 1; i < argument_count; i += 2) {
        if (argument[i] <= 0) continue;
        n += argument[i];
    }
    
    n = random(n);
    for (var i = 1; i < argument_count; i += 2) {
        if (argument[i] <= 0) continue;
        n -= argument[i];
        if (n < 0) return argument[i - 1];
    }
    
    return argument[0];
}