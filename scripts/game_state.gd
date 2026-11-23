extends Node

signal state_changed

const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/autosave.json"
const COUNTRY_DATA_PATH := "res://data/countries_110m.json"

var game_mode: String = "Career"
var selected_country: Dictionary = {}
var country_catalog: Array[Dictionary] = []
var game_date: Dictionary = {"year": 2026, "month": 1, "day": 1}
var simulation_speed: int = 1
var is_paused: bool = false
var treasury: float = 125000000000.0
var population: int = 281000000
var gdp: float = 1371000000000.0
var inflation: float = 2.8
var unemployment: float = 4.9
var _day_accumulator: float = 0.0

const CAPITALS := {
	"IDN":"Jakarta","USA":"Washington, D.C.","CHN":"Beijing","JPN":"Tokyo","DEU":"Berlin",
	"GBR":"London","BRA":"Brasília","IND":"New Delhi","CAN":"Ottawa","FRA":"Paris",
	"RUS":"Moscow","AUS":"Canberra","KOR":"Seoul","PRK":"Pyongyang","ITA":"Rome",
	"ESP":"Madrid","MEX":"Mexico City","SAU":"Riyadh","TUR":"Ankara","ZAF":"Pretoria",
	"EGY":"Cairo","NGA":"Abuja","PAK":"Islamabad","BGD":"Dhaka","THA":"Bangkok",
	"VNM":"Hanoi","MYS":"Kuala Lumpur","SGP":"Singapore","PHL":"Manila","NZL":"Wellington",
	"ARG":"Buenos Aires","CHL":"Santiago","COL":"Bogotá","PER":"Lima","UKR":"Kyiv",
	"POL":"Warsaw","NLD":"Amsterdam","BEL":"Brussels","CHE":"Bern","SWE":"Stockholm",
	"NOR":"Oslo","FIN":"Helsinki","GRC":"Athens","IRN":"Tehran","IRQ":"Baghdad",
	"ISR":"Jerusalem","ARE":"Abu Dhabi","QAT":"Doha","ETH":"Addis Ababa","KEN":"Nairobi",
	"TZA":"Dodoma","GHA":"Accra","MAR":"Rabat","DZA":"Algiers","CUB":"Havana",
	"VEN":"Caracas","ECU":"Quito","URY":"Montevideo","PRY":"Asunción","AFG":"Kabul",
	"NPL":"Kathmandu","LKA":"Sri Jayawardenepura Kotte","MMR":"Naypyidaw","KHM":"Phnom Penh",
	"LAO":"Vientiane","BRN":"Bandar Seri Begawan","TLS":"Dili","FJI":"Suva","PNG":"Port Moresby"
}

const CURRENCIES := {
	"IDN":"IDR","USA":"USD","CHN":"CNY","JPN":"JPY","DEU":"EUR","GBR":"GBP","BRA":"BRL",
	"IND":"INR","CAN":"CAD","FRA":"EUR","RUS":"RUB","AUS":"AUD","KOR":"KRW","MEX":"MXN",
	"SAU":"SAR","TUR":"TRY","ZAF":"ZAR","EGY":"EGP","NGA":"NGN","PAK":"PKR","BGD":"BDT",
	"THA":"THB","VNM":"VND","MYS":"MYR","SGP":"SGD","PHL":"PHP","NZL":"NZD","ARG":"ARS",
	"CHL":"CLP","COL":"COP","PER":"PEN","UKR":"UAH","POL":"PLN","NLD":"EUR","BEL":"EUR",
	"CHE":"CHF","SWE":"SEK","NOR":"NOK","FIN":"EUR","GRC":"EUR","IRN":"IRR","IRQ":"IQD",
	"ISR":"ILS","ARE":"AED","QAT":"QAR","KEN":"KES","GHA":"GHS","MAR":"MAD","DZA":"DZD",
	"CUB":"CUP","VEN":"VES","ECU":"USD","URY":"UYU","PRY":"PYG","AFG":"AFN","NPL":"NPR",
	"LKA":"LKR","MMR":"MMK","KHM":"KHR","LAO":"LAK","BRN":"BND","TLS":"USD","FJI":"FJD"
}

func _ready() -> void:
	load_country_catalog()

func load_country_catalog() -> void:
	country_catalog.clear()
	if not FileAccess.file_exists(COUNTRY_DATA_PATH):
		push_error("Country catalogue is missing: " + COUNTRY_DATA_PATH)
		return
	var file := FileAccess.open(COUNTRY_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to read country catalogue.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Country catalogue JSON is invalid.")
		return
	for row in parsed.get("features", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var iso := str(row.get("c", ""))
		var name := str(row.get("n", "Unknown"))
		if iso.is_empty() or iso == "-99":
			continue
		country_catalog.append({
			"id": iso,
			"name": _display_country_name(name),
			"source_name": name,
			"capital": str(CAPITALS.get(iso, "Not listed")),
			"population": int(row.get("pop", 0)),
			"gdp": float(row.get("gdp", 0.0)),
			"currency": str(CURRENCIES.get(iso, "Not listed")),
			"flag": _flag_from_iso(iso),
			"region": str(row.get("r", "Other")),
			"data_year": 2019
		})
	country_catalog.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.name).naturalcasecmp_to(str(b.name)) < 0)

func _display_country_name(source_name: String) -> String:
	var aliases := {
		"United States of America":"United States",
		"Russian Federation":"Russia",
		"Republic of Korea":"South Korea",
		"Democratic People's Republic of Korea":"North Korea",
		"United Republic of Tanzania":"Tanzania",
		"Bolivia":"Bolivia",
		"Venezuela":"Venezuela"
	}
	return str(aliases.get(source_name, source_name))

func _flag_from_iso(iso: String) -> String:
	if iso.length() != 3:
		return "🏳"
	var flag := ""
	for index in range(2):
		var code := iso.unicode_at(index)
		if code < 65 or code > 90:
			return "🏳"
		flag += String.chr(127397 + code)
	return flag

func find_country(iso: String) -> Dictionary:
	for country in country_catalog:
		if str(country.id) == iso:
			return country.duplicate(true)
	return {}

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
		"game_mode": game_mode, "selected_country": selected_country,
		"game_date": game_date, "treasury": treasury, "population": population,
		"gdp": gdp, "inflation": inflation, "unemployment": unemployment
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
