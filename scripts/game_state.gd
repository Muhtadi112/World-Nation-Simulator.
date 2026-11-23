extends Node

signal state_changed

const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/autosave.json"
const COUNTRY_DATA_PATH := "res://data/countries_110m.json"

var game_mode: String = "Career"
var selected_country: Dictionary = {}
var country_catalog: Array[Dictionary] = []
var ai_countries: Array[Dictionary] = []
var diplomacy_relations: Dictionary = {}
var game_date: Dictionary = {"year": 2026, "month": 1, "day": 1}
var simulation_speed: int = 1
var is_paused: bool = false
var treasury: float = 125000000000.0
var population: int = 281000000
var gdp: float = 1371000000000.0
var inflation: float = 2.8
var unemployment: float = 4.9
var debt: float = 0.0
var tax_rate: float = 0.18
var spending_rate: float = 0.165
var monthly_revenue: float = 0.0
var monthly_expenses: float = 0.0
var monthly_balance: float = 0.0
var annual_gdp_growth: float = 3.2
var stability: float = 72.0
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
	var month_changed := false
	if int(game_date["day"]) > 30:
		game_date["day"] = 1
		game_date["month"] += 1
		month_changed = true
		if int(game_date["month"]) > 12:
			game_date["month"] = 1
			game_date["year"] += 1
	if month_changed:
		_run_monthly_economy()
		_run_ai_world_simulation()
		_run_diplomacy_monthly_effects()
	state_changed.emit()

func _run_monthly_economy() -> void:
	if gdp <= 0.0:
		return
	monthly_revenue = gdp * tax_rate / 12.0
	monthly_expenses = gdp * spending_rate / 12.0
	monthly_balance = monthly_revenue - monthly_expenses
	treasury += monthly_balance
	if treasury < 0.0:
		debt += absf(treasury)
		treasury = 0.0
	else:
		var debt_payment := minf(treasury * 0.08, debt)
		treasury -= debt_payment
		debt -= debt_payment
	var monthly_growth := (annual_gdp_growth / 100.0) / 12.0
	var investment_effect := (spending_rate - 0.12) * 0.004
	var stability_effect := (stability - 50.0) * 0.000015
	var inflation_effect := maxf(0.0, inflation - 5.0) * 0.00008
	gdp *= 1.0 + monthly_growth + investment_effect + stability_effect - inflation_effect
	var annual_population_growth := 0.008 + (stability - 50.0) * 0.00004 - maxf(0.0, unemployment - 8.0) * 0.0001
	population = maxi(1, int(float(population) * (1.0 + annual_population_growth / 12.0)))
	var demand_pressure := (spending_rate - tax_rate) * 0.08
	inflation = clampf(inflation + demand_pressure, 0.0, 40.0)
	unemployment = clampf(unemployment - (annual_gdp_growth - 2.0) * 0.015 + (inflation - 6.0) * 0.008, 1.0, 35.0)
	stability = clampf(stability + (monthly_balance / maxf(gdp / 12.0, 1.0)) * 1.5 - maxf(0.0, inflation - 8.0) * 0.08, 0.0, 100.0)
	annual_gdp_growth = clampf(annual_gdp_growth + (stability - 60.0) * 0.001 - maxf(0.0, inflation - 5.0) * 0.01, -15.0, 20.0)

func _initialize_ai_countries() -> void:
	ai_countries.clear()
	var player_id := str(selected_country.get("id", ""))
	for country in country_catalog:
		var country_id := str(country.get("id", ""))
		if country_id == player_id:
			continue
		var base_gdp := maxf(float(country.get("gdp", 1000000000.0)), 1000000.0)
		var seed_value := float(abs(country_id.hash()) % 1000) / 1000.0
		ai_countries.append({
			"id": country_id, "name": str(country.get("name", "Unknown")),
			"flag": str(country.get("flag", "🏳")), "capital": str(country.get("capital", "Not listed")),
			"region": str(country.get("region", "Other")),
			"population": maxi(1, int(country.get("population", 1000000))),
			"gdp": base_gdp, "debt": base_gdp * (0.18 + seed_value * 0.42),
			"treasury": base_gdp * (0.04 + seed_value * 0.10),
			"inflation": 1.5 + seed_value * 5.0,
			"unemployment": 3.0 + seed_value * 7.0,
			"growth": 1.0 + seed_value * 5.0,
			"stability": 48.0 + seed_value * 42.0,
			"tax_rate": 0.12 + seed_value * 0.14,
			"spending_rate": 0.13 + seed_value * 0.12
		})

func _run_ai_world_simulation() -> void:
	for index in range(ai_countries.size()):
		var nation: Dictionary = ai_countries[index]
		var nation_gdp := maxf(float(nation.get("gdp", 1.0)), 1.0)
		var tax := float(nation.get("tax_rate", 0.18))
		var spending := float(nation.get("spending_rate", 0.17))
		var revenue := nation_gdp * tax / 12.0
		var expenses := nation_gdp * spending / 12.0
		var balance := revenue - expenses
		var cash := float(nation.get("treasury", 0.0)) + balance
		var nation_debt := float(nation.get("debt", 0.0))
		if cash < 0.0:
			nation_debt += absf(cash)
			cash = 0.0
		else:
			var repayment := minf(cash * 0.04, nation_debt)
			cash -= repayment
			nation_debt -= repayment
		var nation_stability := float(nation.get("stability", 60.0))
		var nation_inflation := float(nation.get("inflation", 3.0))
		var growth := float(nation.get("growth", 2.5))
		var growth_delta := growth / 1200.0 + (nation_stability - 55.0) * 0.000008 - maxf(0.0, nation_inflation - 7.0) * 0.00004
		nation_gdp *= maxf(0.80, 1.0 + growth_delta)
		nation_inflation = clampf(nation_inflation + (spending - tax) * 0.035, 0.0, 45.0)
		var unemployment_rate := clampf(float(nation.get("unemployment", 5.0)) - (growth - 2.0) * 0.008 + maxf(0.0, nation_inflation - 8.0) * 0.004, 1.0, 40.0)
		nation_stability = clampf(nation_stability + (balance / maxf(nation_gdp / 12.0, 1.0)) * 0.18 - maxf(0.0, nation_inflation - 9.0) * 0.025, 5.0, 100.0)
		var annual_pop_growth := 0.006 + (nation_stability - 50.0) * 0.000025 - maxf(0.0, unemployment_rate - 10.0) * 0.00005
		nation["population"] = maxi(1, int(float(nation.get("population", 1)) * (1.0 + annual_pop_growth / 12.0)))
		nation["gdp"] = nation_gdp
		nation["debt"] = nation_debt
		nation["treasury"] = cash
		nation["inflation"] = nation_inflation
		nation["unemployment"] = unemployment_rate
		nation["stability"] = nation_stability
		ai_countries[index] = nation

func get_ai_country(country_id: String) -> Dictionary:
	for nation in ai_countries:
		if str(nation.get("id", "")) == country_id:
			return nation.duplicate(true)
	return {}

func _initialize_diplomacy() -> void:
	diplomacy_relations.clear()
	for nation in ai_countries:
		var nation_id := str(nation.get("id", ""))
		var seed_value := float(abs(nation_id.hash()) % 201) - 100.0
		diplomacy_relations[nation_id] = {
			"relation": clampf(seed_value * 0.35, -35.0, 35.0),
			"trade_agreement": false,
			"alliance": false,
			"sanctions": false,
			"at_war": false
		}

func get_diplomacy(country_id: String) -> Dictionary:
	if not diplomacy_relations.has(country_id):
		return {}
	return (diplomacy_relations[country_id] as Dictionary).duplicate(true)

func improve_relations(country_id: String) -> bool:
	if not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if bool(treaty.get("at_war", false)):
		return false
	var cost := maxf(gdp * 0.00015, 100000.0)
	if treasury < cost:
		return false
	treasury -= cost
	treaty["relation"] = clampf(float(treaty.get("relation", 0.0)) + 15.0, -100.0, 100.0)
	diplomacy_relations[country_id] = treaty
	state_changed.emit()
	return true

func establish_trade_agreement(country_id: String) -> bool:
	if not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if bool(treaty.get("at_war", false)) or bool(treaty.get("sanctions", false)) or float(treaty.get("relation", 0.0)) < -20.0:
		return false
	treaty["trade_agreement"] = true
	diplomacy_relations[country_id] = treaty
	state_changed.emit()
	return true

func establish_alliance(country_id: String) -> bool:
	if not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if bool(treaty.get("at_war", false)) or not bool(treaty.get("trade_agreement", false)) or float(treaty.get("relation", 0.0)) < 50.0:
		return false
	treaty["alliance"] = true
	diplomacy_relations[country_id] = treaty
	state_changed.emit()
	return true

func impose_sanctions(country_id: String) -> bool:
	if not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if bool(treaty.get("at_war", false)):
		return false
	treaty["sanctions"] = true
	treaty["trade_agreement"] = false
	treaty["alliance"] = false
	treaty["relation"] = clampf(float(treaty.get("relation", 0.0)) - 20.0, -100.0, 100.0)
	diplomacy_relations[country_id] = treaty
	state_changed.emit()
	return true

func declare_war(country_id: String) -> bool:
	if not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if bool(treaty.get("at_war", false)):
		return false
	treaty["at_war"] = true
	treaty["trade_agreement"] = false
	treaty["alliance"] = false
	treaty["sanctions"] = false
	treaty["relation"] = -100.0
	diplomacy_relations[country_id] = treaty
	stability = maxf(0.0, stability - 8.0)
	state_changed.emit()
	return true

func make_peace(country_id: String) -> bool:
	if not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if not bool(treaty.get("at_war", false)):
		return false
	treaty["at_war"] = false
	treaty["relation"] = -35.0
	diplomacy_relations[country_id] = treaty
	state_changed.emit()
	return true

func _run_diplomacy_monthly_effects() -> void:
	var active_trade_partners := 0
	var active_wars := 0
	for country_id in diplomacy_relations.keys():
		var treaty: Dictionary = diplomacy_relations[country_id]
		if bool(treaty.get("trade_agreement", false)) and not bool(treaty.get("at_war", false)):
			active_trade_partners += 1
			treaty["relation"] = clampf(float(treaty.get("relation", 0.0)) + 0.15, -100.0, 100.0)
		if bool(treaty.get("at_war", false)):
			active_wars += 1
		diplomacy_relations[country_id] = treaty
	var trade_income := gdp * 0.00012 * float(active_trade_partners)
	var war_cost := gdp * 0.00025 * float(active_wars)
	treasury = maxf(0.0, treasury + trade_income - war_cost)
	if active_wars > 0:
		stability = maxf(0.0, stability - 0.25 * float(active_wars))

func _update_budget_forecast() -> void:
	monthly_revenue = maxf(0.0, gdp) * tax_rate / 12.0
	monthly_expenses = maxf(0.0, gdp) * spending_rate / 12.0
	monthly_balance = monthly_revenue - monthly_expenses

func set_budget_policy(new_tax_rate: float, new_spending_rate: float) -> void:
	tax_rate = clampf(new_tax_rate, 0.05, 0.40)
	spending_rate = clampf(new_spending_rate, 0.05, 0.45)
	_update_budget_forecast()
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
	debt = gdp * 0.35
	tax_rate = 0.18
	spending_rate = 0.165
	_update_budget_forecast()
	annual_gdp_growth = 3.2
	stability = 72.0
	_initialize_ai_countries()
	_initialize_diplomacy()
	state_changed.emit()

func save_game() -> bool:
	var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		push_error("Unable to create save directory: %s" % dir_error)
		return false
	var payload := {
		"game_mode": game_mode, "selected_country": selected_country,
		"game_date": game_date, "treasury": treasury, "population": population,
		"gdp": gdp, "inflation": inflation, "unemployment": unemployment,
		"debt": debt, "tax_rate": tax_rate, "spending_rate": spending_rate,
		"monthly_revenue": monthly_revenue, "monthly_expenses": monthly_expenses,
		"monthly_balance": monthly_balance, "annual_gdp_growth": annual_gdp_growth,
		"stability": stability, "ai_countries": ai_countries, "diplomacy_relations": diplomacy_relations
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
	debt = float(data.get("debt", gdp * 0.35))
	tax_rate = float(data.get("tax_rate", 0.18))
	spending_rate = float(data.get("spending_rate", 0.165))
	monthly_revenue = float(data.get("monthly_revenue", 0.0))
	monthly_expenses = float(data.get("monthly_expenses", 0.0))
	monthly_balance = float(data.get("monthly_balance", 0.0))
	annual_gdp_growth = float(data.get("annual_gdp_growth", 3.2))
	stability = float(data.get("stability", 72.0))
	ai_countries.clear()
	for nation in data.get("ai_countries", []):
		if typeof(nation) == TYPE_DICTIONARY:
			ai_countries.append(nation)
	if ai_countries.is_empty():
		_initialize_ai_countries()
	diplomacy_relations = data.get("diplomacy_relations", {})
	if diplomacy_relations.is_empty():
		_initialize_diplomacy()
	_update_budget_forecast()
	state_changed.emit()
	return not selected_country.is_empty()

func formatted_date() -> String:
	return "%02d %s %d" % [int(game_date["day"]), _month_name(int(game_date["month"])), int(game_date["year"])]

func _month_name(month: int) -> String:
	var months := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	return months[clampi(month - 1, 0, 11)]
