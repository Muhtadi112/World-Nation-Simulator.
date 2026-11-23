extends Control
class_name WorldMapView

# Interactive prototype map. Coastlines remain illustrative until real boundary data is integrated.
var zoom: float = 1.0
var pan: Vector2 = Vector2.ZERO
var _dragging := false
var _last_pointer := Vector2.ZERO

const ZOOM_MIN := 0.65
const ZOOM_MAX := 2.8
const MAP_CENTER := Vector2(400.0, 205.0)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0d1b2a"))
	var fitted := minf(size.x / 800.0, size.y / 410.0)
	var map_scale := fitted * zoom
	var origin := (size - MAP_CENTER * map_scale * 2.0) * 0.5 + pan
	draw_set_transform(origin, 0.0, Vector2.ONE * map_scale)
	var land := Color("#1c3d4b")
	var edge := Color("#2d6470")
	var shapes: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(75,100),Vector2(130,65),Vector2(190,82),Vector2(215,125),Vector2(185,160),Vector2(145,150),Vector2(120,190),Vector2(85,165),Vector2(60,130)]),
		PackedVector2Array([Vector2(210,195),Vector2(260,165),Vector2(305,185),Vector2(325,235),Vector2(290,280),Vector2(245,270),Vector2(215,235)]),
		PackedVector2Array([Vector2(365,90),Vector2(430,65),Vector2(500,85),Vector2(535,130),Vector2(510,185),Vector2(455,195),Vector2(420,160),Vector2(380,150)]),
		PackedVector2Array([Vector2(440,220),Vector2(485,205),Vector2(520,235),Vector2(510,285),Vector2(475,310),Vector2(445,275)]),
		PackedVector2Array([Vector2(570,100),Vector2(630,80),Vector2(690,105),Vector2(720,150),Vector2(690,195),Vector2(640,185),Vector2(600,155)]),
		PackedVector2Array([Vector2(650,230),Vector2(700,210),Vector2(745,245),Vector2(735,300),Vector2(690,320),Vector2(660,285)]),
		PackedVector2Array([Vector2(110,280),Vector2(160,260),Vector2(205,285),Vector2(195,340),Vector2(150,365),Vector2(115,330)]),
		PackedVector2Array([Vector2(300,320),Vector2(350,300),Vector2(390,330),Vector2(380,375),Vector2(335,390),Vector2(300,360)])
	]
	for polygon in shapes:
		draw_colored_polygon(polygon, land)
		draw_polyline(polygon, edge, 2.0, true)
	for x in range(0, 801, 80):
		draw_line(Vector2(x, 0), Vector2(x, 410), Color(0.25, 0.55, 0.65, 0.08), 1.0)
	for y in range(0, 411, 65):
		draw_line(Vector2(0, y), Vector2(800, y), Color(0.25, 0.55, 0.65, 0.08), 1.0)
	draw_circle(Vector2(610, 250), 6.0, Color("#29d6bd"))
	draw_circle(Vector2(610, 250), 13.0, Color(0.16, 0.84, 0.74, 0.15))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_string(ThemeDB.fallback_font, Vector2(14, size.y - 14), "ILLUSTRATIVE MAP  •  DRAG TO MOVE  •  SCROLL TO ZOOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#7895a8"))
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 82, 24), "%d%%" % int(zoom * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 68, 11, Color("#29d6e8"))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_last_pointer = event.position
			accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, 1.12)
			accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, 1.0 / 1.12)
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		pan += event.position - _last_pointer
		_last_pointer = event.position
		queue_redraw()
		accept_event()
	elif event is InputEventScreenTouch:
		_dragging = event.pressed
		_last_pointer = event.position
		accept_event()
	elif event is InputEventScreenDrag and _dragging:
		pan += event.position - _last_pointer
		_last_pointer = event.position
		queue_redraw()
		accept_event()

func _zoom_at(pointer: Vector2, factor: float) -> void:
	var next_zoom := clampf(zoom * factor, ZOOM_MIN, ZOOM_MAX)
	if is_equal_approx(next_zoom, zoom):
		return
	var ratio := next_zoom / zoom
	pan = pointer - (pointer - pan) * ratio
	zoom = next_zoom
	queue_redraw()
