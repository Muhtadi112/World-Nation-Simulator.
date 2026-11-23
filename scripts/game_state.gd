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
var military_personnel: int = 350000
var tanks: int = 1200
var aircraft: int = 420
var naval_vessels: int = 180
var military_readiness: float = 68.0
var defense_budget_rate: float = 0.035
var monthly_defense_cost: float = 0.0
var factory_count: int = 0
var industrial_capacity: float = 0.0
var industrial_output: float = 0.0
var industrial_jobs: int = 0
var average_industrial_wage: float = 0.0
var resource_stockpiles: Dictionary = {"food": 0.0, "energy": 0.0, "metals": 0.0, "goods": 0.0}
var market_prices: Dictionary = {"food": 500.0, "energy": 1200.0, "metals": 2500.0, "goods": 4000.0}
var trade_exports: float = 0.0
var trade_imports: float = 0.0
var trade_balance: float = 0.0
var trade_tariff_rate: float = 0.05
var last_trade_report: String = "No trade transactions yet."
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
		_run_monthly_industry()
		_update_market_prices()
		_run_ai_world_simulation()
		_run_diplomacy_monthly_effects()
	state_changed.emit()

func _run_monthly_economy() -> void:
	if gdp <= 0.0:
		return
	monthly_revenue = gdp * tax_rate / 12.0
	monthly_defense_cost = gdp * defense_budget_rate / 12.0
	monthly_expenses = gdp * spending_rate / 12.0 + monthly_defense_cost
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
	military_readiness = clampf(military_readiness + (defense_budget_rate - 0.04) * 5.0 - 0.5, 20.0, 100.0)
	var demand_pressure := (spending_rate - tax_rate) * 0.08
	inflation = clampf(inflation + demand_pressure, 0.0, 40.0)
	unemployment = clampf(unemployment - (annual_gdp_growth - 2.0) * 0.015 + (inflation - 6.0) * 0.008, 1.0, 35.0)
	stability = clampf(stability + (monthly_balance / maxf(gdp / 12.0, 1.0)) * 1.5 - maxf(0.0, inflation - 8.0) * 0.08, 0.0, 100.0)
	annual_gdp_growth = clampf(annual_gdp_growth + (stability - 60.0) * 0.001 - maxf(0.0, inflation - 5.0) * 0.01, -15.0, 20.0)

func _run_monthly_industry() -> void:
	if gdp <= 0.0:
		return
	var capacity_ratio := clampf(industrial_capacity, 0.01, 0.35)
	var food := float(resource_stockpiles.get("food", 0.0))
	var energy := float(resource_stockpiles.get("energy", 0.0))
	var metals := float(resource_stockpiles.get("metals", 0.0))
	var goods := float(resource_stockpiles.get("goods", 0.0))
	var food_production := float(population) * 0.0011
	var food_consumption := float(population) * 0.001
	var energy_production := maxf(1.0, gdp / 1000000000.0 * (0.8 + capacity_ratio * 2.0))
	var energy_consumption := maxf(1.0, gdp / 1000000000.0 * (0.75 + capacity_ratio * 2.8))
	var metals_production := maxf(0.5, gdp / 10000000000.0 * 0.65)
	var metals_consumption := maxf(0.5, gdp / 10000000000.0 * capacity_ratio * 9.0)
	var goods_production := maxf(0.5, gdp / 10000000000.0 * capacity_ratio * 7.0)
	var goods_consumption := maxf(0.5, gdp / 10000000000.0 * 0.45)
	food = maxf(0.0, food + food_production - food_consumption)
	energy = maxf(0.0, energy + energy_production - energy_consumption)
	metals = maxf(0.0, metals + metals_production - metals_consumption)
	goods = maxf(0.0, goods + goods_production - goods_consumption)
	var energy_factor := 1.0 if energy > 0.0 else 0.55
	var metals_factor := 1.0 if metals > 0.0 else 0.65
	var goods_factor := 1.0 if goods > 0.0 else 0.75
	var production_efficiency := (energy_factor + metals_factor + goods_factor) / 3.0
	industrial_output = gdp * capacity_ratio * 0.01 * production_efficiency
	industrial_jobs = maxi(0, int(float(population) * minf(0.035, capacity_ratio * 0.22)))
	average_industrial_wage = industrial_output / maxf(float(industrial_jobs), 1.0)
	resource_stockpiles = {"food": food, "energy": energy, "metals": metals, "goods": goods}
	var industry_growth_bonus := (industrial_output / maxf(gdp, 1.0)) * 0.12
	annual_gdp_growth = clampf(annual_gdp_growth + industry_growth_bonus, -15.0, 20.0)
	var employment_effect := minf(0.08, float(industrial_jobs) / maxf(float(population), 1.0))
	unemployment = clampf(unemployment - employment_effect * 0.08, 1.0, 35.0)

func invest_in_factory() -> bool:
	var cost := maxf(gdp * 0.002, 100000000.0)
	if treasury < cost or factory_count >= 500:
		return false
	treasury -= cost
	factory_count += 1
	industrial_capacity = minf(0.35, industrial_capacity + 0.012)
	industrial_jobs += maxi(1000, int(float(population) * 0.00002))
	average_industrial_wage = maxf(average_industrial_wage, cost * 0.00002)
	_update_budget_forecast()
	state_changed.emit()
	return true

func trade_with_country(country_id: String, commodity: String, direction: String, units: float) -> bool:
	if not diplomacy_relations.has(country_id) or not ["food", "energy", "metals", "goods"].has(commodity):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if not bool(treaty.get("trade_agreement", false)) or bool(treaty.get("at_war", false)) or bool(treaty.get("sanctions", false)):
		return false
	if units <= 0.0 or units > 1000000.0 or not ["export", "import"].has(direction):
		return false
	var nation := get_ai_country(country_id)
	if nation.is_empty():
		return false
	var price := float(market_prices.get(commodity, 1000.0))
	var total_value := price * units
	var partner_stock: Dictionary = nation.get("resource_stockpiles", {})
	var partner_treasury := float(nation.get("treasury", 0.0))
	if direction == "export":
		var available := float(resource_stockpiles.get(commodity, 0.0))
		if available < units or partner_treasury < total_value:
			return false
		resource_stockpiles[commodity] = available - units
		treasury += total_value
		trade_exports += total_value
		trade_balance += total_value
		partner_treasury -= total_value
		partner_stock[commodity] = float(partner_stock.get(commodity, 0.0)) + units
	else:
		var partner_available := float(partner_stock.get(commodity, 0.0))
		var tariff := total_value * trade_tariff_rate
		if partner_available < units or treasury < total_value + tariff:
			return false
		treasury -= total_value + tariff
		resource_stockpiles[commodity] = float(resource_stockpiles.get(commodity, 0.0)) + units
		trade_imports += total_value
		trade_balance -= total_value
		partner_treasury += total_value
		partner_stock[commodity] = partner_available - units
	for index in range(ai_countries.size()):
		if str(ai_countries[index].get("id", "")) == country_id:
			var updated: Dictionary = ai_countries[index]
			updated["treasury"] = partner_treasury
			updated["resource_stockpiles"] = partner_stock
			ai_countries[index] = updated
			break
	last_trade_report = "%s %s units of %s with %s for %s." % [direction.capitalize(), _format_trade_units(units), commodity, str(nation.get("name", country_id)), _format_trade_money(total_value)]
	state_changed.emit()
	return true

func set_trade_tariff(new_rate: float) -> void:
	trade_tariff_rate = clampf(new_rate, 0.0, 0.30)
	state_changed.emit()

func _format_trade_units(value: float) -> String:
	return str(int(value)) if value < 1000.0 else "%.1fK" % (value / 1000.0)

func _format_trade_money(value: float) -> String:
	if value >= 1000000000.0:
		return "$%.2fB" % (value / 1000000000.0)
	if value >= 1000000.0:
		return "$%.2fM" % (value / 1000000.0)
	return "$%.0f" % value

func _update_market_prices() -> void:
	var keys := ["food", "energy", "metals", "goods"]
	var demand_factors := {"food": float(population) * 0.03, "energy": gdp / 1000000000.0 * 2.0, "metals": gdp / 10000000000.0 * 3.0, "goods": gdp / 10000000000.0 * 2.0}
	for key in keys:
		var stock := float(resource_stockpiles.get(key, 0.0))
		var target := maxf(float(demand_factors[key]), 1.0)
		var scarcity := clampf((target - stock) / target, -0.5, 0.5)
		var old_price := float(market_prices.get(key, 1000.0))
		market_prices[key] = clampf(old_price * (1.0 + scarcity * 0.015), old_price * 0.90, old_price * 1.10)

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
			"spending_rate": 0.13 + seed_value * 0.12,
		"resource_stockpiles": {
			"food": float(country.get("population", 1000000)) * 0.025,
			"energy": base_gdp / 1000000000.0 * 1.8,
			"metals": base_gdp / 10000000000.0 * 2.5,
			"goods": base_gdp / 10000000000.0 * 1.7
		}
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

func recruit_personnel() -> bool:
	var recruitment := 10000
	var cost := maxf(gdp * 0.0008, 25000000.0)
	if treasury < cost or military_personnel + recruitment > maxi(100000, int(population * 0.015)):
		return false
	treasury -= cost
	military_personnel += recruitment
	military_readiness = maxf(20.0, military_readiness - 2.0)
	state_changed.emit()
	return true

func procure_equipment() -> bool:
	var cost := maxf(gdp * 0.0012, 50000000.0)
	if treasury < cost:
		return false
	treasury -= cost
	tanks += 80
	aircraft += 24
	naval_vessels += 8
	military_readiness = clampf(military_readiness + 3.0, 0.0, 100.0)
	state_changed.emit()
	return true

func set_defense_budget(new_rate: float) -> void:
	defense_budget_rate = clampf(new_rate, 0.02, 0.12)
	_update_budget_forecast()
	state_changed.emit()

func military_strength() -> float:
	var manpower_score := float(military_personnel) * 0.12
	var equipment_score := float(tanks) * 180.0 + float(aircraft) * 420.0 + float(naval_vessels) * 650.0
	return (manpower_score + equipment_score) * (military_readiness / 100.0)

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
	monthly_expenses = maxf(0.0, gdp) * (spending_rate + defense_budget_rate) / 12.0
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
	factory_count = maxi(1, int(float(population) / 25000000.0))
	industrial_capacity = 0.06 + minf(0.18, float(factory_count) * 0.0015)
	industrial_output = gdp * industrial_capacity * 0.01
	industrial_jobs = maxi(10000, int(float(population) * industrial_capacity * 0.22))
	average_industrial_wage = industrial_output / maxf(float(industrial_jobs), 1.0)
	resource_stockpiles = {"food": float(population) * 0.03, "energy": gdp / 1000000000.0 * 2.0, "metals": gdp / 10000000000.0 * 3.0, "goods": gdp / 10000000000.0 * 2.0}
	market_prices = {"food": 500.0, "energy": 1200.0, "metals": 2500.0, "goods": 4000.0}
	trade_exports = 0.0
	trade_imports = 0.0
	trade_balance = 0.0
	trade_tariff_rate = 0.05
	last_trade_report = "No trade transactions yet."
	military_personnel = maxi(50000, int(float(population) * 0.0012))
	tanks = maxi(100, int(gdp / 1800000000.0))
	aircraft = maxi(40, int(gdp / 5500000000.0))
	naval_vessels = maxi(12, int(gdp / 14000000000.0))
	military_readiness = 68.0
	defense_budget_rate = 0.035
	monthly_defense_cost = gdp * defense_budget_rate / 12.0
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
		"stability": stability, "ai_countries": ai_countries, "diplomacy_relations": diplomacy_relations,
		"military_personnel": military_personnel, "tanks": tanks, "aircraft": aircraft,
		"naval_vessels": naval_vessels, "military_readiness": military_readiness,
		"defense_budget_rate": defense_budget_rate,
		"factory_count": factory_count, "industrial_capacity": industrial_capacity,
		"industrial_output": industrial_output, "industrial_jobs": industrial_jobs,
		"average_industrial_wage": average_industrial_wage, "resource_stockpiles": resource_stockpiles,
		"market_prices": market_prices, "trade_exports": trade_exports,
		"trade_imports": trade_imports, "trade_balance": trade_balance,
		"trade_tariff_rate": trade_tariff_rate, "last_trade_report": last_trade_report
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
	military_personnel = int(data.get("military_personnel", maxi(50000, int(float(population) * 0.0012))))
	tanks = int(data.get("tanks", maxi(100, int(gdp / 1800000000.0))))
	aircraft = int(data.get("aircraft", maxi(40, int(gdp / 5500000000.0))))
	naval_vessels = int(data.get("naval_vessels", maxi(12, int(gdp / 14000000000.0))))
	military_readiness = float(data.get("military_readiness", 68.0))
	defense_budget_rate = float(data.get("defense_budget_rate", 0.035))
	monthly_defense_cost = gdp * defense_budget_rate / 12.0
	factory_count = int(data.get("factory_count", maxi(1, int(float(population) / 25000000.0))))
	industrial_capacity = float(data.get("industrial_capacity", 0.08))
	industrial_output = float(data.get("industrial_output", gdp * industrial_capacity * 0.01))
	industrial_jobs = int(data.get("industrial_jobs", maxi(10000, int(float(population) * industrial_capacity * 0.22))))
	average_industrial_wage = float(data.get("average_industrial_wage", industrial_output / maxf(float(industrial_jobs), 1.0)))
	resource_stockpiles = data.get("resource_stockpiles", {"food": float(population) * 0.03, "energy": gdp / 1000000000.0 * 2.0, "metals": gdp / 10000000000.0 * 3.0, "goods": gdp / 10000000000.0 * 2.0})
	market_prices = data.get("market_prices", {"food": 500.0, "energy": 1200.0, "metals": 2500.0, "goods": 4000.0})
	trade_exports = float(data.get("trade_exports", 0.0))
	trade_imports = float(data.get("trade_imports", 0.0))
	trade_balance = float(data.get("trade_balance", trade_exports - trade_imports))
	trade_tariff_rate = float(data.get("trade_tariff_rate", 0.05))
	last_trade_report = str(data.get("last_trade_report", "No trade transactions yet."))
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
