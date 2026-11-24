extends Node

signal state_changed

const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/autosave.json"
const COUNTRY_DATA_PATH := "res://data/countries_110m.json"


const CITY_DATA_PATH := "res://data/major_cities.json"
var cities: Array[Dictionary] = []
var transport_routes: Array[Dictionary] = []
var selected_city_id: String = ""
var regional_funds: Dictionary = {}
var selected_region_name: String = ""
var companies: Array[Dictionary] = []
var corporate_tax_rate: float = 0.18
var monthly_corporate_tax: float = 0.0
var private_sector_jobs: int = 0
var central_bank_rate: float = 0.045
var reserve_requirement: float = 0.10
var bank_deposits: float = 0.0
var bank_reserves: float = 0.0
var bank_loan_book: float = 0.0
var household_credit: float = 0.0
var nonperforming_loans: float = 0.0
var monthly_bank_interest: float = 0.0
var company_loans: Array[Dictionary] = []
var labor_force: int = 0
var employed_citizens: int = 0
var unemployed_citizens: int = 0
var average_monthly_income: float = 0.0
var poverty_rate: float = 18.0
var middle_class_share: float = 65.0
var wealthy_share: float = 17.0
var income_inequality: float = 0.36
var household_consumption: float = 0.0
var social_welfare_rate: float = 0.02
var monthly_welfare_cost: float = 0.0
var social_mobility: float = 50.0
var healthcare_budget_rate: float = 0.035
var education_budget_rate: float = 0.04
var monthly_healthcare_cost: float = 0.0
var monthly_education_cost: float = 0.0
var hospital_capacity: float = 58.0
var healthcare_access: float = 62.0
var life_expectancy: float = 72.0
var disease_burden: float = 32.0
var health_workers: int = 0
var school_enrollment: float = 78.0
var adult_literacy: float = 86.0
var education_quality: float = 55.0
var skilled_workforce_share: float = 38.0
var teachers: int = 0
var public_services_report: String = "National health and education services established."
var infrastructure: Dictionary = {"roads": 12, "power": 10, "ports": 4, "airports": 3, "hospitals": 8, "schools": 10, "housing": 12}
var city_catalog: Array[Dictionary] = []
var environment_budget_rate: float = 0.012
var monthly_environment_cost: float = 0.0
var carbon_emissions: float = 0.0
var air_pollution: float = 35.0
var water_pollution: float = 28.0
var forest_cover: float = 32.0
var climate_risk: float = 24.0
var biodiversity: float = 65.0
var environmental_quality: float = 62.0
var renewable_energy_share: float = 18.0
var disaster_resilience: float = 42.0
var disaster_cooldown: int = 0
var disaster_history: Array[Dictionary] = []
var last_disaster_report: String = "No major natural disasters recorded."

var research_budget_rate: float = 0.015
var research_labs: int = 1
var scientists: int = 1200
var research_points: float = 0.0
var active_research_id: String = ""
var technology_tree: Array[Dictionary] = []
var completed_technologies: Array[String] = []
var research_report: String = "No technology projects completed yet."
var space_agency_level: int = 1
var space_centers: int = 0
var operational_satellites: int = 0
var space_program_budget_rate: float = 0.004
var monthly_space_cost: float = 0.0
var active_space_mission: Dictionary = {}
var space_mission_log: Array[Dictionary] = []
var space_report: String = "No national space missions have been launched."
var intelligence_agency_level: int = 1
var intelligence_budget_rate: float = 0.006
var intelligence_points: float = 0.0
var cyber_defense_rating: float = 35.0
var counterintelligence_rating: float = 30.0
var national_threat_level: float = 20.0
var monthly_intelligence_cost: float = 0.0
var active_intelligence_operation: Dictionary = {}
var intelligence_operation_log: Array[Dictionary] = []
var intelligence_report: String = "No intelligence operations have been conducted."
var immigration_openness: float = 50.0
var refugee_acceptance_rate: float = 15.0
var citizenship_access: float = 50.0
var border_security: float = 55.0
var integration_capacity: float = 45.0
var immigrant_population: int = 0
var foreign_born_share: float = 0.0
var monthly_net_migration: int = 0
var monthly_immigration_cost: float = 0.0
var immigration_report: String = "No migration report available."
var citizenship_applications: int = 0
var citizenship_granted: int = 0
var passport_access: float = 60.0
var passports_issued: int = 0
var media_freedom: float = 62.0
var media_trust: float = 54.0
var media_reach: float = 38.0
var media_literacy: float = 42.0
var misinformation_pressure: float = 24.0
var public_polarization: float = 32.0
var press_safety: float = 58.0
var media_regulation: float = 35.0
var media_budget_rate: float = 0.003
var monthly_media_cost: float = 0.0
var tv_stations: int = 2
var newspaper_groups: int = 3
var digital_networks: int = 1
var media_report: String = "National media institutions established."
var media_campaign_cooldown: int = 0

var government_type: String = "Constitutional democracy"
var government_approval: float = 58.0
var governing_party_id: String = ""
var coalition_party_ids: Array[String] = []
var parliament_seats: int = 300
var months_until_election: int = 48
var political_parties: Array[Dictionary] = []
var cabinet: Array[Dictionary] = []
var enacted_laws: Array[String] = []
var last_election_report: String = "No election has been held yet."


func load_city_catalog() -> void:
	city_catalog.clear()
	if not FileAccess.file_exists(CITY_DATA_PATH):
		push_warning("Major city catalogue is missing; capital-only fallback will be used.")
		return
	var file := FileAccess.open(CITY_DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_ARRAY:
		for row in parsed:
			if typeof(row) == TYPE_DICTIONARY:
				city_catalog.append(row)

func _initialize_cities(country: Dictionary) -> void:
	if city_catalog.is_empty():
		load_city_catalog()
	cities.clear()
	regional_funds.clear()
	selected_region_name = ""
	var country_id := str(country.get("id", ""))
	var matching: Array[Dictionary] = []
	var total_catalog_population := 0.0
	for entry in city_catalog:
		if str(entry.get("country", "")) == country_id:
			matching.append(entry)
			total_catalog_population += float(entry.get("population", 0))
	var national_population := maxf(float(country.get("population", population)), 1.0)
	var national_gdp := maxf(float(country.get("gdp", gdp)), 1.0)
	var allocated_population := minf(national_population * 0.60, total_catalog_population)
	var allocated_gdp := national_gdp * 0.70
	if matching.is_empty():
		var capital_name := str(country.get("capital", "Capital"))
		matching.append({"id": country_id + "_CAPITAL", "name": capital_name, "region": str(country.get("region", "National Capital District")), "population": maxf(national_population * 0.12, 10000.0), "lat": 0.0, "lon": 0.0, "tier": 1})
		total_catalog_population = float(matching[0].get("population", 10000))
		allocated_population = minf(national_population * 0.12, total_catalog_population)
		allocated_gdp = national_gdp * 0.22
	for entry in matching:
		var source_population := maxf(float(entry.get("population", 10000)), 1.0)
		var share := source_population / maxf(total_catalog_population, 1.0)
		var city_population := maxi(10000, int(allocated_population * share))
		var city_gdp := allocated_gdp * share
		cities.append({
			"id": str(entry.get("id", country_id + "_CITY")),
			"name": str(entry.get("name", "Unnamed City")),
			"country": country_id,
			"region": str(entry.get("region", "Unassigned Region")),
			"population": city_population,
			"gdp": city_gdp,
			"development": int(entry.get("tier", 3)),
			"development_index": 25.0 + float(entry.get("tier", 3)) * 12.0,
			"employment": 94.0,
			"quality_of_life": 58.0 + float(entry.get("tier", 3)) * 2.0,
			"lat": float(entry.get("lat", 0.0)),
			"lon": float(entry.get("lon", 0.0)),
			"roads": 2, "power": 2, "housing": 2, "health": 1, "education": 1,
			"zones": {"residential": 2, "industrial": 1, "commercial": 1, "government": 1},
			"buildings": [], "land_value": maxf(100.0, city_gdp / maxf(float(city_population), 1.0) * 0.12),
			"rail_station": 0, "airport": 0, "seaport": 0
		})
	if not cities.is_empty():
		selected_city_id = str(cities[0].get("id", ""))

func get_regions() -> Array[Dictionary]:
	var grouped: Dictionary = {}
	for city in cities:
		var region_name := str(city.get("region", "Unassigned Region"))
		if not grouped.has(region_name):
			grouped[region_name] = {
				"name": region_name, "city_count": 0, "population": 0,
				"gdp": 0.0, "quality_of_life_total": 0.0,
				"employment_total": 0.0, "cities": []
			}
		var region: Dictionary = grouped[region_name]
		region["city_count"] = int(region.get("city_count", 0)) + 1
		region["population"] = int(region.get("population", 0)) + int(city.get("population", 0))
		region["gdp"] = float(region.get("gdp", 0.0)) + float(city.get("gdp", 0.0))
		region["quality_of_life_total"] = float(region.get("quality_of_life_total", 0.0)) + float(city.get("quality_of_life", 0.0))
		region["employment_total"] = float(region.get("employment_total", 0.0)) + float(city.get("employment", 0.0))
		var member_cities: Array = region.get("cities", [])
		member_cities.append(str(city.get("name", "City")))
		region["cities"] = member_cities
		grouped[region_name] = region
	var result: Array[Dictionary] = []
	for key in grouped.keys():
		var region: Dictionary = grouped[key]
		var count := maxi(1, int(region.get("city_count", 1)))
		region["average_quality_of_life"] = float(region.get("quality_of_life_total", 0.0)) / count
		region["average_employment"] = float(region.get("employment_total", 0.0)) / count
		region.erase("quality_of_life_total")
		region.erase("employment_total")
		result.append(region)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("population", 0)) > int(b.get("population", 0))
	)
	return result

func _city_distance_km(city_a: Dictionary, city_b: Dictionary) -> float:
	var lat_a := deg_to_rad(float(city_a.get("lat", 0.0)))
	var lat_b := deg_to_rad(float(city_b.get("lat", 0.0)))
	var delta_lat := lat_b - lat_a
	var delta_lon := deg_to_rad(float(city_b.get("lon", 0.0)) - float(city_a.get("lon", 0.0)))
	var haversine := pow(sin(delta_lat * 0.5), 2.0) + cos(lat_a) * cos(lat_b) * pow(sin(delta_lon * 0.5), 2.0)
	return 6371.0 * 2.0 * asin(sqrt(clampf(haversine, 0.0, 1.0)))

func transport_facility_cost(city_id: String, facility: String) -> float:
	if not ["rail_station", "airport", "seaport"].has(facility):
		return -1.0
	var city := get_city(city_id)
	if city.is_empty():
		return -1.0
	var level := int(city.get(facility, 0))
	if level >= 10:
		return -1.0
	var multiplier := {"rail_station": 0.00045, "airport": 0.0009, "seaport": 0.0007}
	return maxf(float(city.get("gdp", 0.0)) * float(multiplier[facility]) * float(level + 1), 15000000.0)

func upgrade_transport_facility(city_id: String, facility: String) -> bool:
	var cost := transport_facility_cost(city_id, facility)
	if cost < 0.0 or treasury < cost:
		return false
	for index in range(cities.size()):
		if str(cities[index].get("id", "")) == city_id:
			cities[index][facility] = int(cities[index].get(facility, 0)) + 1
			treasury -= cost
			state_changed.emit()
			return true
	return false

func transport_route_cost(from_city_id: String, to_city_id: String, mode: String = "road") -> float:
	if from_city_id == to_city_id or not ["road", "rail", "air", "sea"].has(mode):
		return -1.0
	var from_city := get_city(from_city_id)
	var to_city := get_city(to_city_id)
	if from_city.is_empty() or to_city.is_empty():
		return -1.0
	for route in transport_routes:
		if str(route.get("mode", "road")) == mode and ((str(route.get("from", "")) == from_city_id and str(route.get("to", "")) == to_city_id) or (str(route.get("from", "")) == to_city_id and str(route.get("to", "")) == from_city_id)):
			return -1.0
	var required_facility := {"rail": "rail_station", "air": "airport", "sea": "seaport"}.get(mode, "")
	if not required_facility.is_empty() and (int(from_city.get(required_facility, 0)) < 1 or int(to_city.get(required_facility, 0)) < 1):
		return -1.0
	var mode_multiplier := {"road": 180000.0, "rail": 320000.0, "air": 520000.0, "sea": 260000.0}
	return maxf(_city_distance_km(from_city, to_city) * float(mode_multiplier[mode]), 10000000.0)

func build_transport_route(from_city_id: String, to_city_id: String, mode: String = "road") -> bool:
	if transport_routes.size() >= 500:
		return false
	var cost := transport_route_cost(from_city_id, to_city_id, mode)
	if cost < 0.0 or treasury < cost:
		return false
	var from_city := get_city(from_city_id)
	var to_city := get_city(to_city_id)
	transport_routes.append({
		"id": from_city_id + "__" + mode + "__" + to_city_id,
		"from": from_city_id, "to": to_city_id, "mode": mode,
		"from_name": str(from_city.get("name", "City")),
		"to_name": str(to_city.get("name", "City")),
		"distance_km": _city_distance_km(from_city, to_city),
		"road_level": 1, "traffic": 0.0, "congestion": 0.0,
		"capacity": 80000.0 if mode == "road" else (120000.0 if mode == "rail" else 45000.0), "status": "Operational"
	})
	treasury -= cost
	state_changed.emit()
	return true

func _run_monthly_transport_simulation() -> void:
	var city_route_counts: Dictionary = {}
	var city_transport_scores: Dictionary = {}
	for index in range(transport_routes.size()):
		var route: Dictionary = transport_routes[index]
		var from_city := get_city(str(route.get("from", "")))
		var to_city := get_city(str(route.get("to", "")))
		if from_city.is_empty() or to_city.is_empty():
			continue
		var mode := str(route.get("mode", "road"))
		var road_level := maxi(1, int(route.get("road_level", 1)))
		var mode_factor := {"road": 1.0, "rail": 0.55, "air": 0.18, "sea": 0.30}.get(mode, 1.0)
		var traffic := float(int(from_city.get("population", 0)) + int(to_city.get("population", 0))) * 0.025 * float(mode_factor)
		var base_capacity := {"road": 80000.0, "rail": 150000.0, "air": 55000.0, "sea": 110000.0}.get(mode, 80000.0)
		var capacity := float(base_capacity) * float(road_level)
		var congestion := clampf((traffic / maxf(capacity, 1.0) - 0.65) * 100.0, 0.0, 100.0)
		route["traffic"] = traffic
		route["capacity"] = capacity
		route["congestion"] = congestion
		transport_routes[index] = route
		for city_id in [str(route.get("from", "")), str(route.get("to", ""))]:
			city_route_counts[city_id] = int(city_route_counts.get(city_id, 0)) + 1
			city_transport_scores[city_id] = float(city_transport_scores.get(city_id, 0.0)) + float(road_level) * (1.0 - congestion / 150.0)
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		var city_id := str(city.get("id", ""))
		var count := int(city_route_counts.get(city_id, 0))
		var score := float(city_transport_scores.get(city_id, 0.0)) / maxf(float(count), 1.0)
		city["transport_access"] = clampf(20.0 + score * 16.0 + float(count) * 3.0, 20.0, 100.0)
		cities[index] = city

func get_city(city_id: String) -> Dictionary:
	for city in cities:
		if str(city.get("id", "")) == city_id:
			return city.duplicate(true)
	return {}

func city_upgrade_cost(city_id: String, category: String) -> float:
	var city := get_city(city_id)
	if city.is_empty() or not [ "roads", "power", "housing", "health", "education" ].has(category):
		return -1.0
	var level := int(city.get(category, 1))
	return maxf(float(city.get("gdp", 0.0)) * (0.00008 + float(level) * 0.000025), 5000000.0)

func upgrade_city(city_id: String, category: String) -> bool:
	var cost := city_upgrade_cost(city_id, category)
	if cost < 0.0 or treasury < cost:
		return false
	for index in range(cities.size()):
		if str(cities[index].get("id", "")) == city_id:
			var level := int(cities[index].get(category, 1))
			if level >= 30:
				return false
			treasury -= cost
			cities[index][category] = level + 1
			cities[index]["development_index"] = minf(100.0, float(cities[index].get("development_index", 25.0)) + 1.8)
			cities[index]["quality_of_life"] = minf(100.0, float(cities[index].get("quality_of_life", 50.0)) + 0.6)
			selected_city_id = city_id
			state_changed.emit()
			return true
	return false

func _initialize_companies() -> void:
	companies.clear()
	private_sector_jobs = 0
	for city in cities:
		var city_id := str(city.get("id", ""))
		var city_gdp := maxf(float(city.get("gdp", 100000000.0)), 100000000.0)
		var city_name := str(city.get("name", "City"))
		var base_jobs := maxi(20, int(float(city.get("population", 10000)) * 0.012))
		var sectors := ["Manufacturing", "Retail & services"]
		for sector_index in range(sectors.size()):
			var jobs := maxi(10, int(float(base_jobs) * (0.42 if sector_index == 0 else 0.58)))
			var monthly_revenue_value := city_gdp / 12.0 * (0.012 if sector_index == 0 else 0.016)
			var wage := maxf(250.0, city_gdp / maxf(float(city.get("population", 1)), 1.0) * 0.018)
			companies.append({
				"id": city_id + "_CORP_" + str(sector_index + 1),
				"name": city_name + (" Industrial Works" if sector_index == 0 else " Commerce Group"),
				"city_id": city_id, "sector": sectors[sector_index],
				"employees": jobs, "average_wage": wage,
				"revenue": monthly_revenue_value,
				"expenses": monthly_revenue_value * 0.78,
				"profit": monthly_revenue_value * 0.22,
				"cash_reserves": monthly_revenue_value * 2.0,
				"tax_paid": monthly_revenue_value * 0.22 * corporate_tax_rate,
				"operating_months": 0, "status": "Operating"
			})
			private_sector_jobs += jobs
	monthly_corporate_tax = 0.0

func create_company(city_id: String, sector: String) -> bool:
	var target_city := get_city(city_id)
	if target_city.is_empty() or companies.size() >= 5000:
		return false
	var allowed_sectors := ["Manufacturing", "Retail & services", "Technology", "Construction", "Logistics", "Energy"]
	if not allowed_sectors.has(sector):
		return false
	var cost := maxf(float(target_city.get("gdp", 0.0)) * 0.0015, 15000000.0)
	if treasury < cost:
		return false
	treasury -= cost
	var city_name := str(target_city.get("name", "City"))
	var employees := maxi(12, int(float(target_city.get("population", 10000)) * 0.0008))
	var revenue := maxf(float(target_city.get("gdp", 0.0)) / 12.0 * 0.004, 250000.0)
	var company_name := city_name + " " + sector + " " + str(companies.size() + 1)
	companies.append({
		"id": city_id + "_NEW_" + str(Time.get_ticks_msec()),
		"name": company_name, "city_id": city_id, "sector": sector,
		"employees": employees, "average_wage": maxf(250.0, float(target_city.get("gdp", 0.0)) / maxf(float(target_city.get("population", 1)), 1.0) * 0.016),
		"revenue": revenue, "expenses": revenue * 0.86,
		"profit": revenue * 0.14, "cash_reserves": cost * 0.35,
		"tax_paid": revenue * 0.14 * corporate_tax_rate,
		"operating_months": 0, "status": "Operating"
	})
	private_sector_jobs += employees
	state_changed.emit()
	return true

func set_corporate_tax(new_rate: float) -> void:
	corporate_tax_rate = clampf(new_rate, 0.05, 0.35)
	state_changed.emit()

func _run_monthly_company_simulation() -> void:
	monthly_corporate_tax = 0.0
	private_sector_jobs = 0
	var city_lookup: Dictionary = {}
	for city in cities:
		city_lookup[str(city.get("id", ""))] = city
	for index in range(companies.size()):
		var company: Dictionary = companies[index]
		if str(company.get("status", "Operating")) == "Bankrupt":
			continue
		var city: Dictionary = city_lookup.get(str(company.get("city_id", "")), {})
		if city.is_empty():
			continue
		var revenue := maxf(0.0, float(company.get("revenue", 0.0)) * (1.0 + annual_gdp_growth / 1200.0 + (float(city.get("quality_of_life", 50.0)) - 50.0) * 0.00015))
		var employees := maxi(0, int(company.get("employees", 0)))
		var wage := maxf(0.0, float(company.get("average_wage", 0.0)))
		var payroll := float(employees) * wage
		var operating_cost := revenue * 0.48 + payroll
		var profit := revenue - operating_cost
		var reserves := float(company.get("cash_reserves", 0.0)) + profit
		var status := "Operating"
		if profit < 0.0:
			reserves += profit
			if reserves < -revenue * 1.5:
				status = "Bankrupt"
				employees = 0
		else:
			var hiring_capacity := int(maxf(0.0, profit / maxf(wage * 12.0, 1.0)) * 0.02)
			employees += mini(hiring_capacity, maxi(1, int(float(employees) * 0.015)))
		var tax := maxf(0.0, profit) * corporate_tax_rate
		monthly_corporate_tax += tax
		company["revenue"] = revenue
		company["expenses"] = operating_cost
		company["profit"] = profit
		company["cash_reserves"] = maxf(0.0, reserves)
		company["tax_paid"] = tax
		company["employees"] = employees
		company["operating_months"] = int(company.get("operating_months", 0)) + 1
		company["status"] = status
		companies[index] = company
		private_sector_jobs += employees
	var total_profit := 0.0
	for company in companies:
		if str(company.get("status", "")) == "Operating":
			total_profit += maxf(0.0, float(company.get("profit", 0.0)))
	treasury += monthly_corporate_tax
	gdp += total_profit * 0.08


func _initialize_banking() -> void:
	central_bank_rate = 0.045
	reserve_requirement = 0.10
	bank_deposits = maxf(gdp * 0.42, 100000000.0)
	bank_reserves = bank_deposits * reserve_requirement
	bank_loan_book = 0.0
	household_credit = population * maxf(gdp / maxf(float(population), 1.0) * 0.12, 100.0)
	nonperforming_loans = 0.0
	monthly_bank_interest = 0.0
	company_loans.clear()

func banking_available_credit() -> float:
	return maxf(0.0, bank_deposits - bank_deposits * reserve_requirement + bank_reserves - bank_loan_book)

func set_central_bank_rate(new_rate: float) -> void:
	central_bank_rate = clampf(new_rate, 0.005, 0.20)
	state_changed.emit()

func set_reserve_requirement(new_ratio: float) -> void:
	reserve_requirement = clampf(new_ratio, 0.05, 0.30)
	bank_reserves = maxf(bank_reserves, bank_deposits * reserve_requirement)
	state_changed.emit()

func issue_company_loan(company_id: String, principal: float) -> bool:
	if principal <= 0.0 or company_loans.size() >= 2000:
		return false
	var company_index := -1
	for index in range(companies.size()):
		if str(companies[index].get("id", "")) == company_id and str(companies[index].get("status", "Operating")) == "Operating":
			company_index = index
			break
	if company_index < 0:
		return false
	var company: Dictionary = companies[company_index]
	var revenue := maxf(float(company.get("revenue", 0.0)), 1.0)
	var existing_debt := float(company.get("loan_balance", 0.0))
	var loan_limit := maxf(revenue * 4.0 - existing_debt, 0.0)
	var amount := minf(principal, loan_limit)
	if amount < 1000000.0 or amount > banking_available_credit():
		return false
	var rate := central_bank_rate + 0.04
	company["loan_balance"] = existing_debt + amount
	company["cash_reserves"] = float(company.get("cash_reserves", 0.0)) + amount
	companies[company_index] = company
	company_loans.append({
		"id": company_id + "_LOAN_" + str(Time.get_ticks_msec()),
		"company_id": company_id, "company_name": str(company.get("name", "Company")),
		"principal": amount, "balance": amount, "annual_rate": rate,
		"monthly_payment": amount * 0.04 + amount * rate / 12.0,
		"missed_payments": 0, "status": "Performing"
	})
	bank_loan_book += amount
	bank_reserves = maxf(0.0, bank_reserves - amount * 0.15)
	state_changed.emit()
	return true

func _run_monthly_banking_simulation() -> void:
	monthly_bank_interest = 0.0
	var total_npl := 0.0
	for index in range(company_loans.size()):
		var loan: Dictionary = company_loans[index]
		if str(loan.get("status", "Performing")) == "Repaid":
			continue
		var balance := maxf(0.0, float(loan.get("balance", 0.0)))
		var annual_rate := maxf(0.0, central_bank_rate + 0.04)
		var interest := balance * annual_rate / 12.0
		var principal_payment := minf(balance, float(loan.get("principal", balance)) * 0.04)
		var payment := interest + principal_payment
		var paid := false
		for company_index in range(companies.size()):
			if str(companies[company_index].get("id", "")) == str(loan.get("company_id", "")):
				var company: Dictionary = companies[company_index]
				var cash := float(company.get("cash_reserves", 0.0))
				if cash >= payment:
					company["cash_reserves"] = cash - payment
					company["loan_balance"] = maxf(0.0, float(company.get("loan_balance", balance)) - principal_payment)
					companies[company_index] = company
					paid = true
				break
		if paid:
			balance = maxf(0.0, balance - principal_payment)
			monthly_bank_interest += interest
			bank_reserves += payment * 0.12
			loan["missed_payments"] = 0
			if balance <= 1.0:
				balance = 0.0
				loan["status"] = "Repaid"
		else:
			loan["missed_payments"] = int(loan.get("missed_payments", 0)) + 1
			if int(loan.get("missed_payments", 0)) >= 3:
				loan["status"] = "Non-performing"
		loan["balance"] = balance
		loan["annual_rate"] = annual_rate
		loan["monthly_payment"] = payment
		company_loans[index] = loan
	bank_loan_book = 0.0
	for loan in company_loans:
		if str(loan.get("status", "")) != "Repaid":
			bank_loan_book += float(loan.get("balance", 0.0))
		if str(loan.get("status", "")) == "Non-performing":
			total_npl += float(loan.get("balance", 0.0))
	nonperforming_loans = total_npl
	var policy_gap := central_bank_rate - 0.045
	inflation = clampf(inflation - policy_gap * 0.18, 0.0, 40.0)
	annual_gdp_growth = clampf(annual_gdp_growth - policy_gap * 0.12, -5.0, 15.0)
	bank_deposits = maxf(bank_deposits * (1.0 + annual_gdp_growth / 1200.0), bank_loan_book * 1.05)
	bank_reserves = minf(bank_deposits, maxf(bank_reserves, bank_deposits * reserve_requirement))
	household_credit = maxf(0.0, household_credit * (1.0 + annual_gdp_growth / 1800.0 + (0.045 - central_bank_rate) * 0.025))

func _run_monthly_social_simulation() -> void:
	if population <= 0 or gdp <= 0.0:
		return
	labor_force = maxi(1, int(float(population) * 0.62))
	var unemployment_rate := clampf(unemployment, 1.0, 35.0)
	unemployed_citizens = int(float(labor_force) * unemployment_rate / 100.0)
	employed_citizens = maxi(0, labor_force - unemployed_citizens)
	average_monthly_income = gdp / maxf(float(population), 1.0) * 0.62 / 12.0
	household_consumption = gdp * 0.56 / 12.0
	var city_satisfaction := 58.0
	if not cities.is_empty():
		city_satisfaction = 0.0
		for city in cities:
			city_satisfaction += float(city.get("resident_satisfaction", city.get("quality_of_life", 58.0)))
		city_satisfaction /= float(cities.size())
	var employment_pressure := maxf(0.0, unemployment_rate - 5.0)
	var income_pressure := clampf(average_monthly_income / 900.0, 0.0, 1.5)
	poverty_rate = clampf(18.0 + employment_pressure * 1.15 + maxf(0.0, inflation - 4.0) * 0.28 - social_welfare_rate * 115.0 - (income_pressure - 0.5) * 5.0 - (city_satisfaction - 55.0) * 0.08, 2.0, 65.0)
	wealthy_share = clampf(10.0 + income_inequality * 12.0 + maxf(0.0, annual_gdp_growth) * 0.15, 8.0, 28.0)
	middle_class_share = clampf(100.0 - poverty_rate - wealthy_share, 15.0, 85.0)
	poverty_rate = 100.0 - middle_class_share - wealthy_share
	income_inequality = clampf(income_inequality + (unemployment_rate - 5.0) * 0.00015 - social_welfare_rate * 0.001 + (annual_gdp_growth - 2.0) * 0.00008, 0.25, 0.65)
	social_mobility = clampf(45.0 + city_satisfaction * 0.25 + float(infrastructure.get("schools", 0)) * 0.45 + float(infrastructure.get("housing", 0)) * 0.25 - income_inequality * 22.0, 0.0, 100.0)
	monthly_welfare_cost = gdp * social_welfare_rate / 12.0

func set_social_welfare_rate(new_rate: float) -> void:
	social_welfare_rate = clampf(new_rate, 0.0, 0.08)
	monthly_welfare_cost = gdp * social_welfare_rate / 12.0
	_update_budget_forecast()
	state_changed.emit()

func _run_monthly_city_simulation() -> void:
	if cities.is_empty():
		return
	var satisfaction_total := 0.0
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		if not city.has("zones"):
			city["zones"] = {"residential": 2, "industrial": 1, "commercial": 1, "government": 1}
		if not city.has("buildings"):
			city["buildings"] = []
		var buildings: Array = city.get("buildings", [])
		var building_output := 0.0
		var building_jobs := 0
		for building in buildings:
			if typeof(building) == TYPE_DICTIONARY:
				building_output += float(building.get("monthly_output", 0.0))
				building_jobs += int(building.get("jobs", 0))
		city["building_jobs"] = building_jobs
		city["building_output"] = building_output
		var zones: Dictionary = city.get("zones", {})
		var population_now := maxf(float(city.get("population", 10000)), 1.0)
		var housing_level := float(city.get("housing", 1))
		var residential_zones := float(zones.get("residential", 1))
		var housing_capacity_ratio := 0.90 + housing_level * 0.045 + residential_zones * 0.025
		var housing_pressure := population_now / maxf(population_now * housing_capacity_ratio, 1.0) * 100.0
		var food_need := population_now * 0.025
		var food_security := clampf(float(resource_stockpiles.get("food", 0.0)) / maxf(food_need, 1.0) * 100.0, 0.0, 100.0)
		var health_access := clampf(42.0 + float(city.get("health", 1)) * 7.0, 0.0, 100.0)
		var education_access := clampf(38.0 + float(city.get("education", 1)) * 8.0, 0.0, 100.0)
		var housing_affordability := clampf(112.0 - maxf(housing_pressure - 90.0, 0.0) * 1.25 - maxf(float(city.get("land_value", 100.0)) / maxf(float(city.get("gdp", 1.0)) / population_now * 0.12, 1.0) - 1.0, 0.0) * 8.0, 10.0, 100.0)
		var zones_bonus := (float(zones.get("residential", 1)) + float(zones.get("industrial", 1)) + float(zones.get("commercial", 1))) * 0.00008
		city["land_value"] = maxf(10.0, float(city.get("land_value", 100.0)) * (1.0 + 0.001 + float(city.get("development_index", 25.0)) * 0.00001))
		var roads := float(city.get("roads", 1))
		var education := float(city.get("education", 1))
		var health := float(city.get("health", 1))
		var housing := float(city.get("housing", 1))
		var transport_effect := float(city.get("transport_access", 20.0)) / 100.0 * 0.00025
		var infrastructure_score := (roads + education + health + housing + float(city.get("power", 1))) / 150.0 + transport_effect
		var satisfaction := clampf(float(city.get("quality_of_life", 58.0)) * 0.25 + food_security * 0.20 + housing_affordability * 0.20 + health_access * 0.18 + education_access * 0.17, 0.0, 100.0)
		var natural_growth := clampf(0.00035 + health_access * 0.000002 + education_access * 0.000001 - maxf(0.0, 100.0 - food_security) * 0.000004, -0.0002, 0.0008)
		var births := int(population_now * maxf(natural_growth + 0.00035, 0.0001))
		var deaths := int(population_now * 0.00035)
		city["housing_capacity"] = int(population_now * housing_capacity_ratio)
		city["housing_pressure"] = housing_pressure
		city["food_security"] = food_security
		city["health_access"] = health_access
		city["education_access"] = education_access
		city["housing_affordability"] = housing_affordability
		city["resident_satisfaction"] = satisfaction
		city["births_monthly"] = births
		city["deaths_monthly"] = deaths
		city["monthly_migration"] = 0
		city["employment"] = clampf(float(city.get("employment", 94.0)) + 0.01 + education * 0.0008 + float(building_jobs) / maxf(population_now, 1.0) * 0.02, 70.0, 99.5)
		city["gdp"] = float(city.get("gdp", 0.0)) * (1.0 + annual_gdp_growth / 1200.0 + infrastructure_score * 0.001 + zones_bonus) + building_output * 0.12
		city["development_index"] = minf(100.0, float(city.get("development_index", 25.0)) + infrastructure_score * 0.035)
		city["quality_of_life"] = clampf(float(city.get("quality_of_life", 58.0)) + (health + housing) * 0.003 + (satisfaction - 50.0) * 0.002 - maxf(inflation - 4.0, 0.0) * 0.01, 10.0, 100.0)
		cities[index] = city
		satisfaction_total += satisfaction
	var average_satisfaction := satisfaction_total / float(cities.size())
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		var population_now := maxf(float(city.get("population", 10000)), 1.0)
		var satisfaction_gap := float(city.get("resident_satisfaction", average_satisfaction)) - average_satisfaction
		var migration := int(clampf(satisfaction_gap * population_now * 0.00003, -population_now * 0.001, population_now * 0.001))
		var births := int(city.get("births_monthly", 0))
		var deaths := int(city.get("deaths_monthly", 0))
		city["monthly_migration"] = migration
		city["population"] = maxi(10000, int(population_now) + births - deaths + migration)
		cities[index] = city


func city_zone_cost(city_id: String, zone_type: String) -> float:
	var allowed := ["residential", "industrial", "commercial", "government"]
	if not allowed.has(zone_type):
		return -1.0
	var city := get_city(city_id)
	if city.is_empty():
		return -1.0
	var zones: Dictionary = city.get("zones", {})
	var level := int(zones.get(zone_type, 1))
	return maxf(float(city.get("gdp", 0.0)) * 0.00012 * float(level + 1), 8000000.0)

func develop_city_zone(city_id: String, zone_type: String) -> bool:
	var cost := city_zone_cost(city_id, zone_type)
	if cost < 0.0 or treasury < cost:
		return false
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		if str(city.get("id", "")) != city_id:
			continue
		var zones: Dictionary = city.get("zones", {"residential": 2, "industrial": 1, "commercial": 1, "government": 1})
		var level := int(zones.get(zone_type, 1))
		if level >= 20:
			return false
		zones[zone_type] = level + 1
		city["zones"] = zones
		city["development_index"] = minf(100.0, float(city.get("development_index", 25.0)) + 0.8)
		city["land_value"] = float(city.get("land_value", 100.0)) * 1.025
		cities[index] = city
		treasury -= cost
		state_changed.emit()
		return true
	return false

func city_building_cost(city_id: String, building_type: String) -> float:
	var multipliers := {"factory": 0.0018, "mall": 0.0012, "apartments": 0.0010, "hospital": 0.0015, "university": 0.0014, "power_plant": 0.0020}
	if not multipliers.has(building_type):
		return -1.0
	var city := get_city(city_id)
	if city.is_empty():
		return -1.0
	return maxf(float(city.get("gdp", 0.0)) * float(multipliers[building_type]), 12000000.0)

func build_city_building(city_id: String, building_type: String) -> bool:
	var cost := city_building_cost(city_id, building_type)
	if cost < 0.0 or treasury < cost:
		return false
	var definitions := {
		"factory": {"name": "Industrial Factory", "jobs": 850, "output": 0.10},
		"mall": {"name": "Shopping Mall", "jobs": 420, "output": 0.075},
		"apartments": {"name": "Residential Complex", "jobs": 90, "output": 0.025},
		"hospital": {"name": "Public Hospital", "jobs": 260, "output": 0.035},
		"university": {"name": "University Campus", "jobs": 310, "output": 0.045},
		"power_plant": {"name": "Power Plant", "jobs": 180, "output": 0.06}
	}
	if not definitions.has(building_type):
		return false
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		if str(city.get("id", "")) != city_id:
			continue
		var buildings: Array = city.get("buildings", [])
		if buildings.size() >= 50:
			return false
		var definition: Dictionary = definitions[building_type]
		buildings.append({
			"id": city_id + "_" + building_type.to_upper() + "_" + str(buildings.size() + 1),
			"type": building_type, "name": definition["name"], "jobs": int(definition["jobs"]),
			"monthly_output": cost * float(definition["output"]) / 12.0,
			"construction_cost": cost
		})
		city["buildings"] = buildings
		if building_type == "hospital":
			city["quality_of_life"] = minf(100.0, float(city.get("quality_of_life", 58.0)) + 1.5)
		elif building_type == "university":
			city["development_index"] = minf(100.0, float(city.get("development_index", 25.0)) + 1.8)
		elif building_type == "power_plant":
			city["power"] = mini(30, int(city.get("power", 1)) + 1)
		elif building_type == "apartments":
			city["housing"] = mini(30, int(city.get("housing", 1)) + 1)
		cities[index] = city
		treasury -= cost
		state_changed.emit()
		return true
	return false


func get_region_detail(region_name: String) -> Dictionary:
	for region in get_regions():
		if str(region.get("name", "")) == region_name:
			var detail: Dictionary = region.duplicate(true)
			detail["funds"] = float(regional_funds.get(region_name, 0.0))
			detail["cities_data"] = []
			for city in cities:
				if str(city.get("region", "")) == region_name:
					detail["cities_data"].append(city.duplicate(true))
			return detail
	return {}

func allocate_region_budget(region_name: String, amount: float) -> bool:
	if region_name.is_empty() or amount < 1000000.0 or amount > treasury:
		return false
	regional_funds[region_name] = float(regional_funds.get(region_name, 0.0)) + amount
	treasury -= amount
	state_changed.emit()
	return true

func invest_in_region(region_name: String, category: String) -> bool:
	var allowed := ["roads", "power", "housing", "health", "education"]
	if not allowed.has(category):
		return false
	var target_index := -1
	var lowest_level := 999
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		if str(city.get("region", "")) != region_name:
			continue
		var level := int(city.get(category, 1))
		if level < lowest_level and level < 30:
			lowest_level = level
			target_index = index
	if target_index < 0:
		return false
	var target: Dictionary = cities[target_index]
	var cost := maxf(float(target.get("gdp", 0.0)) * 0.00008 * float(lowest_level + 1), 5000000.0)
	var funds := float(regional_funds.get(region_name, 0.0))
	if funds < cost:
		return false
	regional_funds[region_name] = funds - cost
	target[category] = lowest_level + 1
	target["development_index"] = minf(100.0, float(target.get("development_index", 25.0)) + 1.2)
	target["quality_of_life"] = minf(100.0, float(target.get("quality_of_life", 58.0)) + (0.35 if category == "health" or category == "housing" else 0.15))
	cities[target_index] = target
	state_changed.emit()
	return true


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
var mining_resources: Array[String] = ["gold", "coal", "iron", "copper", "uranium", "oil", "natural_gas", "bauxite", "rare_earths", "lithium"]
var resource_reserves: Dictionary = {}
var resource_inventory: Dictionary = {}
var resource_market_prices: Dictionary = {}
var mining_sites: Array[Dictionary] = []
var exploration_count: Dictionary = {}
var resource_production: Dictionary = {}
var mining_jobs: int = 0
var mining_tax_rate: float = 0.08
var monthly_mining_revenue: float = 0.0
var monthly_mining_cost: float = 0.0
var mining_report: String = "No mining operations established."
var power_plants: Array[Dictionary] = []
var energy_fuel_reserves: Dictionary = {"coal": 0.0, "gas": 0.0, "uranium": 0.0}
var grid_capacity: float = 0.0
var energy_demand: float = 0.0
var energy_generation: float = 0.0
var energy_supply_ratio: float = 1.0
var energy_price: float = 1200.0
var blackout_risk: float = 5.0
var monthly_power_cost: float = 0.0
var regional_power_access: Dictionary = {}
var last_energy_report: String = "National grid operating normally."

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
		_run_monthly_energy()
		_run_monthly_mining()
		_run_monthly_industry()
		_run_monthly_infrastructure()
		_run_monthly_transport_simulation()
		_run_monthly_company_simulation()
		_run_monthly_banking_simulation()
		_run_monthly_social_simulation()
		_run_monthly_public_services()
		_run_monthly_research()
		_run_monthly_space_program()
		_run_monthly_intelligence()
		_run_monthly_immigration()
		_run_monthly_media()
		_run_monthly_environment()
		_update_government_monthly()
		_run_monthly_city_simulation()
		_update_market_prices()
		_run_ai_world_simulation()
		_run_diplomacy_monthly_effects()
	state_changed.emit()

func _run_monthly_economy() -> void:
	if gdp <= 0.0:
		return
	monthly_revenue = gdp * tax_rate / 12.0
	monthly_defense_cost = gdp * defense_budget_rate / 12.0
	monthly_welfare_cost = gdp * social_welfare_rate / 12.0
	monthly_environment_cost = gdp * environment_budget_rate / 12.0
	monthly_expenses = gdp * (spending_rate + research_budget_rate + environment_budget_rate + media_budget_rate + healthcare_budget_rate + education_budget_rate) / 12.0 + monthly_defense_cost + monthly_welfare_cost + monthly_power_cost
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
	var infrastructure_effect := (float(infrastructure.get("roads", 0)) + float(infrastructure.get("power", 0)) + float(infrastructure.get("ports", 0)) + float(infrastructure.get("airports", 0))) * 0.000012
	var investment_effect := (spending_rate - 0.12) * 0.004 + infrastructure_effect
	var stability_effect := (stability - 50.0) * 0.000015
	var inflation_effect := maxf(0.0, inflation - 5.0) * 0.00008
	gdp *= 1.0 + monthly_growth + investment_effect + stability_effect - inflation_effect
	var social_infrastructure := float(infrastructure.get("hospitals", 0)) + float(infrastructure.get("schools", 0)) + float(infrastructure.get("housing", 0))
	var annual_population_growth := 0.008 + (stability - 50.0) * 0.00004 + social_infrastructure * 0.000008 - maxf(0.0, unemployment - 8.0) * 0.0001
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
		},
		"resource_inventory": {
			"gold": base_gdp / 1000000000000.0 * 0.08, "coal": base_gdp / 1000000000.0 * 0.35,
			"iron": base_gdp / 1000000000.0 * 0.28, "copper": base_gdp / 1000000000.0 * 0.12,
			"uranium": base_gdp / 1000000000.0 * 0.015, "oil": base_gdp / 1000000000.0 * 0.20,
			"natural_gas": base_gdp / 1000000000.0 * 0.18, "bauxite": base_gdp / 1000000000.0 * 0.16,
			"rare_earths": base_gdp / 1000000000.0 * 0.025, "lithium": base_gdp / 1000000000.0 * 0.035
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

func _initialize_government() -> void:
	government_type = "Constitutional democracy"
	government_approval = 58.0
	parliament_seats = 300
	months_until_election = 48
	political_parties = [
		{"id": "national_union", "name": "National Union", "ideology": "Centre-right", "leader": "A. Rahman", "popularity": 38.0, "seats": 114, "government": true},
		{"id": "social_progress", "name": "Social Progress Party", "ideology": "Centre-left", "leader": "M. Pratama", "popularity": 29.0, "seats": 87, "government": false},
		{"id": "green_future", "name": "Green Future", "ideology": "Green / liberal", "leader": "S. Wijaya", "popularity": 19.0, "seats": 57, "government": false},
		{"id": "people_voice", "name": "People's Voice", "ideology": "Populist", "leader": "D. Santoso", "popularity": 14.0, "seats": 42, "government": false}
	]
	governing_party_id = "national_union"
	coalition_party_ids = ["national_union", "green_future"]
	cabinet.clear()
	var ministries := [
		["Finance", "Ministry of Finance"],
		["Defense", "Ministry of Defense"],
		["Foreign Affairs", "Ministry of Foreign Affairs"],
		["Interior", "Ministry of Interior"],
		["Education", "Ministry of Education"],
		["Health", "Ministry of Health"],
		["Infrastructure", "Ministry of Infrastructure"],
		["Industry", "Ministry of Industry"],
		["Energy", "Ministry of Energy"],
		["Environment", "Ministry of Environment"]
	]
	for index in range(ministries.size()):
		cabinet.append({
			"id": str(ministries[index][0]).to_lower().replace(" ", "_"),
			"ministry": ministries[index][1],
			"minister": "Acting Minister %02d" % (index + 1),
			"approval": 55.0 + float(index % 4) * 3.0
		})
	enacted_laws.clear()
	last_election_report = "Initial government formed at the start of the simulation."

func government_coalition_seats() -> int:
	var total := 0
	for party in political_parties:
		if coalition_party_ids.has(str(party.get("id", ""))):
			total += int(party.get("seats", 0))
	return total

func government_has_majority() -> bool:
	return government_coalition_seats() > parliament_seats / 2

func appoint_minister(ministry_id: String, minister_name: String) -> bool:
	var clean_name := minister_name.strip_edges()
	if clean_name.length() < 3 or clean_name.length() > 36:
		return false
	for index in range(cabinet.size()):
		var entry: Dictionary = cabinet[index]
		if str(entry.get("id", "")) == ministry_id:
			entry["minister"] = clean_name
			entry["approval"] = clampf(float(entry.get("approval", 50.0)) + 1.5, 0.0, 100.0)
			cabinet[index] = entry
			state_changed.emit()
			return true
	return false

func pass_legislation(law_id: String) -> bool:
	if enacted_laws.has(law_id) or not government_has_majority():
		return false
	var law_cost := gdp * 0.0015
	if law_id == "education_act" or law_id == "healthcare_act":
		law_cost = gdp * 0.002
	elif law_id == "green_transition":
		law_cost = gdp * 0.0025
	elif law_id == "infrastructure_act":
		law_cost = gdp * 0.003
	else:
		return false
	if treasury < law_cost:
		return false
	treasury -= law_cost
	match law_id:
		"education_act":
			infrastructure["schools"] = mini(100, int(infrastructure.get("schools", 0)) + 2)
			spending_rate = minf(0.45, spending_rate + 0.002)
			social_mobility = clampf(social_mobility + 4.0, 0.0, 100.0)
		"healthcare_act":
			infrastructure["hospitals"] = mini(100, int(infrastructure.get("hospitals", 0)) + 2)
			social_welfare_rate = minf(0.08, social_welfare_rate + 0.002)
			stability = minf(100.0, stability + 1.5)
		"green_transition":
			infrastructure["power"] = mini(100, int(infrastructure.get("power", 0)) + 2)
			annual_gdp_growth = minf(15.0, annual_gdp_growth + 0.15)
			inflation = maxf(0.0, inflation - 0.1)
		"infrastructure_act":
			infrastructure["roads"] = mini(100, int(infrastructure.get("roads", 0)) + 2)
			infrastructure["airports"] = mini(100, int(infrastructure.get("airports", 0)) + 1)
			annual_gdp_growth = minf(15.0, annual_gdp_growth + 0.2)
	enacted_laws.append(law_id)
	government_approval = clampf(government_approval + 2.0, 0.0, 100.0)
	_update_budget_forecast()
	state_changed.emit()
	return true

func _update_government_monthly() -> void:
	var performance := (annual_gdp_growth - 2.0) * 0.32
	performance -= maxf(0.0, inflation - 4.0) * 0.22
	performance -= maxf(0.0, unemployment - 5.0) * 0.28
	performance -= maxf(0.0, poverty_rate - 18.0) * 0.035
	performance += (stability - 55.0) * 0.025
	government_approval = clampf(government_approval + clampf(performance, -2.0, 1.5), 5.0, 95.0)
	months_until_election -= 1
	if months_until_election <= 0:
		hold_election(false)

func hold_election(early: bool = true) -> bool:
	if political_parties.is_empty():
		_initialize_government()
	var total_weight := 0.0
	for index in range(political_parties.size()):
		var party: Dictionary = political_parties[index]
		var popularity := float(party.get("popularity", 10.0))
		if str(party.get("id", "")) == governing_party_id:
			popularity += (government_approval - 50.0) * 0.16
		else:
			popularity += (50.0 - government_approval) * 0.045
		popularity = maxf(2.0, popularity)
		party["election_weight"] = popularity
		total_weight += popularity
		political_parties[index] = party
	var assigned_seats := 0
	var winner_id := ""
	var winner_seats := -1
	for index in range(political_parties.size()):
		var party: Dictionary = political_parties[index]
		var seats := int(floor(float(parliament_seats) * float(party.get("election_weight", 1.0)) / maxf(total_weight, 1.0)))
		party["seats"] = seats
		party["popularity"] = float(party.get("election_weight", 1.0)) / maxf(total_weight, 1.0) * 100.0
		party.erase("election_weight")
		party["government"] = false
		assigned_seats += seats
		if seats > winner_seats:
			winner_seats = seats
			winner_id = str(party.get("id", ""))
		political_parties[index] = party
	var remainder := parliament_seats - assigned_seats
	if remainder > 0:
		for index in range(remainder):
			var party_index := index % maxi(1, political_parties.size())
			political_parties[party_index]["seats"] = int(political_parties[party_index].get("seats", 0)) + 1
	governing_party_id = winner_id
	coalition_party_ids.clear()
	coalition_party_ids.append(winner_id)
	var sorted_parties := political_parties.duplicate(true)
	sorted_parties.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("seats", 0)) > int(b.get("seats", 0))
	)
	var coalition_seats := winner_seats
	for party in sorted_parties:
		var party_id := str(party.get("id", ""))
		if party_id == winner_id:
			continue
		if coalition_seats > parliament_seats / 2:
			break
		coalition_party_ids.append(party_id)
		coalition_seats += int(party.get("seats", 0))
	for index in range(political_parties.size()):
		var party: Dictionary = political_parties[index]
		party["government"] = coalition_party_ids.has(str(party.get("id", "")))
		political_parties[index] = party
	if early:
		government_approval = maxf(5.0, government_approval - 4.0)
	else:
		government_approval = clampf(government_approval + 1.0, 5.0, 95.0)
	months_until_election = 48
	last_election_report = "Election complete: %s leads with %d seats. Coalition holds %d of %d seats." % [winner_id.replace("_", " ").capitalize(), maxi(0, winner_seats), government_coalition_seats(), parliament_seats]
	state_changed.emit()
	return true


func _initialize_mining() -> void:
	resource_reserves.clear()
	resource_inventory.clear()
	resource_market_prices = {"gold": 62000.0, "coal": 120.0, "iron": 145.0, "copper": 9200.0, "uranium": 85000.0, "oil": 78.0, "natural_gas": 42.0, "bauxite": 68.0, "rare_earths": 12500.0, "lithium": 14500.0}
	resource_production.clear()
	exploration_count.clear()
	mining_sites.clear()
	mining_jobs = 0
	mining_tax_rate = 0.08
	monthly_mining_revenue = 0.0
	monthly_mining_cost = 0.0
	var country_id := str(selected_country.get("id", "AAA"))
	var seed_value := abs(country_id.hash())
	for index in range(mining_resources.size()):
		var resource := mining_resources[index]
		var variation := 0.45 + float(posmod(seed_value / (index + 1) + index * 173, 1100)) / 1000.0
		resource_reserves[resource] = maxf(0.0, gdp / 1000000000.0 * variation * (1.0 + float(index % 4) * 0.35))
		resource_inventory[resource] = 0.0
		resource_production[resource] = 0.0
		exploration_count[resource] = 0
	for resource in ["coal", "iron"]:
		var reserve := float(resource_reserves.get(resource, 0.0))
		if reserve > 0.0:
			mining_sites.append({"id": "MINE_%s_001" % resource.to_upper(), "resource": resource, "region": "National Territory", "level": 1, "capacity": maxf(0.2, reserve * 0.025), "workers": maxi(80, int(float(population) * 0.000015)), "operating": true})
	mining_report = "National geological survey initialized with abstract gameplay deposits."
	_run_monthly_mining()

func resource_exploration_cost(resource: String) -> float:
	if not mining_resources.has(resource) or int(exploration_count.get(resource, 0)) >= 5:
		return -1.0
	return maxf(gdp * 0.00018, 12000000.0) * (1.0 + float(exploration_count.get(resource, 0)) * 0.55)

func explore_resource(resource: String) -> bool:
	var cost := resource_exploration_cost(resource)
	if cost < 0.0 or treasury < cost:
		return false
	treasury -= cost
	var attempts := int(exploration_count.get(resource, 0))
	var seed_text := "%s_%s_%d_%d" % [str(selected_country.get("id", "AAA")), resource, int(game_date.get("year", 2026)), attempts]
	var discovery_roll := posmod(seed_text.hash(), 100)
	var discovered := 0.0
	if discovery_roll < 78:
		var size_factor := 0.08 + float(posmod(seed_text.hash() / 7, 100)) / 100.0
		discovered = maxf(0.5, gdp / 1000000000.0 * size_factor)
		resource_reserves[resource] = float(resource_reserves.get(resource, 0.0)) + discovered
		mining_report = "Survey discovered %.2f abstract units of %s deposits." % [discovered, resource.replace("_", " ")]
	else:
		mining_report = "Survey found no commercially viable %s deposit." % resource.replace("_", " ")
	exploration_count[resource] = attempts + 1
	state_changed.emit()
	return true

func mine_construction_cost(resource: String) -> float:
	if not mining_resources.has(resource) or float(resource_reserves.get(resource, 0.0)) <= 0.0 or mining_sites.size() >= 100:
		return -1.0
	return maxf(gdp * 0.00032, 18000000.0)

func open_mine(resource: String, region_name: String) -> bool:
	var cost := mine_construction_cost(resource)
	if cost < 0.0 or treasury < cost:
		return false
	var region_exists := false
	for region in get_regions():
		if str(region.get("name", "")) == region_name:
			region_exists = true
			break
	if not region_exists:
		region_name = "National Territory"
	treasury -= cost
	var site_number := 1
	for site in mining_sites:
		if str(site.get("resource", "")) == resource:
			site_number += 1
	var capacity := maxf(0.15, float(resource_reserves.get(resource, 0.0)) * 0.018)
	var workers := maxi(60, int(float(population) * 0.000012))
	mining_sites.append({"id": "MINE_%s_%03d" % [resource.to_upper(), site_number], "resource": resource, "region": region_name, "level": 1, "capacity": capacity, "workers": workers, "operating": true})
	mining_report = "%s mine commissioned in %s." % [resource.replace("_", " ").capitalize(), region_name]
	state_changed.emit()
	return true

func mine_upgrade_cost(site_id: String) -> float:
	for site in mining_sites:
		if str(site.get("id", "")) == site_id:
			var level := int(site.get("level", 1))
			if level >= 10:
				return -1.0
			return maxf(gdp * (0.00012 + float(level) * 0.00006), 8000000.0)
	return -1.0

func upgrade_mine(site_id: String) -> bool:
	var cost := mine_upgrade_cost(site_id)
	if cost < 0.0 or treasury < cost:
		return false
	for index in range(mining_sites.size()):
		var site: Dictionary = mining_sites[index]
		if str(site.get("id", "")) == site_id:
			site["level"] = int(site.get("level", 1)) + 1
			site["capacity"] = float(site.get("capacity", 0.0)) * 1.22
			site["workers"] = int(float(site.get("workers", 0)) * 1.15)
			mining_sites[index] = site
			treasury -= cost
			mining_report = "%s upgraded to level %d." % [site_id, int(site["level"])]
			state_changed.emit()
			return true
	return false

func set_mining_tax(new_rate: float) -> void:
	mining_tax_rate = clampf(new_rate, 0.02, 0.30)
	state_changed.emit()

func trade_natural_resource_with_country(country_id: String, resource: String, direction: String, quantity: float) -> bool:
	if not mining_resources.has(resource) or not diplomacy_relations.has(country_id):
		return false
	var treaty: Dictionary = diplomacy_relations[country_id]
	if not bool(treaty.get("trade_agreement", false)) or bool(treaty.get("at_war", false)) or bool(treaty.get("sanctions", false)):
		return false
	if quantity <= 0.0 or quantity > 100000.0 or not ["import", "export"].has(direction):
		return false
	var nation := get_ai_country(country_id)
	if nation.is_empty():
		return false
	var partner_inventory: Dictionary = nation.get("resource_inventory", {})
	var partner_treasury := float(nation.get("treasury", 0.0))
	var value := float(resource_market_prices.get(resource, 100.0)) * quantity
	if direction == "export":
		var available := float(resource_inventory.get(resource, 0.0))
		if available < quantity or partner_treasury < value:
			return false
		resource_inventory[resource] = available - quantity
		partner_inventory[resource] = float(partner_inventory.get(resource, 0.0)) + quantity
		partner_treasury -= value
		treasury += value
		trade_exports += value
		trade_balance += value
	else:
		var available_partner := float(partner_inventory.get(resource, 0.0))
		var tariff := value * trade_tariff_rate
		if available_partner < quantity or treasury < value + tariff:
			return false
		partner_inventory[resource] = available_partner - quantity
		resource_inventory[resource] = float(resource_inventory.get(resource, 0.0)) + quantity
		partner_treasury += value
		treasury -= value + tariff
		trade_imports += value
		trade_balance -= value
	for index in range(ai_countries.size()):
		if str(ai_countries[index].get("id", "")) == country_id:
			var updated: Dictionary = ai_countries[index]
			updated["treasury"] = partner_treasury
			updated["resource_inventory"] = partner_inventory
			ai_countries[index] = updated
			break
	mining_report = "%s %.2f units of %s with %s for %s." % [direction.capitalize(), quantity, resource.replace("_", " "), str(nation.get("name", country_id)), _format_trade_money(value)]
	state_changed.emit()
	return true

func _run_monthly_mining() -> void:
	resource_production.clear()
	for resource in mining_resources:
		resource_production[resource] = 0.0
	mining_jobs = 0
	monthly_mining_revenue = 0.0
	monthly_mining_cost = 0.0
	for index in range(mining_sites.size()):
		var site: Dictionary = mining_sites[index]
		if not bool(site.get("operating", true)):
			continue
		var resource := str(site.get("resource", ""))
		if not mining_resources.has(resource):
			continue
		var capacity := maxf(0.0, float(site.get("capacity", 0.0)))
		var available := maxf(0.0, float(resource_reserves.get(resource, 0.0)))
		var output := minf(capacity, available)
		resource_reserves[resource] = maxf(0.0, available - output)
		resource_production[resource] = float(resource_production.get(resource, 0.0)) + output
		resource_inventory[resource] = float(resource_inventory.get(resource, 0.0)) + output
		mining_jobs += int(site.get("workers", 0))
		var price := float(resource_market_prices.get(resource, 100.0))
		monthly_mining_revenue += output * price
		monthly_mining_cost += output * price * 0.34
		if resource == "coal":
			energy_fuel_reserves["coal"] = float(energy_fuel_reserves.get("coal", 0.0)) + output * 0.12
		elif resource == "natural_gas":
			energy_fuel_reserves["gas"] = float(energy_fuel_reserves.get("gas", 0.0)) + output * 0.12
		elif resource == "uranium":
			energy_fuel_reserves["uranium"] = float(energy_fuel_reserves.get("uranium", 0.0)) + output * 0.08
		if resource in ["iron", "copper", "bauxite", "lithium", "rare_earths", "gold"]:
			resource_stockpiles["metals"] = float(resource_stockpiles.get("metals", 0.0)) + output * 0.05
		if resource in ["coal", "oil", "natural_gas"]:
			resource_stockpiles["energy"] = float(resource_stockpiles.get("energy", 0.0)) + output * 0.025
	var tax_income := maxf(0.0, monthly_mining_revenue - monthly_mining_cost) * mining_tax_rate
	treasury += tax_income
	if mining_sites.size() > 0:
		var mine_pressure := minf(0.18, float(mining_jobs) / maxf(float(population), 1.0) * 0.0007)
		air_pollution = clampf(air_pollution + mine_pressure, 0.0, 100.0)
		water_pollution = clampf(water_pollution + mine_pressure * 0.65, 0.0, 100.0)
		forest_cover = clampf(forest_cover - mine_pressure * 0.025, 2.0, 95.0)
	mining_report = "%d mine sites produced resources worth %s; tax receipts %s." % [mining_sites.size(), _format_trade_money(monthly_mining_revenue), _format_trade_money(tax_income)]
	_update_budget_forecast()

func _initialize_energy() -> void:
	power_plants.clear()
	energy_fuel_reserves = {
		"coal": maxf(10.0, gdp / 1000000000.0 * 0.42),
		"gas": maxf(8.0, gdp / 1000000000.0 * 0.30),
		"uranium": maxf(2.0, gdp / 1000000000.0 * 0.025)
	}
	energy_demand = maxf(1.0, float(population) / 8000000.0 + gdp / 100000000000.0 * 0.30)
	var base_capacity := energy_demand * 1.22
	var plant_mix := [
		{"type": "coal", "share": 0.28, "availability": 0.82},
		{"type": "gas", "share": 0.20, "availability": 0.88},
		{"type": "nuclear", "share": 0.12, "availability": 0.91},
		{"type": "hydro", "share": 0.16, "availability": 0.72},
		{"type": "solar", "share": 0.14, "availability": 0.24},
		{"type": "wind", "share": 0.10, "availability": 0.36}
	]
	var plant_index := 0
	for spec in plant_mix:
		var kind := str(spec["type"])
		var capacity := base_capacity * float(spec["share"])
		power_plants.append({
			"id": "GRID_%s_%02d" % [kind.to_upper(), plant_index + 1],
			"type": kind,
			"name": "%s National Station" % kind.capitalize(),
			"capacity": capacity,
			"availability": float(spec["availability"]),
			"operating": true,
			"age": 4
		})
		plant_index += 1
	grid_capacity = energy_demand * 1.30
	energy_generation = 0.0
	energy_supply_ratio = 1.0
	energy_price = 1200.0
	blackout_risk = 4.0
	monthly_power_cost = gdp * 0.0035 / 12.0
	regional_power_access.clear()
	for region in get_regions():
		var region_name := str(region.get("name", ""))
		regional_power_access[region_name] = 78.0 + float(abs(region_name.hash()) % 1800) / 100.0
	last_energy_report = "National grid commissioned with %d generation stations." % power_plants.size()
	_run_monthly_energy()

func energy_plant_cost(plant_type: String) -> float:
	var costs := {
		"coal": 0.0018, "gas": 0.0015, "nuclear": 0.0055,
		"hydro": 0.0032, "solar": 0.0013, "wind": 0.0017
	}
	if not costs.has(plant_type):
		return -1.0
	return maxf(gdp * float(costs[plant_type]), 35000000.0)

func build_power_plant(plant_type: String) -> bool:
	var cost := energy_plant_cost(plant_type)
	if cost < 0.0 or treasury < cost or power_plants.size() >= 80:
		return false
	var capacities := {"coal": 0.10, "gas": 0.11, "nuclear": 0.16, "hydro": 0.09, "solar": 0.07, "wind": 0.08}
	var availability := {"coal": 0.82, "gas": 0.88, "nuclear": 0.91, "hydro": 0.72, "solar": 0.24, "wind": 0.36}
	var capacity := maxf(0.5, energy_demand * float(capacities[plant_type]))
	treasury -= cost
	power_plants.append({
		"id": "GRID_%s_%03d" % [plant_type.to_upper(), power_plants.size() + 1],
		"type": plant_type,
		"name": "%s Power Station %d" % [plant_type.capitalize(), power_plants.size() + 1],
		"capacity": capacity,
		"availability": float(availability[plant_type]),
		"operating": true,
		"age": 0
	})
	last_energy_report = "%s generation station commissioned (+%.2f GW capacity)." % [plant_type.capitalize(), capacity]
	state_changed.emit()
	return true

func upgrade_national_grid() -> bool:
	var cost := maxf(gdp * (0.0007 + grid_capacity / maxf(energy_demand, 1.0) * 0.00012), 25000000.0)
	if treasury < cost or grid_capacity >= energy_demand * 3.0:
		return false
	treasury -= cost
	grid_capacity = minf(energy_demand * 3.0, grid_capacity + maxf(1.0, energy_demand * 0.12))
	last_energy_report = "National transmission capacity expanded."
	state_changed.emit()
	return true

func upgrade_regional_grid(region_name: String) -> bool:
	if not regional_power_access.has(region_name):
		return false
	var access := float(regional_power_access[region_name])
	if access >= 100.0:
		return false
	var cost := maxf(gdp * 0.00025, 15000000.0)
	if treasury < cost:
		return false
	treasury -= cost
	regional_power_access[region_name] = minf(100.0, access + 8.0)
	last_energy_report = "%s regional grid upgraded to %.1f%% access." % [region_name, float(regional_power_access[region_name])]
	state_changed.emit()
	return true

func _run_monthly_energy() -> void:
	if energy_demand <= 0.0:
		energy_demand = maxf(1.0, float(population) / 8000000.0 + gdp / 100000000000.0 * 0.30)
	var total_generation := 0.0
	var fuel_cost := 0.0
	for index in range(power_plants.size()):
		var plant: Dictionary = power_plants[index]
		if not bool(plant.get("operating", true)):
			continue
		var kind := str(plant.get("type", "gas"))
		var capacity := float(plant.get("capacity", 0.0))
		var availability := float(plant.get("availability", 0.5))
		var fuel_key := kind
		if kind == "coal" or kind == "gas" or kind == "nuclear":
			var fuel_need := capacity * availability * 0.035
			var fuel_available := float(energy_fuel_reserves.get(fuel_key, 0.0))
			var fuel_ratio := clampf(fuel_available / maxf(fuel_need, 0.001), 0.0, 1.0)
			energy_fuel_reserves[fuel_key] = maxf(0.0, fuel_available - fuel_need * fuel_ratio)
			availability *= fuel_ratio
			fuel_cost += capacity * availability * (0.00012 if kind == "nuclear" else 0.00008)
		var generated := capacity * availability
		total_generation += generated
		plant["age"] = int(plant.get("age", 0)) + 1
		power_plants[index] = plant
	energy_generation = total_generation
	energy_supply_ratio = clampf(minf(energy_generation, grid_capacity) / maxf(energy_demand, 0.1), 0.0, 1.5)
	var supply_gap := maxf(0.0, 1.0 - energy_supply_ratio)
	blackout_risk = clampf(supply_gap * 100.0 + maxf(0.0, energy_demand / maxf(grid_capacity, 0.1) - 0.85) * 12.0, 0.0, 100.0)
	energy_price = clampf(850.0 + supply_gap * 4200.0 + maxf(0.0, energy_demand - energy_generation) * 18.0, 400.0, 12000.0)
	var renewable_generation := 0.0
	for plant in power_plants:
		if ["hydro", "solar", "wind"].has(str(plant.get("type", ""))):
			renewable_generation += float(plant.get("capacity", 0.0)) * float(plant.get("availability", 0.0))
	var renewable_ratio := renewable_generation / maxf(total_generation, 0.1)
	renewable_energy_share = clampf(renewable_ratio * 100.0, 0.0, 100.0)
	monthly_power_cost = gdp * (0.0022 + fuel_cost + supply_gap * 0.006) / 12.0
	market_prices["energy"] = energy_price
	resource_stockpiles["energy"] = maxf(0.0, float(resource_stockpiles.get("energy", 0.0)) + energy_generation - energy_demand)
	if supply_gap > 0.15:
		last_energy_report = "Power shortage %.1f%% • rolling blackouts likely." % (supply_gap * 100.0)
		annual_gdp_growth = maxf(-5.0, annual_gdp_growth - supply_gap * 0.18)
		stability = maxf(0.0, stability - supply_gap * 1.2)
	elif energy_supply_ratio > 1.12:
		last_energy_report = "Power surplus %.1f%% • grid operating with reserve margin." % ((energy_supply_ratio - 1.0) * 100.0)
	else:
		last_energy_report = "National electricity supply meets current demand."
	for region_name in regional_power_access.keys():
		var access := float(regional_power_access[region_name])
		var pressure := supply_gap * 0.08
		regional_power_access[region_name] = clampf(access - pressure + 0.015, 35.0, 100.0)
	_update_budget_forecast()

func _initialize_environment() -> void:
	environment_budget_rate = 0.012
	monthly_environment_cost = gdp * environment_budget_rate / 12.0
	carbon_emissions = maxf(1.0, float(population) / 1000000.0 * 0.42 + industrial_output / 1000000000.0 * 0.08)
	air_pollution = clampf(28.0 + industrial_capacity * 90.0, 10.0, 90.0)
	water_pollution = clampf(22.0 + industrial_capacity * 65.0, 8.0, 85.0)
	forest_cover = 24.0 + float(abs(str(selected_country.get("id", "AAA")).hash()) % 3500) / 100.0
	forest_cover = clampf(forest_cover, 12.0, 58.0)
	climate_risk = clampf(18.0 + (100.0 - forest_cover) * 0.32 + industrial_capacity * 55.0, 8.0, 72.0)
	biodiversity = clampf(45.0 + forest_cover * 0.75 - air_pollution * 0.18, 10.0, 95.0)
	environmental_quality = clampf(100.0 - air_pollution * 0.42 - water_pollution * 0.30 + forest_cover * 0.18, 10.0, 95.0)
	renewable_energy_share = clampf(12.0 + float(infrastructure.get("power", 10)) * 0.45, 5.0, 55.0)
	disaster_resilience = clampf(28.0 + float(infrastructure.get("roads", 12)) * 0.7 + float(infrastructure.get("hospitals", 8)) * 1.1 + float(infrastructure.get("housing", 12)) * 0.55, 15.0, 85.0)
	disaster_cooldown = 0
	disaster_history.clear()
	last_disaster_report = "No major natural disasters recorded."
	_update_budget_forecast()

func set_environment_budget(new_rate: float) -> void:
	environment_budget_rate = clampf(new_rate, 0.002, 0.06)
	_update_budget_forecast()
	state_changed.emit()

func environment_project_cost(project_id: String) -> float:
	var multipliers := {"reforestation": 0.00045, "pollution_cleanup": 0.00055, "renewable_transition": 0.0011, "flood_defense": 0.0008, "disaster_preparedness": 0.0005}
	if not multipliers.has(project_id):
		return -1.0
	return maxf(gdp * float(multipliers[project_id]), 20000000.0)

func invest_in_environment_project(project_id: String) -> bool:
	var cost := environment_project_cost(project_id)
	if cost < 0.0 or treasury < cost:
		return false
	treasury -= cost
	match project_id:
		"reforestation":
			forest_cover = minf(85.0, forest_cover + 1.8)
			biodiversity = minf(100.0, biodiversity + 1.5)
			climate_risk = maxf(5.0, climate_risk - 1.2)
		"pollution_cleanup":
			air_pollution = maxf(3.0, air_pollution - 5.0)
			water_pollution = maxf(3.0, water_pollution - 4.0)
			environmental_quality = minf(100.0, environmental_quality + 4.0)
		"renewable_transition":
			renewable_energy_share = minf(95.0, renewable_energy_share + 5.0)
			carbon_emissions = maxf(0.0, carbon_emissions * 0.96)
			air_pollution = maxf(0.0, air_pollution - 1.2)
		"flood_defense":
			disaster_resilience = minf(100.0, disaster_resilience + 8.0)
			climate_risk = maxf(5.0, climate_risk - 0.8)
		"disaster_preparedness":
			disaster_resilience = minf(100.0, disaster_resilience + 12.0)
			stability = minf(100.0, stability + 1.0)
	last_disaster_report = "Environmental project completed: %s." % project_id.replace("_", " ").capitalize()
	state_changed.emit()
	return true

func _run_monthly_environment() -> void:
	if gdp <= 0.0:
		return
	monthly_environment_cost = gdp * environment_budget_rate / 12.0
	var industrial_pressure := industrial_capacity * 100.0 + float(factory_count) * 0.012
	var population_pressure := float(population) / maxf(gdp / 1000000000.0, 1.0) * 0.00002
	var emissions_growth := 0.0015 + industrial_pressure * 0.000025 + population_pressure * 0.00001
	emissions_growth -= renewable_energy_share * 0.000018 + environment_budget_rate * 0.035
	carbon_emissions = maxf(0.1, carbon_emissions * (1.0 + clampf(emissions_growth, -0.012, 0.012)))
	air_pollution = clampf(air_pollution + industrial_capacity * 0.22 - renewable_energy_share * 0.012 - environment_budget_rate * 18.0 + 0.08, 0.0, 100.0)
	water_pollution = clampf(water_pollution + industrial_capacity * 0.16 - environment_budget_rate * 13.0 + 0.04, 0.0, 100.0)
	forest_cover = clampf(forest_cover - maxf(0.0, industrial_capacity - 0.08) * 0.045 + environment_budget_rate * 12.0, 2.0, 95.0)
	biodiversity = clampf(biodiversity + (forest_cover - 35.0) * 0.006 - air_pollution * 0.0015 - water_pollution * 0.001 + environment_budget_rate * 4.0, 0.0, 100.0)
	renewable_energy_share = clampf(renewable_energy_share + environment_budget_rate * 0.18 - 0.025, 0.0, 100.0)
	climate_risk = clampf(climate_risk + maxf(0.0, carbon_emissions / maxf(float(population) / 1000000.0, 1.0) - 0.5) * 0.0004 - forest_cover * 0.0008 - environment_budget_rate * 3.0, 0.0, 100.0)
	environmental_quality = clampf(100.0 - air_pollution * 0.43 - water_pollution * 0.31 + forest_cover * 0.18 + biodiversity * 0.12, 0.0, 100.0)
	disaster_resilience = clampf(disaster_resilience + environment_budget_rate * 0.35 - 0.04, 10.0, 100.0)
	if disaster_cooldown > 0:
		disaster_cooldown -= 1
	else:
		var year := int(game_date.get("year", 2026))
		var month := int(game_date.get("month", 1))
		var country_id := str(selected_country.get("id", "AAA"))
		var roll := posmod((country_id + "_" + str(year) + "_" + str(month)).hash(), 10000)
		var hazard_probability := clampf(0.002 + climate_risk * 0.00017, 0.002, 0.019)
		if float(roll) / 10000.0 < hazard_probability:
			_trigger_natural_disaster(roll, year, month)
	_update_budget_forecast()

func _trigger_natural_disaster(seed_value: int, year: int, month: int) -> void:
	var kinds := ["Flood", "Drought", "Severe storm", "Earthquake", "Wildfire", "Tsunami"]
	var weights := [22, 18, 22, 18, 15, 5]
	var roll := posmod(seed_value / 7, 100)
	var running := 0
	var disaster := "Flood"
	for index in range(kinds.size()):
		running += int(weights[index])
		if roll < running:
			disaster = str(kinds[index])
			break
	var severity := clampf(25.0 + float(posmod(seed_value / 13, 7000)) / 100.0, 25.0, 95.0)
	var resilience_factor := 1.0 - disaster_resilience / 150.0
	var economic_damage := gdp * severity * 0.00012 * resilience_factor
	var infrastructure_damage := severity * 0.025 * resilience_factor
	treasury = maxf(0.0, treasury - minf(treasury, economic_damage))
	gdp = maxf(gdp * 0.90, gdp - economic_damage * 0.22)
	population = maxi(1, population - int(float(population) * severity * 0.000008 * resilience_factor))
	stability = maxf(0.0, stability - severity * 0.035 * resilience_factor)
	for key in ["roads", "power", "housing"]:
		infrastructure[key] = maxi(1, int(infrastructure.get(key, 1)) - int(infrastructure_damage / 8.0))
	for index in range(cities.size()):
		var city: Dictionary = cities[index]
		city["quality_of_life"] = maxf(5.0, float(city.get("quality_of_life", 50.0)) - severity * 0.06 * resilience_factor)
		city["development_index"] = maxf(5.0, float(city.get("development_index", 25.0)) - severity * 0.025 * resilience_factor)
		cities[index] = city
	var report := "%s disaster • severity %.0f/100 • estimated economic damage %s." % [disaster, severity, _environment_money(economic_damage)]
	last_disaster_report = report
	disaster_history.push_front({"year": year, "month": month, "type": disaster, "severity": severity, "damage": economic_damage})
	while disaster_history.size() > 12:
		disaster_history.pop_back()
	disaster_cooldown = 5
	environmental_quality = maxf(0.0, environmental_quality - severity * 0.025)
	state_changed.emit()

func _environment_money(value: float) -> String:
	if value >= 1000000000000.0:
		return "$%.2fT" % (value / 1000000000000.0)
	if value >= 1000000000.0:
		return "$%.2fB" % (value / 1000000000.0)
	if value >= 1000000.0:
		return "$%.1fM" % (value / 1000000.0)
	return "$%.0f" % value

func _initialize_research() -> void:
	research_budget_rate = 0.015
	research_labs = 1
	scientists = maxi(500, int(float(population) * 0.00002))
	research_points = 0.0
	active_research_id = ""
	completed_technologies.clear()
	research_report = "Research institutions established."
	technology_tree = [
		{"id":"precision_agriculture","name":"Precision Agriculture","field":"Agriculture","description":"Improve crop yields and food security.","cost":120.0,"unlocked":false},
		{"id":"industrial_robotics","name":"Industrial Robotics","field":"Industry","description":"Increase factory productivity and industrial output.","cost":180.0,"unlocked":false},
		{"id":"advanced_materials","name":"Advanced Materials","field":"Industry","description":"Improve manufacturing efficiency and export competitiveness.","cost":240.0,"unlocked":false},
		{"id":"smart_grid","name":"Smart Electricity Grid","field":"Energy","description":"Reduce energy waste and strengthen power infrastructure.","cost":160.0,"unlocked":false},
		{"id":"renewable_storage","name":"Renewable Energy Storage","field":"Energy","description":"Improve clean energy reliability and energy security.","cost":220.0,"unlocked":false},
		{"id":"medical_biotech","name":"Medical Biotechnology","field":"Health","description":"Improve healthcare outcomes and life quality.","cost":210.0,"unlocked":false},
		{"id":"digital_education","name":"Digital Education","field":"Education","description":"Raise education quality and social mobility.","cost":150.0,"unlocked":false},
		{"id":"ai_governance","name":"Artificial Intelligence","field":"Digital","description":"Improve national productivity and public administration.","cost":280.0,"unlocked":false},
		{"id":"cyber_defense","name":"Cyber Defense","field":"Defense","description":"Strengthen military readiness and national resilience.","cost":190.0,"unlocked":false},
		{"id":"autonomous_transport","name":"Autonomous Transport","field":"Transport","description":"Improve logistics and transport network efficiency.","cost":250.0,"unlocked":false},
		{"id":"orbital_launch","name":"Orbital Launch Systems","field":"Space","description":"Unlock a national space programme and launch capability.","cost":360.0,"unlocked":false},
		{"id":"deep_space_missions","name":"Deep Space Missions","field":"Space","description":"Advance scientific capability beyond Earth orbit.","cost":520.0,"unlocked":false}
	]

func start_research(technology_id: String) -> bool:
	if not active_research_id.is_empty():
		return false
	for technology in technology_tree:
		if str(technology.get("id", "")) == technology_id:
			if bool(technology.get("unlocked", false)) or completed_technologies.has(technology_id):
				return false
			if technology_id == "deep_space_missions" and not completed_technologies.has("orbital_launch"):
				return false
			active_research_id = technology_id
			research_points = 0.0
			research_report = "Research started: %s." % str(technology.get("name", technology_id))
			state_changed.emit()
			return true
	return false

func set_research_budget(new_rate: float) -> void:
	research_budget_rate = clampf(new_rate, 0.005, 0.06)
	_update_budget_forecast()
	state_changed.emit()

func invest_in_research_lab() -> bool:
	var cost := maxf(gdp * 0.0018, 50000000.0) * float(research_labs + 1)
	if treasury < cost or research_labs >= 30:
		return false
	treasury -= cost
	research_labs += 1
	scientists += maxi(250, int(float(population) * 0.000008))
	research_report = "Research laboratory expanded. Research capacity increased."
	state_changed.emit()
	return true

func _run_monthly_research() -> void:
	if active_research_id.is_empty():
		return
	var monthly_funding := gdp * research_budget_rate / 12.0
	var points_gained := 4.0 + research_budget_rate * 500.0 + float(research_labs) * 2.5 + float(infrastructure.get("schools", 0)) * 0.18
	points_gained *= clampf(float(scientists) / 1200.0, 0.6, 4.0)
	for index in range(technology_tree.size()):
		var technology: Dictionary = technology_tree[index]
		if str(technology.get("id", "")) != active_research_id:
			continue
		research_points += points_gained
		var required := float(technology.get("cost", 100.0))
		if research_points >= required:
			var finished_id := active_research_id
			var finished_name := str(technology.get("name", finished_id))
			technology["unlocked"] = true
			technology_tree[index] = technology
			completed_technologies.append(finished_id)
			active_research_id = ""
			research_points = 0.0
			_apply_technology_effect(finished_id)
			research_report = "Technology unlocked: %s." % finished_name
		else:
			research_report = "%s: %.1f / %.0f research points. Funding %.1fM/month." % [
				str(technology.get("name", active_research_id)), research_points, required, monthly_funding / 1000000.0
			]
		break

func _apply_technology_effect(technology_id: String) -> void:
	match technology_id:
		"precision_agriculture":
			resource_stockpiles["food"] = float(resource_stockpiles.get("food", 0.0)) * 1.12
			annual_gdp_growth += 0.15
		"industrial_robotics":
			industrial_capacity = minf(0.35, industrial_capacity + 0.025)
			industrial_output *= 1.08
			annual_gdp_growth += 0.25
		"advanced_materials":
			industrial_output *= 1.10
			annual_gdp_growth += 0.2
		"smart_grid":
			infrastructure["power"] = mini(100, int(infrastructure.get("power", 0)) + 3)
			annual_gdp_growth += 0.15
		"renewable_storage":
			resource_stockpiles["energy"] = float(resource_stockpiles.get("energy", 0.0)) * 1.15
			inflation = maxf(0.0, inflation - 0.2)
		"medical_biotech":
			infrastructure["hospitals"] = mini(100, int(infrastructure.get("hospitals", 0)) + 3)
			stability = minf(100.0, stability + 2.0)
		"digital_education":
			infrastructure["schools"] = mini(100, int(infrastructure.get("schools", 0)) + 3)
			social_mobility = minf(100.0, social_mobility + 6.0)
		"ai_governance":
			annual_gdp_growth += 0.4
			government_approval = minf(100.0, government_approval + 2.0)
		"cyber_defense":
			military_readiness = minf(100.0, military_readiness + 8.0)
		"autonomous_transport":
			annual_gdp_growth += 0.25
			for route_index in range(transport_routes.size()):
				transport_routes[route_index]["capacity"] = float(transport_routes[route_index].get("capacity", 0.0)) * 1.12
		"orbital_launch":
			infrastructure["airports"] = mini(100, int(infrastructure.get("airports", 0)) + 1)
			annual_gdp_growth += 0.1
			space_agency_level = maxi(space_agency_level, 1)
		"deep_space_missions":
			social_mobility = minf(100.0, social_mobility + 2.0)
	_update_budget_forecast()


func space_center_cost() -> float:
	if not completed_technologies.has("orbital_launch") or space_centers >= 5:
		return -1.0
	return maxf(gdp * (0.0025 + float(space_centers) * 0.0015), 90000000.0)

func build_space_center() -> bool:
	var cost := space_center_cost()
	if cost < 0.0 or treasury < cost:
		return false
	treasury -= cost
	space_centers += 1
	space_agency_level = maxi(space_agency_level, 1)
	space_report = "National space center commissioned. Launch operations are now available."
	state_changed.emit()
	return true

func space_agency_upgrade_cost() -> float:
	if space_agency_level >= 5:
		return -1.0
	return maxf(gdp * (0.0009 + float(space_agency_level) * 0.0007), 35000000.0)

func upgrade_space_agency() -> bool:
	var cost := space_agency_upgrade_cost()
	if cost < 0.0 or treasury < cost or space_centers <= 0:
		return false
	treasury -= cost
	space_agency_level += 1
	space_report = "Space agency upgraded to level %d." % space_agency_level
	state_changed.emit()
	return true

func set_space_program_budget(new_rate: float) -> void:
	space_program_budget_rate = clampf(new_rate, 0.001, 0.03)
	_update_budget_forecast()
	state_changed.emit()

func space_mission_catalog() -> Array[Dictionary]:
	return [
		{"id": "earth_observation", "name": "Earth Observation Satellite", "cost": 0.00045, "duration": 3, "tech": "orbital_launch", "reward": "Improves environmental monitoring and disaster resilience."},
		{"id": "communications", "name": "National Communications Network", "cost": 0.00055, "duration": 4, "tech": "orbital_launch", "reward": "Expands satellite coverage and boosts economic productivity."},
		{"id": "lunar_probe", "name": "Lunar Research Probe", "cost": 0.0009, "duration": 6, "tech": "deep_space_missions", "reward": "Advances national science and research capability."},
		{"id": "mars_probe", "name": "Mars Exploration Mission", "cost": 0.0016, "duration": 9, "tech": "deep_space_missions", "reward": "A major prestige and scientific achievement."}
	]

func start_space_mission(mission_id: String) -> bool:
	if space_centers <= 0 or not active_space_mission.is_empty():
		return false
	for mission in space_mission_catalog():
		if str(mission.get("id", "")) != mission_id:
			continue
		var required_tech := str(mission.get("tech", "orbital_launch"))
		if not completed_technologies.has(required_tech):
			return false
		var cost := maxf(gdp * float(mission.get("cost", 0.001)), 25000000.0)
		if treasury < cost:
			return false
		treasury -= cost
		active_space_mission = {
			"id": mission_id, "name": str(mission.get("name", "Space mission")),
			"duration": int(mission.get("duration", 3)), "progress": 0,
			"cost": cost, "reward": str(mission.get("reward", "Scientific progress."))
		}
		space_report = "Mission launched: %s. Estimated completion: %d months." % [str(mission.get("name", mission_id)), int(mission.get("duration", 3))]
		state_changed.emit()
		return true
	return false

func _run_monthly_space_program() -> void:
	monthly_space_cost = gdp * space_program_budget_rate / 12.0
	if not active_space_mission.is_empty():
		active_space_mission["progress"] = int(active_space_mission.get("progress", 0)) + 1
		if int(active_space_mission.get("progress", 0)) >= int(active_space_mission.get("duration", 3)):
			var mission_id := str(active_space_mission.get("id", ""))
			var mission_name := str(active_space_mission.get("name", "Space mission"))
			match mission_id:
				"earth_observation":
					operational_satellites += 1
					disaster_resilience = minf(100.0, disaster_resilience + 8.0)
					environmental_quality = minf(100.0, environmental_quality + 2.0)
				"communications":
					operational_satellites += 2
					annual_gdp_growth += 0.18
					stability = minf(100.0, stability + 1.0)
				"lunar_probe":
					research_points += 45.0
					annual_gdp_growth += 0.08
				"mars_probe":
					research_points += 90.0
					government_approval = minf(100.0, government_approval + 3.0)
					stability = minf(100.0, stability + 1.5)
			space_mission_log.append({"name": mission_name, "date": formatted_date(), "status": "SUCCESS"})
			if space_mission_log.size() > 20:
				space_mission_log.pop_front()
			space_report = "Mission success: %s. %s" % [mission_name, str(active_space_mission.get("reward", ""))]
			active_space_mission.clear()
	_update_budget_forecast()


func intelligence_agency_upgrade_cost() -> float:
	if intelligence_agency_level >= 5:
		return -1.0
	return maxf(gdp * (0.0012 + float(intelligence_agency_level) * 0.0008), 35000000.0)

func upgrade_intelligence_agency() -> bool:
	var cost := intelligence_agency_upgrade_cost()
	if cost < 0.0 or treasury < cost:
		return false
	treasury -= cost
	intelligence_agency_level += 1
	intelligence_points += 18.0
	intelligence_report = "Intelligence agency upgraded to level %d." % intelligence_agency_level
	state_changed.emit()
	return true

func set_intelligence_budget(value: float) -> void:
	intelligence_budget_rate = clampf(value, 0.001, 0.03)
	_update_budget_forecast()
	state_changed.emit()

func upgrade_cyber_defense() -> bool:
	var cost := maxf(gdp * (0.0008 + cyber_defense_rating / 100000.0), 25000000.0)
	if treasury < cost or cyber_defense_rating >= 95.0:
		return false
	treasury -= cost
	cyber_defense_rating = minf(100.0, cyber_defense_rating + 8.0)
	counterintelligence_rating = minf(100.0, counterintelligence_rating + 2.0)
	intelligence_report = "National cyber defense improved. Current rating: %.1f." % cyber_defense_rating
	state_changed.emit()
	return true

func launch_intelligence_operation(target_id: String, operation_id: String) -> bool:
	if not active_intelligence_operation.is_empty() or target_id == str(selected_country.get("id", "")):
		return false
	var target_index := -1
	for index in range(ai_countries.size()):
		if str(ai_countries[index].get("id", "")) == target_id:
			target_index = index
			break
	if target_index < 0:
		return false
	var operation_cost := 0.0
	var duration := 2
	var operation_name := ""
	match operation_id:
		"foreign_intel":
			operation_cost = maxf(gdp * 0.00012, 2500000.0)
			duration = 2
			operation_name = "Foreign intelligence gathering"
		"technology_espionage":
			operation_cost = maxf(gdp * 0.00035, 8000000.0)
			duration = 3
			operation_name = "Technology intelligence operation"
			if completed_technologies.size() >= technology_tree.size():
				return false
		"cyber_disruption":
			operation_cost = maxf(gdp * 0.00055, 15000000.0)
			duration = 3
			operation_name = "Strategic cyber disruption"
			var relation: Dictionary = get_diplomacy(target_id)
			if float(relation.get("relation", 0.0)) > -10.0 and not bool(relation.get("at_war", false)):
				return false
		_:
			return false
	if treasury < operation_cost:
		return false
	treasury -= operation_cost
	active_intelligence_operation = {
		"id": operation_id, "name": operation_name, "target_id": target_id,
		"target_name": str(ai_countries[target_index].get("name", target_id)),
		"duration": duration, "progress": 0, "cost": operation_cost
	}
	intelligence_report = "Operation launched: %s against %s." % [operation_name, str(ai_countries[target_index].get("name", target_id))]
	state_changed.emit()
	return true

func _run_monthly_intelligence() -> void:
	monthly_intelligence_cost = gdp * intelligence_budget_rate / 12.0
	intelligence_points += float(intelligence_agency_level) * (0.8 + intelligence_budget_rate * 35.0)
	national_threat_level = clampf(national_threat_level + (35.0 - cyber_defense_rating) * 0.008 - counterintelligence_rating * 0.001, 0.0, 100.0)
	if active_intelligence_operation.is_empty():
		_update_budget_forecast()
		return
	active_intelligence_operation["progress"] = int(active_intelligence_operation.get("progress", 0)) + 1
	if int(active_intelligence_operation.get("progress", 0)) < int(active_intelligence_operation.get("duration", 2)):
		_update_budget_forecast()
		return
	var target_id := str(active_intelligence_operation.get("target_id", ""))
	var target_index := -1
	for index in range(ai_countries.size()):
		if str(ai_countries[index].get("id", "")) == target_id:
			target_index = index
			break
	if target_index < 0:
		intelligence_report = "Operation aborted: target nation is no longer available."
		active_intelligence_operation.clear()
		_update_budget_forecast()
		return
	var target: Dictionary = ai_countries[target_index]
	var target_defense := float(target.get("cyber_defense", 25.0))
	var target_counter := float(target.get("counterintelligence", 25.0))
	var operation_id := str(active_intelligence_operation.get("id", ""))
	var detection_chance := clampf(0.12 + target_defense * 0.004 + target_counter * 0.002 - float(intelligence_agency_level) * 0.025 - cyber_defense_rating * 0.001, 0.05, 0.75)
	var seed_value := absi(target_id.hash() + int(game_date.get("year", 2026)) * 31 + int(game_date.get("month", 1)) * 17 + intelligence_operation_log.size() * 13)
	var roll := float(seed_value % 1000) / 1000.0
	var detected := roll < detection_chance
	var outcome := "SUCCESS"
	if detected:
		outcome = "DETECTED"
		var relations: Dictionary = get_diplomacy(target_id)
		relations["relation"] = maxf(-100.0, float(relations.get("relation", 0.0)) - 18.0)
		diplomacy_relations[target_id] = relations
		target["cyber_defense"] = minf(100.0, target_defense + 5.0)
		ai_countries[target_index] = target
		stability = maxf(0.0, stability - 1.0)
		intelligence_report = "Operation detected by %s. Diplomatic relations deteriorated." % str(target.get("name", target_id))
	else:
		match operation_id:
			"foreign_intel":
				intelligence_points += 35.0
				intelligence_report = "Intelligence report acquired: %s — GDP %s, population %s, stability %.1f." % [str(target.get("name", target_id)), _environment_money(float(target.get("gdp", 0.0))), str(int(target.get("population", 0))), float(target.get("stability", 50.0))]
			"technology_espionage":
				var stolen_points := minf(65.0, 25.0 + float(intelligence_agency_level) * 8.0)
				research_points += stolen_points
				intelligence_report = "Technology intelligence successful against %s. Research gained: %.0f points." % [str(target.get("name", target_id)), stolen_points]
			"cyber_disruption":
				target["gdp"] = maxf(1000000.0, float(target.get("gdp", 0.0)) * 0.992)
				target["stability"] = maxf(0.0, float(target.get("stability", 50.0)) - 2.5)
				ai_countries[target_index] = target
				var relations: Dictionary = get_diplomacy(target_id)
				relations["relation"] = maxf(-100.0, float(relations.get("relation", 0.0)) - 8.0)
				diplomacy_relations[target_id] = relations
				intelligence_report = "Cyber operation disrupted %s economic systems. Diplomatic exposure remains possible." % str(target.get("name", target_id))
	intelligence_operation_log.append({"name": str(active_intelligence_operation.get("name", operation_id)), "target": str(target.get("name", target_id)), "date": formatted_date(), "status": outcome})
	while intelligence_operation_log.size() > 20:
		intelligence_operation_log.pop_front()
	active_intelligence_operation.clear()
	_update_budget_forecast()
	state_changed.emit()


func set_immigration_openness(value: float) -> void:
	immigration_openness = clampf(value, 0.0, 100.0)
	_update_budget_forecast()
	state_changed.emit()

func set_refugee_acceptance(value: float) -> void:
	refugee_acceptance_rate = clampf(value, 0.0, 100.0)
	_update_budget_forecast()
	state_changed.emit()

func set_citizenship_access(value: float) -> void:
	citizenship_access = clampf(value, 0.0, 100.0)
	state_changed.emit()

func strengthen_border_security() -> bool:
	var cost := maxf(gdp * 0.00045, 18000000.0)
	if treasury < cost or border_security >= 95.0:
		return false
	treasury -= cost
	border_security = minf(100.0, border_security + 8.0)
	integration_capacity = minf(100.0, integration_capacity + 1.5)
	immigration_report = "Border management capacity strengthened."
	state_changed.emit()
	return true

func invest_in_integration() -> bool:
	var cost := maxf(gdp * 0.0005, 22000000.0)
	if treasury < cost or integration_capacity >= 95.0:
		return false
	treasury -= cost
	integration_capacity = minf(100.0, integration_capacity + 10.0)
	immigration_report = "Language, employment and settlement integration capacity improved."
	state_changed.emit()
	return true

func process_citizenship_applications() -> bool:
	if citizenship_applications <= 0 or citizenship_access < 10.0:
		return false
	var approved := mini(citizenship_applications, maxi(1, int(float(citizenship_applications) * citizenship_access / 100.0 * 0.35)))
	var cost := float(approved) * maxf(gdp / maxf(float(population), 1.0) * 0.018, 25.0)
	if treasury < cost:
		return false
	treasury -= cost
	citizenship_applications -= approved
	citizenship_granted += approved
	immigration_report = "%s citizenship applications approved. New citizens: %s." % [_format_trade_units(approved), _format_trade_units(approved)]
	state_changed.emit()
	return true

func set_passport_access(value: float) -> void:
	passport_access = clampf(value, 0.0, 100.0)
	state_changed.emit()

func issue_passports() -> bool:
	var eligible := maxi(0, population - immigrant_population)
	var batch := mini(maxi(0, int(float(eligible) * 0.015 * passport_access / 100.0)), maxi(0, eligible - passports_issued))
	if batch <= 0:
		return false
	var cost := float(batch) * maxf(gdp / maxf(float(population), 1.0) * 0.004, 8.0)
	if treasury < cost:
		return false
	treasury -= cost
	passports_issued += batch
	immigration_report = "%s new passports issued. Total registered passports: %s." % [_format_trade_units(batch), _format_trade_units(passports_issued)]
	state_changed.emit()
	return true


func _initialize_media() -> void:
	media_freedom = 62.0
	media_trust = 54.0
	media_reach = 38.0
	media_literacy = 42.0
	misinformation_pressure = 24.0
	public_polarization = 32.0
	press_safety = 58.0
	media_regulation = 35.0
	media_budget_rate = 0.003
	monthly_media_cost = 0.0
	tv_stations = 2
	newspaper_groups = 3
	digital_networks = 1
	media_report = "Independent and public media institutions established."
	media_campaign_cooldown = 0

func media_investment_cost(kind: String) -> float:
	var multiplier := {"tv": 0.0008, "newspaper": 0.00025, "digital": 0.00055}
	if not multiplier.has(kind):
		return -1.0
	var level := int({"tv": tv_stations, "newspaper": newspaper_groups, "digital": digital_networks}[kind])
	if level >= 30:
		return -1.0
	return maxf(gdp * float(multiplier[kind]) * float(level + 1), 2500000.0)

func invest_in_media(kind: String) -> bool:
	var cost := media_investment_cost(kind)
	if cost < 0.0 or treasury < cost:
		return false
	treasury -= cost
	match kind:
		"tv": tv_stations += 1
		"newspaper": newspaper_groups += 1
		"digital": digital_networks += 1
	media_reach = clampf(media_reach + (3.0 if kind == "digital" else 2.0), 0.0, 100.0)
	media_report = "New %s institution opened. Media reach improved." % kind
	state_changed.emit()
	return true

func set_media_policy(freedom: float, regulation: float, literacy: float, budget: float) -> void:
	media_freedom = clampf(freedom, 0.0, 100.0)
	media_regulation = clampf(regulation, 0.0, 100.0)
	media_literacy = clampf(literacy, 0.0, 100.0)
	media_budget_rate = clampf(budget, 0.001, 0.02)
	_update_budget_forecast()
	state_changed.emit()

func run_media_campaign(kind: String) -> bool:
	if media_campaign_cooldown > 0:
		return false
	var cost := gdp * (0.00035 if kind == "public_info" else (0.0005 if kind == "literacy" else 0.0007))
	if not ["public_info", "literacy", "propaganda"].has(kind) or treasury < cost:
		return false
	treasury -= cost
	media_campaign_cooldown = 2
	if kind == "public_info":
		media_trust = clampf(media_trust + 3.0, 0.0, 100.0)
		government_approval = clampf(government_approval + 1.5, 0.0, 100.0)
		media_report = "Public information campaign improved access to verified public updates."
	elif kind == "literacy":
		media_literacy = clampf(media_literacy + 4.0, 0.0, 100.0)
		misinformation_pressure = clampf(misinformation_pressure - 4.0, 0.0, 100.0)
		public_polarization = clampf(public_polarization - 2.0, 0.0, 100.0)
		media_report = "Media literacy campaign strengthened critical evaluation of information."
	else:
		media_freedom = clampf(media_freedom - 3.0, 0.0, 100.0)
		media_trust = clampf(media_trust - 4.0, 0.0, 100.0)
		public_polarization = clampf(public_polarization + 5.0, 0.0, 100.0)
		government_approval = clampf(government_approval + 1.0, 0.0, 100.0)
		media_report = "State propaganda produced a short-lived approval bump while damaging trust and increasing polarization."
	_update_budget_forecast()
	state_changed.emit()
	return true


func _initialize_public_services() -> void:
	healthcare_budget_rate = 0.035
	education_budget_rate = 0.04
	monthly_healthcare_cost = gdp * healthcare_budget_rate / 12.0
	monthly_education_cost = gdp * education_budget_rate / 12.0
	hospital_capacity = clampf(48.0 + float(infrastructure.get("hospitals", 8)) * 1.3, 20.0, 90.0)
	healthcare_access = clampf(52.0 + float(infrastructure.get("hospitals", 8)) * 1.25, 20.0, 95.0)
	disease_burden = 32.0
	life_expectancy = clampf(65.0 + healthcare_access * 0.12 - disease_burden * 0.04, 55.0, 88.0)
	health_workers = maxi(100, int(float(population) * 0.012))
	school_enrollment = clampf(65.0 + float(infrastructure.get("schools", 10)) * 1.3, 45.0, 98.0)
	adult_literacy = clampf(76.0 + float(infrastructure.get("schools", 10)) * 1.0, 55.0, 99.0)
	education_quality = clampf(42.0 + float(infrastructure.get("schools", 10)) * 1.5, 25.0, 90.0)
	skilled_workforce_share = 38.0
	teachers = maxi(100, int(float(population) * 0.018))
	public_services_report = "Public hospitals, clinics and education institutions are operating."

func set_public_service_budgets(health_rate: float, education_rate: float) -> void:
	healthcare_budget_rate = clampf(health_rate, 0.01, 0.10)
	education_budget_rate = clampf(education_rate, 0.01, 0.12)
	monthly_healthcare_cost = gdp * healthcare_budget_rate / 12.0
	monthly_education_cost = gdp * education_budget_rate / 12.0
	_update_budget_forecast()
	state_changed.emit()

func invest_in_public_service(kind: String) -> bool:
	var cost := 0.0
	if kind == "hospital":
		cost = maxf(gdp * 0.0012 * (1.0 + hospital_capacity / 100.0), 5000000.0)
	elif kind == "school":
		cost = maxf(gdp * 0.0009 * (1.0 + education_quality / 100.0), 3000000.0)
	else:
		return false
	if treasury < cost:
		return false
	treasury -= cost
	if kind == "hospital":
		infrastructure["hospitals"] = int(infrastructure.get("hospitals", 0)) + 1
		hospital_capacity = clampf(hospital_capacity + 3.5, 0.0, 100.0)
		healthcare_access = clampf(healthcare_access + 2.0, 0.0, 100.0)
		health_workers += maxi(250, int(float(population) * 0.0003))
		public_services_report = "A new public hospital opened, expanding capacity and access."
	else:
		infrastructure["schools"] = int(infrastructure.get("schools", 0)) + 1
		education_quality = clampf(education_quality + 3.0, 0.0, 100.0)
		school_enrollment = clampf(school_enrollment + 1.5, 0.0, 100.0)
		teachers += maxi(300, int(float(population) * 0.0004))
		public_services_report = "A new public school opened, improving education capacity."
	_update_budget_forecast()
	state_changed.emit()
	return true

func _run_monthly_public_services() -> void:
	if population <= 0 or gdp <= 0.0:
		return
	monthly_healthcare_cost = gdp * healthcare_budget_rate / 12.0
	monthly_education_cost = gdp * education_budget_rate / 12.0
	var hospital_factor := clampf(float(infrastructure.get("hospitals", 0)) / maxf(float(population) / 1000000.0, 1.0), 0.2, 2.0)
	var school_factor := clampf(float(infrastructure.get("schools", 0)) / maxf(float(population) / 1000000.0, 1.0), 0.2, 2.0)
	healthcare_access = clampf(healthcare_access + (healthcare_budget_rate * 60.0 + hospital_factor * 0.08 - disease_burden * 0.006 - 1.0), 0.0, 100.0)
	hospital_capacity = clampf(hospital_capacity + (healthcare_budget_rate * 40.0 + hospital_factor * 0.06 - 0.7), 0.0, 100.0)
	var pollution_pressure := maxf(0.0, air_pollution - 25.0) * 0.018 + maxf(0.0, water_pollution - 25.0) * 0.012
	disease_burden = clampf(disease_burden + pollution_pressure + (55.0 - healthcare_access) * 0.012 - healthcare_budget_rate * 2.5, 0.0, 100.0)
	life_expectancy = clampf(life_expectancy + (healthcare_access - 60.0) * 0.0015 - disease_burden * 0.0008, 45.0, 90.0)
	school_enrollment = clampf(school_enrollment + (education_budget_rate * 12.0 + school_factor * 0.08 - 0.4), 0.0, 100.0)
	education_quality = clampf(education_quality + education_budget_rate * 8.0 + school_factor * 0.06 - 0.25, 0.0, 100.0)
	adult_literacy = clampf(adult_literacy + (school_enrollment - 75.0) * 0.001 + (education_quality - 50.0) * 0.0008, 0.0, 100.0)
	skilled_workforce_share = clampf(skilled_workforce_share + (education_quality - 50.0) * 0.006 + (school_enrollment - 70.0) * 0.003, 0.0, 100.0)
	var health_staff_need := maxi(1, int(float(population) * 0.012))
	var teacher_need := maxi(1, int(float(population) * 0.018))
	health_workers = maxi(0, int(lerpf(float(health_workers), float(health_staff_need) * clampf(healthcare_access / 75.0, 0.5, 1.3), 0.04)))
	teachers = maxi(0, int(lerpf(float(teachers), float(teacher_need) * clampf(school_enrollment / 80.0, 0.5, 1.3), 0.04)))
	annual_gdp_growth += (skilled_workforce_share - 40.0) * 0.000015
	stability = clampf(stability + (healthcare_access + education_quality - 110.0) * 0.0005, 0.0, 100.0)
	public_services_report = "Health access %.1f • Life expectancy %.1f • School enrollment %.1f%% • Education quality %.1f." % [healthcare_access, life_expectancy, school_enrollment, education_quality]
	_update_budget_forecast()

func _run_monthly_media() -> void:
	if media_campaign_cooldown > 0:
		media_campaign_cooldown -= 1
	monthly_media_cost = gdp * media_budget_rate / 12.0
	var institution_reach := float(tv_stations) * 1.5 + float(newspaper_groups) * 0.7 + float(digital_networks) * 2.2
	media_reach = clampf(media_reach + (institution_reach - 8.0) * 0.025, 0.0, 100.0)
	var trust_change := (media_freedom - 50.0) * 0.012 + (media_literacy - 50.0) * 0.008 + (press_safety - 50.0) * 0.01 - misinformation_pressure * 0.009 - public_polarization * 0.004
	media_trust = clampf(media_trust + trust_change, 0.0, 100.0)
	misinformation_pressure = clampf(misinformation_pressure + (25.0 - media_literacy) * 0.012 + (35.0 - media_regulation) * 0.004 - media_literacy * 0.003, 0.0, 100.0)
	public_polarization = clampf(public_polarization + (misinformation_pressure - 30.0) * 0.008 - (media_literacy - 50.0) * 0.006, 0.0, 100.0)
	press_safety = clampf(press_safety + (media_freedom - press_safety) * 0.015 - maxf(0.0, public_polarization - 65.0) * 0.012, 0.0, 100.0)
	var approval_effect := (media_trust - 50.0) * 0.012 - maxf(0.0, misinformation_pressure - 40.0) * 0.008 - maxf(0.0, public_polarization - 60.0) * 0.006
	government_approval = clampf(government_approval + approval_effect, 5.0, 95.0)
	if media_trust < 25.0 or misinformation_pressure > 75.0:
		stability = clampf(stability - 0.15, 0.0, 100.0)
	media_report = "Trust %.1f • Reach %.1f • Disinformation pressure %.1f • Polarization %.1f." % [media_trust, media_reach, misinformation_pressure, public_polarization]
	_update_budget_forecast()

func _run_monthly_immigration() -> void:
	var arrivals := 0
	var departures := 0
	var refugee_arrivals := 0
	var source_count := maxi(1, ai_countries.size())
	var source_attractiveness := 0.0
	var source_instability := 0.0
	for nation in ai_countries:
		var source_gdp_per_capita := float(nation.get("gdp", 1.0)) / maxf(float(nation.get("population", 1)), 1.0)
		source_attractiveness += clampf(source_gdp_per_capita / maxf(gdp / maxf(float(population), 1.0), 1.0), 0.2, 2.0)
		source_instability += maxf(0.0, 65.0 - float(nation.get("stability", 50.0)))
	source_attractiveness /= float(source_count)
	source_instability /= float(source_count)
	var economic_pull := clampf(0.75 + annual_gdp_growth * 0.035 + (55.0 - unemployment) * 0.006, 0.35, 1.6)
	var openness_factor := immigration_openness / 50.0
	arrivals = int(float(population) * 0.000018 * openness_factor * economic_pull * source_attractiveness)
	refugee_arrivals = int(float(population) * 0.0000008 * refugee_acceptance_rate / 15.0 * clampf(source_instability / 20.0, 0.2, 2.5))
	departures = int(float(population) * 0.000006 * (1.0 - immigration_openness / 120.0) * clampf((unemployment - 4.0) / 8.0 + (50.0 - stability) / 100.0, 0.15, 1.8))
	var admitted := maxi(0, arrivals + refugee_arrivals - int(float(departures) * border_security / 100.0 * 0.35))
	monthly_net_migration = arrivals + refugee_arrivals - departures
	population = maxi(1, population + monthly_net_migration)
	immigrant_population = maxi(0, immigrant_population + admitted - int(float(immigrant_population) * 0.0004))
	foreign_born_share = clampf(float(immigrant_population) / maxf(float(population), 1.0) * 100.0, 0.0, 100.0)
	citizenship_applications += int(float(immigrant_population) * 0.00035 * citizenship_access / 50.0)
	var service_pressure := float(immigrant_population) / maxf(float(population), 1.0) * 100.0
	var integration_gap := maxf(0.0, service_pressure - integration_capacity * 0.45)
	stability = clampf(stability + (integration_capacity - 45.0) * 0.001 - integration_gap * 0.008, 0.0, 100.0)
	monthly_immigration_cost = float(admitted) * maxf(gdp / maxf(float(population), 1.0) * 0.025, 18.0) + gdp * 0.00008 * (refugee_acceptance_rate / 100.0)
	if refugee_arrivals > 0:
		immigration_report = "Monthly arrivals: %s • Refugees admitted: %s • Net migration: %s." % [_format_trade_units(arrivals), _format_trade_units(refugee_arrivals), _format_trade_units(monthly_net_migration)]
	else:
		immigration_report = "Monthly arrivals: %s • Departures: %s • Net migration: %s." % [_format_trade_units(arrivals), _format_trade_units(departures), _format_trade_units(monthly_net_migration)]
	_update_budget_forecast()

func _update_budget_forecast() -> void:
	monthly_revenue = maxf(0.0, gdp) * tax_rate / 12.0 + maxf(0.0, monthly_mining_revenue - monthly_mining_cost) * mining_tax_rate
	monthly_welfare_cost = maxf(0.0, gdp) * social_welfare_rate / 12.0
	monthly_environment_cost = maxf(0.0, gdp) * environment_budget_rate / 12.0
	monthly_expenses = maxf(0.0, gdp) * (spending_rate + defense_budget_rate + social_welfare_rate + research_budget_rate + environment_budget_rate + space_program_budget_rate + intelligence_budget_rate + media_budget_rate + healthcare_budget_rate + education_budget_rate) / 12.0 + monthly_power_cost + monthly_mining_cost + monthly_space_cost + monthly_intelligence_cost + monthly_immigration_cost
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
	infrastructure = {"roads": 12, "power": 10, "ports": 4, "airports": 3, "hospitals": 8, "schools": 10, "housing": 12}
	_initialize_cities(country)
	_initialize_companies()
	_initialize_banking()
	labor_force = maxi(1, int(float(population) * 0.62))
	unemployed_citizens = int(float(labor_force) * unemployment / 100.0)
	employed_citizens = labor_force - unemployed_citizens
	average_monthly_income = gdp / maxf(float(population), 1.0) * 0.62 / 12.0
	poverty_rate = 18.0
	middle_class_share = 65.0
	wealthy_share = 17.0
	income_inequality = 0.36
	household_consumption = gdp * 0.56 / 12.0
	social_welfare_rate = 0.02
	monthly_welfare_cost = gdp * social_welfare_rate / 12.0
	social_mobility = 50.0
	_initialize_public_services()
	_update_budget_forecast()
	transport_routes.clear()
	military_personnel = maxi(50000, int(float(population) * 0.0012))
	tanks = maxi(100, int(gdp / 1800000000.0))
	aircraft = maxi(40, int(gdp / 5500000000.0))
	naval_vessels = maxi(12, int(gdp / 14000000000.0))
	military_readiness = 68.0
	defense_budget_rate = 0.035
	monthly_defense_cost = gdp * defense_budget_rate / 12.0
	_initialize_diplomacy()
	_initialize_government()
	_initialize_research()
	space_agency_level = 1
	space_centers = 0
	operational_satellites = 0
	space_program_budget_rate = 0.004
	monthly_space_cost = 0.0
	active_space_mission.clear()
	space_mission_log.clear()
	space_report = "No national space missions have been launched."
	intelligence_agency_level = 1
	intelligence_budget_rate = 0.006
	intelligence_points = 0.0
	cyber_defense_rating = 30.0 + minf(25.0, float(population) / 10000000.0)
	counterintelligence_rating = 30.0
	national_threat_level = 20.0
	monthly_intelligence_cost = 0.0
	active_intelligence_operation.clear()
	intelligence_operation_log.clear()
	intelligence_report = "National intelligence and cyber security institutions established."
	immigration_openness = 50.0
	refugee_acceptance_rate = 15.0
	citizenship_access = 50.0
	border_security = 55.0
	integration_capacity = 45.0
	immigrant_population = int(float(population) * 0.04)
	foreign_born_share = 4.0
	monthly_net_migration = 0
	monthly_immigration_cost = 0.0
	immigration_report = "Immigration, border and citizenship institutions established."
	citizenship_applications = 0
	citizenship_granted = 0
	passport_access = 60.0
	passports_issued = 0
	_initialize_media()
	_initialize_environment()
	_initialize_energy()
	_initialize_mining()
	_update_budget_forecast()
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
		"trade_tariff_rate": trade_tariff_rate, "last_trade_report": last_trade_report,
		"infrastructure": infrastructure, "cities": cities, "selected_city_id": selected_city_id,
		"transport_routes": transport_routes, "companies": companies, "corporate_tax_rate": corporate_tax_rate, "monthly_corporate_tax": monthly_corporate_tax, "private_sector_jobs": private_sector_jobs,
		"central_bank_rate": central_bank_rate, "reserve_requirement": reserve_requirement,
		"bank_deposits": bank_deposits, "bank_reserves": bank_reserves, "bank_loan_book": bank_loan_book,
		"household_credit": household_credit, "nonperforming_loans": nonperforming_loans,
		"monthly_bank_interest": monthly_bank_interest, "company_loans": company_loans,
		"labor_force": labor_force, "employed_citizens": employed_citizens, "unemployed_citizens": unemployed_citizens,
		"average_monthly_income": average_monthly_income, "poverty_rate": poverty_rate,
		"middle_class_share": middle_class_share, "wealthy_share": wealthy_share,
		"income_inequality": income_inequality, "household_consumption": household_consumption,
		"social_welfare_rate": social_welfare_rate, "monthly_welfare_cost": monthly_welfare_cost,
		"social_mobility": social_mobility,
		"healthcare_budget_rate": healthcare_budget_rate, "education_budget_rate": education_budget_rate,
		"monthly_healthcare_cost": monthly_healthcare_cost, "monthly_education_cost": monthly_education_cost,
		"hospital_capacity": hospital_capacity, "healthcare_access": healthcare_access,
		"life_expectancy": life_expectancy, "disease_burden": disease_burden,
		"health_workers": health_workers, "school_enrollment": school_enrollment,
		"adult_literacy": adult_literacy, "education_quality": education_quality,
		"skilled_workforce_share": skilled_workforce_share, "teachers": teachers,
		"public_services_report": public_services_report,
		"government_type": government_type, "government_approval": government_approval,
		"governing_party_id": governing_party_id, "coalition_party_ids": coalition_party_ids,
		"parliament_seats": parliament_seats, "months_until_election": months_until_election,
		"political_parties": political_parties, "cabinet": cabinet,
		"enacted_laws": enacted_laws, "last_election_report": last_election_report,
		"research_budget_rate": research_budget_rate, "research_labs": research_labs,
		"scientists": scientists, "research_points": research_points,
		"active_research_id": active_research_id, "technology_tree": technology_tree,
		"completed_technologies": completed_technologies, "research_report": research_report,
		"space_agency_level": space_agency_level, "space_centers": space_centers,
		"operational_satellites": operational_satellites, "space_program_budget_rate": space_program_budget_rate,
		"monthly_space_cost": monthly_space_cost, "active_space_mission": active_space_mission,
		"space_mission_log": space_mission_log, "space_report": space_report,
		"intelligence_agency_level": intelligence_agency_level, "intelligence_budget_rate": intelligence_budget_rate,
		"intelligence_points": intelligence_points, "cyber_defense_rating": cyber_defense_rating,
		"counterintelligence_rating": counterintelligence_rating, "national_threat_level": national_threat_level,
		"monthly_intelligence_cost": monthly_intelligence_cost, "active_intelligence_operation": active_intelligence_operation,
		"intelligence_operation_log": intelligence_operation_log, "intelligence_report": intelligence_report,
		"immigration_openness": immigration_openness, "refugee_acceptance_rate": refugee_acceptance_rate,
		"citizenship_access": citizenship_access, "border_security": border_security,
		"integration_capacity": integration_capacity, "immigrant_population": immigrant_population,
		"foreign_born_share": foreign_born_share, "monthly_net_migration": monthly_net_migration,
		"monthly_immigration_cost": monthly_immigration_cost, "immigration_report": immigration_report,
		"citizenship_applications": citizenship_applications, "citizenship_granted": citizenship_granted,
		"passport_access": passport_access, "passports_issued": passports_issued,
		"media_freedom": media_freedom, "media_trust": media_trust, "media_reach": media_reach,
		"media_literacy": media_literacy, "misinformation_pressure": misinformation_pressure,
		"public_polarization": public_polarization, "press_safety": press_safety,
		"media_regulation": media_regulation, "media_budget_rate": media_budget_rate,
		"monthly_media_cost": monthly_media_cost, "tv_stations": tv_stations,
		"newspaper_groups": newspaper_groups, "digital_networks": digital_networks,
		"media_report": media_report, "media_campaign_cooldown": media_campaign_cooldown,
		"environment_budget_rate": environment_budget_rate, "monthly_environment_cost": monthly_environment_cost,
		"carbon_emissions": carbon_emissions, "air_pollution": air_pollution, "water_pollution": water_pollution,
		"forest_cover": forest_cover, "climate_risk": climate_risk, "biodiversity": biodiversity,
		"environmental_quality": environmental_quality, "renewable_energy_share": renewable_energy_share,
		"disaster_resilience": disaster_resilience, "disaster_cooldown": disaster_cooldown,
		"disaster_history": disaster_history, "last_disaster_report": last_disaster_report,
		"power_plants": power_plants, "energy_fuel_reserves": energy_fuel_reserves,
		"grid_capacity": grid_capacity, "energy_demand": energy_demand, "energy_generation": energy_generation,
		"energy_supply_ratio": energy_supply_ratio, "energy_price": energy_price, "blackout_risk": blackout_risk,
		"monthly_power_cost": monthly_power_cost, "regional_power_access": regional_power_access,
		"last_energy_report": last_energy_report,
		"resource_reserves": resource_reserves, "resource_inventory": resource_inventory,
		"resource_market_prices": resource_market_prices, "mining_sites": mining_sites,
		"exploration_count": exploration_count, "resource_production": resource_production,
		"mining_jobs": mining_jobs, "mining_tax_rate": mining_tax_rate,
		"monthly_mining_revenue": monthly_mining_revenue, "monthly_mining_cost": monthly_mining_cost,
		"mining_report": mining_report,
		"regional_funds": regional_funds, "selected_region_name": selected_region_name
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
	infrastructure = data.get("infrastructure", {"roads": 12, "power": 10, "ports": 4, "airports": 3, "hospitals": 8, "schools": 10, "housing": 12})
	cities.clear()
	for city_data in data.get("cities", []):
		if typeof(city_data) == TYPE_DICTIONARY:
			cities.append(city_data)
	selected_city_id = str(data.get("selected_city_id", ""))
	transport_routes.clear()
	for route_data in data.get("transport_routes", []):
		if typeof(route_data) == TYPE_DICTIONARY:
			transport_routes.append(route_data)
	companies.clear()
	for company_data in data.get("companies", []):
		if typeof(company_data) == TYPE_DICTIONARY:
			companies.append(company_data)
	corporate_tax_rate = float(data.get("corporate_tax_rate", 0.18))
	monthly_corporate_tax = float(data.get("monthly_corporate_tax", 0.0))
	private_sector_jobs = int(data.get("private_sector_jobs", 0))
	central_bank_rate = float(data.get("central_bank_rate", 0.045))
	reserve_requirement = float(data.get("reserve_requirement", 0.10))
	bank_deposits = float(data.get("bank_deposits", maxf(gdp * 0.42, 100000000.0)))
	bank_reserves = float(data.get("bank_reserves", bank_deposits * reserve_requirement))
	bank_loan_book = float(data.get("bank_loan_book", 0.0))
	household_credit = float(data.get("household_credit", population * maxf(gdp / maxf(float(population), 1.0) * 0.12, 100.0)))
	nonperforming_loans = float(data.get("nonperforming_loans", 0.0))
	monthly_bank_interest = float(data.get("monthly_bank_interest", 0.0))
	company_loans.clear()
	for loan_data in data.get("company_loans", []):
		if typeof(loan_data) == TYPE_DICTIONARY:
			company_loans.append(loan_data)
	labor_force = int(data.get("labor_force", maxi(1, int(float(population) * 0.62))))
	employed_citizens = int(data.get("employed_citizens", labor_force - int(float(labor_force) * unemployment / 100.0)))
	unemployed_citizens = int(data.get("unemployed_citizens", labor_force - employed_citizens))
	average_monthly_income = float(data.get("average_monthly_income", gdp / maxf(float(population), 1.0) * 0.62 / 12.0))
	poverty_rate = float(data.get("poverty_rate", 18.0))
	middle_class_share = float(data.get("middle_class_share", 65.0))
	wealthy_share = float(data.get("wealthy_share", 17.0))
	income_inequality = float(data.get("income_inequality", 0.36))
	household_consumption = float(data.get("household_consumption", gdp * 0.56 / 12.0))
	social_welfare_rate = float(data.get("social_welfare_rate", 0.02))
	monthly_welfare_cost = float(data.get("monthly_welfare_cost", gdp * social_welfare_rate / 12.0))
	social_mobility = float(data.get("social_mobility", 50.0))
	healthcare_budget_rate = float(data.get("healthcare_budget_rate", 0.035))
	education_budget_rate = float(data.get("education_budget_rate", 0.04))
	monthly_healthcare_cost = float(data.get("monthly_healthcare_cost", gdp * healthcare_budget_rate / 12.0))
	monthly_education_cost = float(data.get("monthly_education_cost", gdp * education_budget_rate / 12.0))
	hospital_capacity = float(data.get("hospital_capacity", 58.0))
	healthcare_access = float(data.get("healthcare_access", 62.0))
	life_expectancy = float(data.get("life_expectancy", 72.0))
	disease_burden = float(data.get("disease_burden", 32.0))
	health_workers = int(data.get("health_workers", int(float(population) * 0.012)))
	school_enrollment = float(data.get("school_enrollment", 78.0))
	adult_literacy = float(data.get("adult_literacy", 86.0))
	education_quality = float(data.get("education_quality", 55.0))
	skilled_workforce_share = float(data.get("skilled_workforce_share", 38.0))
	teachers = int(data.get("teachers", int(float(population) * 0.018)))
	public_services_report = str(data.get("public_services_report", "National health and education services loaded."))
	government_type = str(data.get("government_type", "Constitutional democracy"))
	government_approval = float(data.get("government_approval", 58.0))
	governing_party_id = str(data.get("governing_party_id", ""))
	coalition_party_ids.clear()
	for party_id in data.get("coalition_party_ids", []):
		coalition_party_ids.append(str(party_id))
	parliament_seats = int(data.get("parliament_seats", 300))
	months_until_election = int(data.get("months_until_election", 48))
	political_parties.clear()
	for party_data in data.get("political_parties", []):
		if typeof(party_data) == TYPE_DICTIONARY:
			political_parties.append(party_data)
	cabinet.clear()
	for minister_data in data.get("cabinet", []):
		if typeof(minister_data) == TYPE_DICTIONARY:
			cabinet.append(minister_data)
	enacted_laws.clear()
	for law_id in data.get("enacted_laws", []):
		enacted_laws.append(str(law_id))
	last_election_report = str(data.get("last_election_report", "No election has been held yet."))
	research_budget_rate = float(data.get("research_budget_rate", 0.015))
	research_labs = int(data.get("research_labs", 1))
	scientists = int(data.get("scientists", maxi(500, int(float(population) * 0.00002))))
	research_points = float(data.get("research_points", 0.0))
	active_research_id = str(data.get("active_research_id", ""))
	technology_tree.clear()
	for technology_data in data.get("technology_tree", []):
		if typeof(technology_data) == TYPE_DICTIONARY:
			technology_tree.append(technology_data)
	completed_technologies.clear()
	for technology_id in data.get("completed_technologies", []):
		completed_technologies.append(str(technology_id))
	research_report = str(data.get("research_report", "No technology projects completed yet."))
	space_agency_level = int(data.get("space_agency_level", 1))
	space_centers = int(data.get("space_centers", 0))
	operational_satellites = int(data.get("operational_satellites", 0))
	space_program_budget_rate = float(data.get("space_program_budget_rate", 0.004))
	monthly_space_cost = float(data.get("monthly_space_cost", 0.0))
	active_space_mission = data.get("active_space_mission", {})
	space_mission_log.clear()
	for mission_data in data.get("space_mission_log", []):
		if typeof(mission_data) == TYPE_DICTIONARY:
			space_mission_log.append(mission_data)
	space_report = str(data.get("space_report", "No national space missions have been launched."))
	intelligence_agency_level = int(data.get("intelligence_agency_level", 1))
	intelligence_budget_rate = float(data.get("intelligence_budget_rate", 0.006))
	intelligence_points = float(data.get("intelligence_points", 0.0))
	cyber_defense_rating = float(data.get("cyber_defense_rating", 30.0))
	counterintelligence_rating = float(data.get("counterintelligence_rating", 30.0))
	national_threat_level = float(data.get("national_threat_level", 20.0))
	monthly_intelligence_cost = float(data.get("monthly_intelligence_cost", 0.0))
	active_intelligence_operation = data.get("active_intelligence_operation", {})
	intelligence_operation_log.clear()
	for operation_data in data.get("intelligence_operation_log", []):
		if typeof(operation_data) == TYPE_DICTIONARY:
			intelligence_operation_log.append(operation_data)
	intelligence_report = str(data.get("intelligence_report", "No intelligence operations have been conducted."))
	immigration_openness = float(data.get("immigration_openness", 50.0))
	refugee_acceptance_rate = float(data.get("refugee_acceptance_rate", 15.0))
	citizenship_access = float(data.get("citizenship_access", 50.0))
	border_security = float(data.get("border_security", 55.0))
	integration_capacity = float(data.get("integration_capacity", 45.0))
	immigrant_population = int(data.get("immigrant_population", int(float(population) * 0.04)))
	foreign_born_share = float(data.get("foreign_born_share", float(immigrant_population) / maxf(float(population), 1.0) * 100.0))
	monthly_net_migration = int(data.get("monthly_net_migration", 0))
	monthly_immigration_cost = float(data.get("monthly_immigration_cost", 0.0))
	immigration_report = str(data.get("immigration_report", "No migration report available."))
	citizenship_applications = int(data.get("citizenship_applications", 0))
	citizenship_granted = int(data.get("citizenship_granted", 0))
	passport_access = float(data.get("passport_access", 60.0))
	passports_issued = int(data.get("passports_issued", 0))
	media_freedom = float(data.get("media_freedom", 62.0))
	media_trust = float(data.get("media_trust", 54.0))
	media_reach = float(data.get("media_reach", 38.0))
	media_literacy = float(data.get("media_literacy", 42.0))
	misinformation_pressure = float(data.get("misinformation_pressure", 24.0))
	public_polarization = float(data.get("public_polarization", 32.0))
	press_safety = float(data.get("press_safety", 58.0))
	media_regulation = float(data.get("media_regulation", 35.0))
	media_budget_rate = float(data.get("media_budget_rate", 0.003))
	monthly_media_cost = float(data.get("monthly_media_cost", 0.0))
	tv_stations = int(data.get("tv_stations", 2))
	newspaper_groups = int(data.get("newspaper_groups", 3))
	digital_networks = int(data.get("digital_networks", 1))
	media_report = str(data.get("media_report", "National media institutions established."))
	media_campaign_cooldown = int(data.get("media_campaign_cooldown", 0))
	environment_budget_rate = float(data.get("environment_budget_rate", 0.012))
	monthly_environment_cost = float(data.get("monthly_environment_cost", 0.0))
	carbon_emissions = float(data.get("carbon_emissions", maxf(1.0, float(population) / 1000000.0 * 0.42)))
	air_pollution = float(data.get("air_pollution", 35.0))
	water_pollution = float(data.get("water_pollution", 28.0))
	forest_cover = float(data.get("forest_cover", 32.0))
	climate_risk = float(data.get("climate_risk", 24.0))
	biodiversity = float(data.get("biodiversity", 65.0))
	environmental_quality = float(data.get("environmental_quality", 62.0))
	renewable_energy_share = float(data.get("renewable_energy_share", 18.0))
	disaster_resilience = float(data.get("disaster_resilience", 42.0))
	disaster_cooldown = int(data.get("disaster_cooldown", 0))
	disaster_history.clear()
	for disaster_data in data.get("disaster_history", []):
		if typeof(disaster_data) == TYPE_DICTIONARY:
			disaster_history.append(disaster_data)
	last_disaster_report = str(data.get("last_disaster_report", "No major natural disasters recorded."))
	power_plants.clear()
	for plant_data in data.get("power_plants", []):
		if typeof(plant_data) == TYPE_DICTIONARY:
			power_plants.append(plant_data)
	energy_fuel_reserves = data.get("energy_fuel_reserves", {"coal": 0.0, "gas": 0.0, "uranium": 0.0})
	grid_capacity = float(data.get("grid_capacity", 0.0))
	energy_demand = float(data.get("energy_demand", 0.0))
	energy_generation = float(data.get("energy_generation", 0.0))
	energy_supply_ratio = float(data.get("energy_supply_ratio", 1.0))
	energy_price = float(data.get("energy_price", 1200.0))
	blackout_risk = float(data.get("blackout_risk", 5.0))
	monthly_power_cost = float(data.get("monthly_power_cost", 0.0))
	regional_power_access = data.get("regional_power_access", {})
	last_energy_report = str(data.get("last_energy_report", "National grid operating normally."))
	resource_reserves = data.get("resource_reserves", {})
	resource_inventory = data.get("resource_inventory", {})
	resource_market_prices = data.get("resource_market_prices", {})
	mining_sites.clear()
	for mine_data in data.get("mining_sites", []):
		if typeof(mine_data) == TYPE_DICTIONARY:
			mining_sites.append(mine_data)
	exploration_count = data.get("exploration_count", {})
	resource_production = data.get("resource_production", {})
	mining_jobs = int(data.get("mining_jobs", 0))
	mining_tax_rate = float(data.get("mining_tax_rate", 0.08))
	monthly_mining_revenue = float(data.get("monthly_mining_revenue", 0.0))
	monthly_mining_cost = float(data.get("monthly_mining_cost", 0.0))
	mining_report = str(data.get("mining_report", "No mining operations established."))
	if resource_reserves.is_empty() and not selected_country.is_empty():
		_initialize_mining()
	if power_plants.is_empty() and not selected_country.is_empty():
		_initialize_energy()
	if technology_tree.is_empty():
		_initialize_research()
	if political_parties.is_empty() or cabinet.is_empty():
		_initialize_government()
	if companies.is_empty() and not cities.is_empty():
	regional_funds = data.get("regional_funds", {})
	selected_region_name = str(data.get("selected_region_name", ""))
	if cities.is_empty() and not selected_country.is_empty():
		_initialize_cities(selected_country)
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
