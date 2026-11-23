extends Control
class_name CityMapView

signal city_selected(city_id: String)

const BG := Color("#0b1b2a")
const GRID := Color("#20384a")
const LAND := Color("#153b4a")
const WATER := Color("#102b3b")
const MUTED := Color("#86a6ba")
const ACCENT := Color("#29d6e8")
const SELECTED := Color("#f0c56b")

var _cities: Array[Dictionary] = []
var _selected_id := ""
var _plot_rect := Rect2()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_refresh_data()
	queue_redraw()

func _refresh_data() -> void:
	_cities.clear()
	for city in GameState.cities:
		_cities.append(city.duplicate(true))
	_selected_id = GameState.selected_city_id

func _draw() -> void:
	draw_style_box(_panel_style(), Rect2(Vector2.ZERO, size))
	if _cities.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(18, 35), "NO CITY COORDINATES AVAILABLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
		return
	var min_lon := 180.0
	var max_lon := -180.0
	var min_lat := 90.0
	var max_lat := -90.0
	for city in _cities:
		var lon := float(city.get("lon", 0.0))
		var lat := float(city.get("lat", 0.0))
		min_lon = minf(min_lon, lon)
		max_lon = maxf(max_lon, lon)
		min_lat = minf(min_lat, lat)
		max_lat = maxf(max_lat, lat)
	var lon_span := maxf(max_lon - min_lon, 2.0)
	var lat_span := maxf(max_lat - min_lat, 2.0)
	var lon_pad := maxf(lon_span * 0.18, 1.0)
	var lat_pad := maxf(lat_span * 0.22, 1.0)
	min_lon -= lon_pad
	max_lon += lon_pad
	min_lat -= lat_pad
	max_lat += lat_pad
	_plot_rect = Rect2(Vector2(18, 30), Vector2(maxf(size.x - 36, 1), maxf(size.y - 48, 1)))
	draw_rect(_plot_rect, WATER)
	for step in range(1, 6):
		var x := _plot_rect.position.x + _plot_rect.size.x * float(step) / 6.0
		var y := _plot_rect.position.y + _plot_rect.size.y * float(step) / 6.0
		draw_line(Vector2(x, _plot_rect.position.y), Vector2(x, _plot_rect.end.y), GRID, 1.0)
		draw_line(Vector2(_plot_rect.position.x, y), Vector2(_plot_rect.end.x, y), GRID, 1.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(14, 20), "CITY LOCATION MAP  •  RELATIVE GEOGRAPHIC POSITIONS", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ACCENT)
	for city in _cities:
		var point := _city_point(float(city.get("lon", 0.0)), float(city.get("lat", 0.0)), min_lon, max_lon, min_lat, max_lat)
		var is_selected := str(city.get("id", "")) == _selected_id
		var radius := 7.0 if is_selected else 4.5
		draw_circle(point, radius + 3.0, Color(ACCENT, 0.12))
		draw_circle(point, radius, SELECTED if is_selected else ACCENT)
		draw_arc(point, radius + 1.5, 0.0, TAU, 24, Color("#e8f3f8"), 1.0)
		var label_color := SELECTED if is_selected else Color("#d6e5ee")
		draw_string(font, point + Vector2(9, -7), str(city.get("name", "City")), HORIZONTAL_ALIGNMENT_LEFT, 150, 10 if not is_selected else 11, label_color)
	draw_string(font, Vector2(14, size.y - 7), "%d CATALOGUED CITIES  •  TAP A MARKER TO OPEN CITY PROFILE" % _cities.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, MUTED)

func _city_point(lon: float, lat: float, min_lon: float, max_lon: float, min_lat: float, max_lat: float) -> Vector2:
	var x_ratio := (lon - min_lon) / maxf(max_lon - min_lon, 0.001)
	var y_ratio := 1.0 - (lat - min_lat) / maxf(max_lat - min_lat, 0.001)
	return Vector2(_plot_rect.position.x + x_ratio * _plot_rect.size.x, _plot_rect.position.y + y_ratio * _plot_rect.size.y)

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
	var min_lon := 180.0
	var max_lon := -180.0
	var min_lat := 90.0
	var max_lat := -90.0
	for city in _cities:
		min_lon = minf(min_lon, float(city.get("lon", 0.0)))
		max_lon = maxf(max_lon, float(city.get("lon", 0.0)))
		min_lat = minf(min_lat, float(city.get("lat", 0.0)))
		max_lat = maxf(max_lat, float(city.get("lat", 0.0)))
	var lon_span := maxf(max_lon - min_lon, 2.0)
	var lat_span := maxf(max_lat - min_lat, 2.0)
	min_lon -= maxf(lon_span * 0.18, 1.0)
	max_lon += maxf(lon_span * 0.18, 1.0)
	min_lat -= maxf(lat_span * 0.22, 1.0)
	max_lat += maxf(lat_span * 0.22, 1.0)
	var nearest_id := ""
	var nearest_distance := 28.0
	for city in _cities:
		var point := _city_point(float(city.get("lon", 0.0)), float(city.get("lat", 0.0)), min_lon, max_lon, min_lat, max_lat)
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
