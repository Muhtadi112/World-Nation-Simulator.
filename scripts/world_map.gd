extends Control
class_name WorldMapView

signal country_selected(country: Dictionary)

const DATA_PATH := "res://data/countries_110m.json"
const MAP_SIZE := Vector2(800.0, 410.0)
const ZOOM_MIN := 0.7
const ZOOM_MAX := 4.0

var zoom := 1.0
var pan := Vector2.ZERO
var countries: Array[Dictionary] = []
var cities: Array[Dictionary] = []
var selected_iso := ""
var _dragging := false
var _press_position := Vector2.ZERO
var _last_pointer := Vector2.ZERO
var _did_drag := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_load_countries()
	_load_cities()
	queue_redraw()

func _load_countries() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("World country boundary dataset is missing.")
		return
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open world country boundary dataset.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("World country boundary dataset is invalid.")
		return
	var rows: Variant = parsed.get("features", [])
	if typeof(rows) != TYPE_ARRAY:
		return
	for row in rows:
		if typeof(row) == TYPE_DICTIONARY:
			countries.append(row)

func _load_cities() -> void:
	var file := FileAccess.open("res://data/world_cities.json", FileAccess.READ)
	if file == null:
		push_warning("World city catalogue is unavailable.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var rows: Variant = parsed.get("cities", [])
	if typeof(rows) == TYPE_ARRAY:
		for row in rows:
			if typeof(row) == TYPE_DICTIONARY:
				cities.append(row)

func _map_transform() -> Dictionary:
	var fit := minf(size.x / MAP_SIZE.x, size.y / MAP_SIZE.y)
	var scale := fit * zoom
	var origin := (size - MAP_SIZE * scale) * 0.5 + pan
	return {"scale": scale, "origin": origin}

func _project(lon: float, lat: float) -> Vector2:
	return Vector2((lon + 180.0) / 360.0 * MAP_SIZE.x, (90.0 - lat) / 180.0 * MAP_SIZE.y)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0b1928"))
	var transform := _map_transform()
	var scale: float = transform.scale
	var origin: Vector2 = transform.origin
	draw_set_transform(origin, 0.0, Vector2.ONE * scale)
	for country in countries:
		var polygons: Array = country.get("g", [])
		for polygon in polygons:
			if polygon.is_empty():
				continue
			var points := PackedVector2Array()
			for coordinate in polygon[0]:
				points.append(_project(float(coordinate[0]), float(coordinate[1])))
			if points.size() < 3:
				continue
			var iso := str(country.get("c", ""))
			var fill := Color("#245063") if iso != selected_iso else Color("#16a58f")
			draw_colored_polygon(points, fill)
			draw_polyline(points, Color("#47788a") if iso != selected_iso else Color("#7df0d6"), 0.75, true)
			for hole_index in range(1, polygon.size()):
				var hole := PackedVector2Array()
				for coordinate in polygon[hole_index]:
					hole.append(_project(float(coordinate[0]), float(coordinate[1])))
				if hole.size() > 2:
					draw_polyline(hole, Color("#47788a"), 0.55, true)

	# Major city network from Business Cargo Simulator's WGS84 world-city catalogue.
	for city in cities:
		var point := Vector2(float(city.get("mapX", 0.5)) * MAP_SIZE.x, float(city.get("mapY", 0.5)) * MAP_SIZE.y)
		var tier := int(city.get("tier", 3))
		var marker_color := Color("#5de4c7") if tier == 1 else (Color("#50b8d8") if tier == 2 else Color("#8aa9bd"))
		draw_circle(point, 2.2 if tier == 1 else 1.45, marker_color)
		if zoom >= 1.35 and tier <= 2:
			draw_string(ThemeDB.fallback_font, point + Vector2(5, -4), str(city.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, 110, 9, Color("#d9edf5"))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_string(ThemeDB.fallback_font, Vector2(14, size.y - 14), "NATURAL EARTH  •  %d COUNTRIES / AREAS  •  DRAG & ZOOM" % countries.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#8ba8bb"))
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 72, 22), "%d%%" % int(zoom * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 58, 11, Color("#29d6e8"))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_did_drag = false
				_press_position = event.position
				_last_pointer = event.position
			else:
				if _dragging and not _did_drag:
					_select_at(event.position)
				_dragging = false
			accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, 1.15)
			accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, 1.0 / 1.15)
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		if event.position.distance_to(_press_position) > 7.0:
			_did_drag = true
		pan += event.position - _last_pointer
		_last_pointer = event.position
		queue_redraw()
		accept_event()
	elif event is InputEventScreenTouch:
		if event.pressed:
			_dragging = true
			_did_drag = false
			_press_position = event.position
			_last_pointer = event.position
		else:
			if _dragging and not _did_drag:
				_select_at(event.position)
			_dragging = false
		accept_event()
	elif event is InputEventScreenDrag and _dragging:
		if event.position.distance_to(_press_position) > 7.0:
			_did_drag = true
		pan += event.position - _last_pointer
		_last_pointer = event.position
		queue_redraw()
		accept_event()

func _select_at(screen_position: Vector2) -> void:
	var transform := _map_transform()
	var origin: Vector2 = transform["origin"]
	var scale: float = transform["scale"]
	var map_point: Vector2 = (screen_position - origin) / scale
	for country_index in range(countries.size() - 1, -1, -1):
		var country := countries[country_index]
		for polygon in country.get("g", []):
			if polygon.is_empty():
				continue
			var points := PackedVector2Array()
			for coordinate in polygon[0]:
				points.append(_project(float(coordinate[0]), float(coordinate[1])))
			if points.size() >= 3 and Geometry2D.is_point_in_polygon(map_point, points):
				selected_iso = str(country.get("c", ""))
				queue_redraw()
				country_selected.emit({"id": selected_iso, "name": str(country.get("n", "Unknown")), "region": str(country.get("r", "Other")), "population": int(country.get("pop", 0)), "gdp": float(country.get("gdp", 0))})
				return

func _zoom_at(pointer: Vector2, factor: float) -> void:
	var next_zoom := clampf(zoom * factor, ZOOM_MIN, ZOOM_MAX)
	if is_equal_approx(next_zoom, zoom):
		return
	var ratio := next_zoom / zoom
	pan = pointer - (pointer - pan) * ratio
	zoom = next_zoom
	queue_redraw()
