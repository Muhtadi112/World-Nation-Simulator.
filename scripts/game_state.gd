extends Node

signal state_changed

const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/autosave.json"

var game_mode: String = "Career"
var selected_country: Dictionary = {}
var game_date: Dictionary = {"year": 2026, "month": 1, "day": 1}
var simulation_speed: int = 1
var is_paused: bool = false
var treasury: float = 125000000000.0
var population: int = 281000000
var gdp: float = 1371000000000.0
var inflation: float = 2.8
var unemployment: float = 4.9
var _day_accumulator: float = 0.0

const COUNTRIES: Array[Dictionary] = [
	{"id":"IDN","name":"Indonesia","capital":"Jakarta","population":281000000,"gdp":1371000000000.0,"currency":"IDR","flag":"🇮🇩","region":"Asia"},
	{"id":"USA","name":"United States","capital":"Washington, D.C.","population":347000000,"gdp":29170000000000.0,"currency":"USD","flag":"🇺🇸","region":"North America"},
	{"id":"CHN","name":"China","capital":"Beijing","population":1408000000,"gdp":18740000000000.0,"currency":"CNY","flag":"🇨🇳","region":"Asia"},
	{"id":"JPN","name":"Japan","capital":"Tokyo","population":123000000,"gdp":4110000000000.0,"currency":"JPY","flag":"🇯🇵","region":"Asia"},
	{"id":"DEU","name":"Germany","capital":"Berlin","population":84500000,"gdp":4710000000000.0,"currency":"EUR","flag":"🇩🇪","region":"Europe"},
	{"id":"GBR","name":"United Kingdom","capital":"London","population":69600000,"gdp":3580000000000.0,"currency":"GBP","flag":"🇬🇧","region":"Europe"},
	{"id":"BRA","name":"Brazil","capital":"Brasília","population":212000000,"gdp":2170000000000.0,"currency":"BRL","flag":"🇧🇷","region":"South America"},
	{"id":"IND","name":"India","capital":"New Delhi","population":1450000000,"gdp":3930000000000.0,"currency":"INR","flag":"🇮🇳","region":"Asia"}
]

func _process(delta: float) -> void:
	if is_paused:
		return
	_day_accumulator += delta * float(simulation_speed)
	if _day_accumulator >= 3.0:
		_day_accumulator = 0.0
		_advance_day()

func _advance_day() -> void:
	game_date["day"] += 1
	if int(game_date["day"]) > 30:
		game_date["day"] = 1
		game_date["month"] += 1
		if int(game_date["month"]) > 12:
			game_date["month"] = 1
			game_date["year"] += 1
	state_changed.emit()

func start_new_game(mode: String, country: Dictionary) -> void:
	game_mode = mode
	selected_country = country.duplicate(true)
	population = int(country.get("population", 1000000))
	gdp = float(country.get("gdp", 1000000000.0))
	treasury = gdp * 0.12
	game_date = {"year": 2026, "month": 1, "day": 1}
	simulation_speed = 1
	is_paused = false
	_day_accumulator = 0.0
	state_changed.emit()

func save_game() -> bool:
	var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		push_error("Unable to create save directory: %s" % dir_error)
		return false
	var payload := {
		"game_mode": game_mode,
		"selected_country": selected_country,
		"game_date": game_date,
		"treasury": treasury,
		"population": population,
		"gdp": gdp,
		"inflation": inflation,
		"unemployment": unemployment
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to open save file.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Save file is invalid; starting without loading it.")
		return false
	var data: Dictionary = parsed
	game_mode = str(data.get("game_mode", "Career"))
	selected_country = data.get("selected_country", {})
	game_date = data.get("game_date", {"year":2026,"month":1,"day":1})
	treasury = float(data.get("treasury", 0.0))
	population = int(data.get("population", 0))
	gdp = float(data.get("gdp", 0.0))
	inflation = float(data.get("inflation", 2.8))
	unemployment = float(data.get("unemployment", 4.9))
	state_changed.emit()
	return not selected_country.is_empty()

func formatted_date() -> String:
	return "%02d %s %d" % [int(game_date["day"]), _month_name(int(game_date["month"])), int(game_date["year"])]

func _month_name(month: int) -> String:
	var months := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	return months[clampi(month - 1, 0, 11)]
