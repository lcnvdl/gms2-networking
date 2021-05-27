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

function damp_angle(current, target, delta) {
	//	TODO	This is not working fine.
	return median(-delta, delta, angle_difference(current, target));
}

function chance(posibilities) {
	return irandom(100) < posibilities;	
}
