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

function damp_angle(current, target, delta) {
	var tempdir;
	var diff = abs(target-current);
	var angle = current;
	
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
