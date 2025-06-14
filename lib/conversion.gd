class_name UnitConversion

static func to_meters(pixels: float) -> float:
	return pixels / 300.0

static func to_pixels(meters: float) -> float:
	return meters * 300.0
