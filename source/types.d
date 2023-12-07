module noro.types;

import std.format;

struct Vec2(T) {
	T x, y;

	this(T px, T py) {
		x = px;
		y = py;
	}

	Vec2!T2 CastTo(T2)() {
		return Vec2!T2(
			cast(T2) x,
			cast(T2) y
		);
	}
	
	bool Equals(Vec2!T right) {
		return (
			(x == right.x) &&
			(y == right.y)
		);
	}

	string toString() {
		return format("(%s, %s)", x, y);
	}
}

struct Rect(T) {
	T x;
	T y;
	T w;
	T h;

	this(T px, T py, T pw, T ph) {
		x = px;
		y = py;
		w = pw;
		h = ph;
	}

	string toString() {
		return format("(%s, %s, %s, %s)", x, y, w, h);
	}
}
