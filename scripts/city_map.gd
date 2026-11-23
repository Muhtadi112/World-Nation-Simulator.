extends Control
class_name CityMapView

signal city_selected(city_id: String)

const DATA_PATH := "res://data/countries_110m.json"
const BG := Color("#0b1b2a")
const GRID := Color("#20384a")
const LAND := Color("#1b5360")
const WATER := Color("#102b3b")
const MUTED := Color("#86a6ba")
const ACCENT := Color("#29d6e8")
const SELECTED := Color("#f0c56b")

var _cities: Array[Dictionary] = []
var _country_geometry: Array = []
var _selected_id := ""
var _plot_rect := Rect2()
var _min_lon := -180.0
var _max_lon := 180.0
var _min_lat := -90.0
var _max_lat := 90.0
var _map_scale := 1.0
var _map_origin := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_refresh_data()
	queue_redraw()

func _refresh_data() -> void:
	_cities.clear()
	for city in GameState.cities:
		_cities.append(city.duplicate(true))
	_selected_id = GameState.selected_city_id
	_country_geometry.clear()
	var country_id := str(GameState.selected_country.get("id", ""))
	if not FileAccess.file_exists(DATA_PATH):
		return
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for feature in parsed.get("features", []):
		if typeof(feature) == TYPE_DICTIONARY and str(feature.get("c", "")) == country_id:
			_country_geometry = feature.get("g", [])
			break

func _calculate_projection() -> void:
	_min_lon = 180.0
	_max_lon = -180.0
	_min_lat = 90.0
	_max_lat = -90.0
	var found_coordinate := false
	for polygon in _country_geometry:
		for ring in polygon:
			for coordinate in ring:
				if coordinate.size() < 2:
					continue
				var lon := float(coordinate[0])
				var lat := float(coordinate[1])
				_min_lon = minf(_min_lon, lon)
				_max_lon = maxf(_max_lon, lon)
				_min_lat = minf(_min_lat, lat)
				_max_lat = maxf(_max_lat, lat)
				found_coordinate = true
	if not found_coordinate:
		for city in _cities:
			var lon := float(city.get("lon", 0.0))
			var lat := float(city.get("lat", 0.0))
			_min_lon = minf(_min_lon, lon)
			_max_lon = maxf(_max_lon, lon)
			_min_lat = minf(_min_lat, lat)
			_max_lat = maxf(_max_lat, lat)
		_min_lon -= 1.0
		_max_lon += 1.0
		_min_lat -= 1.0
		_max_lat += 1.0
	var lon_span := maxf(_max_lon - _min_lon, 1.0)
	var lat_span := maxf(_max_lat - _min_lat, 1.0)
	var padding := 22.0
	_map_scale = minf(maxf(size.x - padding * 2.0, 1.0) / lon_span, maxf(size.y - 68.0, 1.0) / lat_span)
	_map_origin = Vector2(size.x * 0.5 - ((_min_lon + _max_lon) * 0.5) * _map_scale, 30.0 + (size.y - 68.0) * 0.5 + ((_min_lat + _max_lat) * 0.5) * _map_scale)
	_plot_rect = Rect2(Vector2(8, 26), Vector2(maxf(size.x - 16, 1), maxf(size.y - 42, 1)))

func _project(lon: float, lat: float) -> Vector2:
	return Vector2(_map_origin.x + lon * _map_scale, _map_origin.y - lat * _map_scale)

func _draw() -> void:
	draw_style_box(_panel_style(), Rect2(Vector2.ZERO, size))
	if _cities.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(18, 35), "NO CITY COORDINATES AVAILABLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
		return
	_calculate_projection()
	draw_rect(_plot_rect, WATER)
	for step in range(1, 6):
		var x := _plot_rect.position.x + _plot_rect.size.x * float(step) / 6.0
		var y := _plot_rect.position.y + _plot_rect.size.y * float(step) / 6.0
		draw_line(Vector2(x, _plot_rect.position.y), Vector2(x, _plot_rect.end.y), GRID, 1.0)
		draw_line(Vector2(_plot_rect.position.x, y), Vector2(_plot_rect.end.x, y), GRID, 1.0)
	for polygon in _country_geometry:
		if polygon.is_empty():
			continue
		var outer := PackedVector2Array()
		for coordinate in polygon[0]:
			outer.append(_project(float(coordinate[0]), float(coordinate[1])))
		if outer.size() >= 3:
			draw_colored_polygon(outer, LAND)
			draw_polyline(outer, Color("#4d8791"), 1.0, true)
		for ring_index in range(1, polygon.size()):
			var hole := PackedVector2Array()
			for coordinate in polygon[ring_index]:
				hole.append(_project(float(coordinate[0]), float(coordinate[1])))
			if hole.size() > 2:
				draw_polyline(hole, Color("#4d8791"), 0.8, true)
	var font := ThemeDB.fallback_font
	var country_name := str(GameState.selected_country.get("name", "COUNTRY"))
	draw_string(font, Vector2(14, 19), country_name.to_upper() + "  /  CITY NETWORK", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ACCENT)
	for city in _cities:
		var point := _project(float(city.get("lon", 0.0)), float(city.get("lat", 0.0)))
		var is_selected := str(city.get("id", "")) == _selected_id
		var radius := 7.0 if is_selected else 4.5
		draw_circle(point, radius + 3.0, Color(ACCENT, 0.14))
		draw_circle(point, radius, SELECTED if is_selected else ACCENT)
		draw_arc(point, radius + 1.5, 0.0, TAU, 24, Color("#e8f3f8"), 1.0)
		var label_color := SELECTED if is_selected else Color("#d6e5ee")
		draw_string(font, point + Vector2(9, -7), str(city.get("name", "City")), HORIZONTAL_ALIGNMENT_LEFT, 150, 10 if not is_selected else 11, label_color)
	draw_string(font, Vector2(14, size.y - 7), "%d CATALOGUED CITIES  •  TAP A MARKER TO OPEN CITY PROFILE" % _cities.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, MUTED)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_nearest(event.position)
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		_select_nearest(event.position)
		accept_event()

func _select_nearest(position: Vector2) -> void:
	if _cities.is_empty() or not _plot_rect.has_point(position):
		return
	var nearest_id := ""
	var nearest_distance := 28.0
	for city in _cities:
		var point := _project(float(city.get("lon", 0.0)), float(city.get("lat", 0.0)))
		var distance := point.distance_to(position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = str(city.get("id", ""))
	if not nearest_id.is_empty():
		_selected_id = nearest_id
		queue_redraw()
		city_selected.emit(nearest_id)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = BG
	style.border_color = GRID
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	return style
