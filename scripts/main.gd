extends Control

const BG := Color("#091321")
const PANEL := Color("#111f30")
const PANEL_ALT := Color("#17283b")
const BORDER := Color("#263d52")
const TEXT := Color("#edf4fa")
const MUTED := Color("#8da4b8")
const BLUE := Color("#3988f5")
const CYAN := Color("#29d6e8")
const GREEN := Color("#26c99a")
const GOLD := Color("#d6ad55")

var content: Control
var toast_label: Label
var country_list: VBoxContainer
var selected_country: Dictionary = {}
var current_screen: String = "home"
var country_search_text: String = ""
var country_results: VBoxContainer
var selected_diplomacy_id: String = ""

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_show_home()

func _on_viewport_resized() -> void:
	if is_inside_tree():
		match current_screen:
			"home": _show_home()
			"countries": _show_country_select()
			"dashboard": _show_dashboard()
			"budget": _show_budget()
			"world": _show_world_nations()
			"diplomacy": _show_diplomacy()
			"diplomacy_detail": _show_diplomacy_detail()
			"military": _show_military()
			"industry": _show_industry()
			"trade": _show_trade()
			"infrastructure": _show_infrastructure()
			"cities": _show_cities()

func _clear() -> void:
	for child in get_children():
		child.queue_free()
	content = null
	toast_label = null

func _base(title: String, subtitle: String) -> VBoxContainer:
	_clear()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 76
	header.add_theme_constant_override("separation", 18)
	header.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 0, 0))
	root.add_child(header)
	var brand := Label.new()
	brand.text = "WN  /  WORLD NATION SIMULATOR"
	brand.add_theme_font_size_override("font_size", 18)
	brand.add_theme_color_override("font_color", CYAN)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	var status := Label.new()
	status.text = "OFFLINE  •  PHASE 01"
	status.add_theme_color_override("font_color", GREEN)
	status.add_theme_font_size_override("font_size", 11)
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(status)
	var body := VBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	body.add_theme_stylebox_override("panel", _style(BG, BG, 0, 0))
	body.add_theme_constant_override("margin_left", 28)
	body.add_theme_constant_override("margin_right", 28)
	body.add_theme_constant_override("margin_top", 22)
	body.add_theme_constant_override("margin_bottom", 18)
	root.add_child(body)
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", 28)
	heading.add_theme_color_override("font_color", TEXT)
	body.add_child(heading)
	var sub := Label.new()
	sub.text = subtitle
	sub.add_theme_font_size_override("font_size", 12)
	sub.add_theme_color_override("font_color", MUTED)
	body.add_child(sub)
	content = body
	return body

func _show_home() -> void:
	current_screen = "home"
	var body := _base("Build your world.", "A living world simulation. Shape nations, economies and cities.")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 245)
	card.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 18))
	body.add_child(card)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	card.add_child(inner)
	var eyebrow := Label.new()
	eyebrow.text = "YOUR NEXT CHAPTER"
	eyebrow.add_theme_color_override("font_color", CYAN)
	eyebrow.add_theme_font_size_override("font_size", 11)
	inner.add_child(eyebrow)
	var tagline := Label.new()
	tagline.text = "One planet. Hundreds of nations.\nYour decisions shape the future."
	tagline.add_theme_font_size_override("font_size", 25)
	tagline.add_theme_color_override("font_color", TEXT)
	inner.add_child(tagline)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	inner.add_child(row)
	row.add_child(_button("NEW CAREER", BLUE, func(): GameState.game_mode = "Career"; _show_country_select()))
	row.add_child(_button("SANDBOX", GREEN, func(): GameState.game_mode = "Sandbox"; _show_country_select()))
	var continue_button := _button("CONTINUE SAVE", PANEL_ALT, _continue_game)
	row.add_child(continue_button)
	var footer := Label.new()
	footer.text = "GODOT 4  •  SINGLE PLAYER  •  LOCAL SAVE"
	footer.add_theme_color_override("font_color", MUTED)
	footer.add_theme_font_size_override("font_size", 10)
	body.add_child(footer)
	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(bottom_spacer)

func _show_country_select() -> void:
	current_screen = "countries"
	var body := _base("Choose your nation", "Career begins in 2026. Select a country to start the simulation.")
	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 18)
	body.add_child(split)
	var left := PanelContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 14))
	split.add_child(left)
	var list_scroll := ScrollContainer.new()
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(list_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	list_scroll.add_child(list)
	var list_title := Label.new()
	list_title.text = "COUNTRY DATABASE  •  %d NATIONS / AREAS" % GameState.country_catalog.size()
	list_title.add_theme_color_override("font_color", CYAN)
	list_title.add_theme_font_size_override("font_size", 11)
	list.add_child(list_title)
	var search := LineEdit.new()
	search.placeholder_text = "Search country or ISO code..."
	search.text = country_search_text
	search.clear_button_enabled = true
	search.text_changed.connect(_on_country_search_changed)
	list.add_child(search)
	country_results = VBoxContainer.new()
	country_results.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	country_results.add_theme_constant_override("separation", 7)
	list.add_child(country_results)
	_populate_country_results()

	var right := PanelContainer.new()
	right.custom_minimum_size.x = 340
	right.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 14))
	split.add_child(right)
	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 12)
	right.add_child(detail)
	var hint := Label.new()
	hint.text = "COUNTRY PROFILE"
	hint.add_theme_color_override("font_color", GOLD)
	detail.add_child(hint)
	var chosen := selected_country if not selected_country.is_empty() else (GameState.country_catalog[0] if not GameState.country_catalog.is_empty() else {})
	if chosen.is_empty():
		detail.add_child(_muted_label("Country database could not be loaded."))
		return
	var name := Label.new()
	name.text = "%s %s" % [chosen["flag"], chosen["name"]]
	name.add_theme_font_size_override("font_size", 22)
	name.add_theme_color_override("font_color", TEXT)
	detail.add_child(name)
	detail.add_child(_muted_label("Capital: %s" % chosen["capital"]))
	detail.add_child(_muted_label("Population: %s" % _format_number(int(chosen["population"]))))
	detail.add_child(_muted_label("GDP: %s" % _money(float(chosen["gdp"]))))
	detail.add_child(_muted_label("Currency: %s" % chosen.get("currency", "Not listed")))
	detail.add_child(_muted_label("Source baseline: Natural Earth / approx. 2019"))
	detail.add_child(_muted_label("Some capitals and currencies are not yet catalogued."))
	var launch := _button("START SIMULATION  →", BLUE, func(): _start_selected(chosen))
	detail.add_child(launch)
	detail.add_child(_button("BACK", PANEL_ALT, _show_home))

func _on_country_search_changed(value: String) -> void:
	country_search_text = value
	_populate_country_results()

func _populate_country_results() -> void:
	if country_results == null or not is_instance_valid(country_results):
		return
	for child in country_results.get_children():
		child.queue_free()
	var query := country_search_text.strip_edges().to_lower()
	var matches := 0
	for country in GameState.country_catalog:
		var haystack := ("%s %s %s" % [country.name, country.id, country.region]).to_lower()
		if not query.is_empty() and not haystack.contains(query):
			continue
		var item := _button("%s   %s   •   %s" % [country.flag, country.name, country.region], PANEL_ALT, func(c: Dictionary = country): _select_country(c))
		item.custom_minimum_size.y = 42
		country_results.add_child(item)
		matches += 1
	if matches == 0:
		country_results.add_child(_muted_label("No matching country found."))

func _select_country(country: Dictionary) -> void:
	selected_country = country.duplicate(true)
	_show_country_select()

func _start_selected(country: Dictionary) -> void:
	GameState.start_new_game(GameState.game_mode, country)
	_show_dashboard()

func _continue_game() -> void:
	if GameState.load_game():
		selected_country = GameState.selected_country
		_show_dashboard()
	else:
		_show_country_select()
		_show_toast("No valid local save found. Start a new game.")

func _show_dashboard() -> void:
	current_screen = "dashboard"
	var country: Dictionary = GameState.selected_country
	if country.is_empty():
		_show_country_select()
		return
	var body := _base("%s  %s" % [country.get("flag", ""), country.get("name", "Nation")], "NATIONAL OVERVIEW  /  %s  /  %s" % [country.get("capital", ""), GameState.game_mode.to_upper()])
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 10)
	body.add_child(toolbar)
	var date_label := Label.new()
	date_label.text = "📅  %s" % GameState.formatted_date()
	date_label.add_theme_color_override("font_color", TEXT)
	toolbar.add_child(date_label)
	toolbar.add_spacer(false)
	toolbar.add_child(_button("Ⅱ  PAUSE" if not GameState.is_paused else "▶  RESUME", PANEL_ALT, _toggle_pause))
	for speed in [1, 2, 5, 10]:
		toolbar.add_child(_button("%dx" % speed, BLUE if GameState.simulation_speed == speed else PANEL_ALT, func(s: int = speed): GameState.simulation_speed = s; GameState.is_paused = false; _show_dashboard()))
	toolbar.add_child(_button("SAVE", GREEN, _save_game))
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 10)
	body.add_child(stats)
	stats.add_child(_stat_card("POPULATION", _format_number(GameState.population), "NATIONAL RESIDENTS"))
	stats.add_child(_stat_card("GDP", _money(GameState.gdp), "NATIONAL OUTPUT"))
	stats.add_child(_stat_card("TREASURY", _money(GameState.treasury), "AVAILABLE FUNDS"))
	stats.add_child(_stat_card("INFLATION", "%.1f%%" % GameState.inflation, "ANNUAL"))
	stats.add_child(_stat_card("UNEMPLOYMENT", "%.1f%%" % GameState.unemployment, "LABOR MARKET"))
	stats.add_child(_stat_card("PUBLIC DEBT", _money(GameState.debt), "GOVERNMENT LIABILITIES"))
	stats.add_child(_stat_card("GDP GROWTH", "%.1f%%" % GameState.annual_gdp_growth, "ANNUAL ESTIMATE"))
	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 12)
	body.add_child(main_row)
	var map_panel := PanelContainer.new()
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	main_row.add_child(map_panel)
	var map_column := VBoxContainer.new()
	map_panel.add_child(map_column)
	var map_title := Label.new()
	map_title.text = "WORLD INTELLIGENCE"
	map_title.add_theme_color_override("font_color", CYAN)
	map_title.add_theme_font_size_override("font_size", 11)
	map_column.add_child(map_title)
	var map := Control.new()
	map.set_script(load("res://scripts/world_map.gd"))
	map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_column.add_child(map)
	map.connect("country_selected", Callable(self, "_on_map_country_selected"))
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 250
	side.add_theme_constant_override("separation", 8)
	main_row.add_child(side)
	side.add_child(_section_label("GOVERNMENT"))
	side.add_child(_button("National budget", PANEL_ALT, _show_budget))
	side.add_child(_button("World nations / AI", PANEL_ALT, _show_world_nations))
	side.add_child(_action_button("Cabinet & ministries", "Government simulation coming in Phase 2"))
	side.add_child(_button("Diplomacy & foreign affairs", PANEL_ALT, _show_diplomacy))
	side.add_child(_button("Military & defense", PANEL_ALT, _show_military))
	side.add_child(_section_label("DEVELOPMENT"))
	side.add_child(_button("Infrastructure", PANEL_ALT, _show_infrastructure))
	side.add_child(_button("City & regional management", PANEL_ALT, _show_cities))
	side.add_child(_button("Industry & trade", PANEL_ALT, _show_industry))
	side.add_child(_button("International trade", PANEL_ALT, _show_trade))
	side.add_child(_action_button("Research", "Technology tree coming in Phase 2"))
	side.add_child(_button("MAIN MENU", PANEL_ALT, _show_home))
	var note := Label.new()
	note.text = "Monthly economic simulation • 177 mapped features • historical baseline estimates (2019)."
	note.add_theme_color_override("font_color", MUTED)
	note.add_theme_font_size_override("font_size", 10)
	body.add_child(note)
	GameState.state_changed.connect(_refresh_dashboard, CONNECT_ONE_SHOT)

func _show_world_nations() -> void:
	current_screen = "world"
	var body := _base("World nations", "AI-controlled countries • monthly simulation • %d nations" % GameState.ai_countries.size())
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 6)
	scroll.add_child(rows)
	var nations := GameState.ai_countries.duplicate(true)
	nations.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.get("gdp", 0.0)) > float(b.get("gdp", 0.0)))
	for nation in nations:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 8))
		rows.add_child(row)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 12)
		row.add_child(line)
		var identity := Label.new()
		identity.text = "%s  %s  •  %s" % [nation.get("flag", "🏳"), nation.get("name", "Unknown"), nation.get("id", "")]
		identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		identity.add_theme_color_override("font_color", TEXT)
		line.add_child(identity)
		var economy := Label.new()
		economy.text = "GDP %s   •   Growth %.1f%%   •   Inflation %.1f%%" % [_money(float(nation.get("gdp", 0.0))), float(nation.get("growth", 0.0)), float(nation.get("inflation", 0.0))]
		economy.add_theme_color_override("font_color", MUTED)
		line.add_child(economy)
		var people := Label.new()
		people.text = "Pop. %s   •   Stability %.0f" % [_format_number(int(nation.get("population", 0))), float(nation.get("stability", 0.0))]
		people.add_theme_color_override("font_color", GREEN)
		line.add_child(people)
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_trade() -> void:
	current_screen = "trade"
	var body := _base("International trade", "Trade resources with nations that have an active diplomatic trade agreement.")
	var summary := HBoxContainer.new()
	summary.add_theme_constant_override("separation", 10)
	body.add_child(summary)
	summary.add_child(_stat_card("EXPORTS", _money(GameState.trade_exports), "CUMULATIVE VALUE"))
	summary.add_child(_stat_card("IMPORTS", _money(GameState.trade_imports), "CUMULATIVE VALUE"))
	summary.add_child(_stat_card("TRADE BALANCE", _money(GameState.trade_balance), "EXPORTS MINUS IMPORTS"))
	var market := PanelContainer.new()
	market.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(market)
	var market_column := VBoxContainer.new()
	market_column.add_theme_constant_override("separation", 7)
	market.add_child(market_column)
	market_column.add_child(_section_label("WORLD COMMODITY MARKET"))
	for key in ["food", "energy", "metals", "goods"]:
		market_column.add_child(_muted_label("%s  •  %s per unit  •  Stockpile: %s" % [str(key).capitalize(), _money(float(GameState.market_prices.get(key, 0.0))), _format_number(int(GameState.resource_stockpiles.get(key, 0.0)))]))
	var policy := PanelContainer.new()
	policy.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(policy)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	policy.add_child(controls)
	controls.add_child(_section_label("TRADE POLICY"))
	var tariff_label := _muted_label("Import tariff: %.1f%%" % (GameState.trade_tariff_rate * 100.0))
	controls.add_child(tariff_label)
	var tariff_slider := HSlider.new()
	tariff_slider.min_value = 0
	tariff_slider.max_value = 30
	tariff_slider.step = 1
	tariff_slider.value = GameState.trade_tariff_rate * 100.0
	tariff_slider.value_changed.connect(func(value: float): tariff_label.text = "Import tariff: %.1f%%" % value)
	controls.add_child(tariff_slider)
	controls.add_child(_button("APPLY TARIFF", BLUE, func(): GameState.set_trade_tariff(tariff_slider.value / 100.0); _show_trade()))
	var partner_picker := OptionButton.new()
	var trade_partners: Array[Dictionary] = []
	for nation in GameState.ai_countries:
		var treaty: Dictionary = GameState.get_diplomacy(str(nation.get("id", "")))
		if bool(treaty.get("trade_agreement", false)) and not bool(treaty.get("at_war", false)) and not bool(treaty.get("sanctions", false)):
			partner_picker.add_item("%s %s" % [nation.get("flag", "🏳"), nation.get("name", "Unknown")])
			trade_partners.append(nation)
	if trade_partners.is_empty():
		partner_picker.add_item("No active trade partners")
	partner_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_section_label("TRADE TRANSACTION"))
	body.add_child(partner_picker)
	var commodity_picker := OptionButton.new()
	for key in ["food", "energy", "metals", "goods"]:
		commodity_picker.add_item(str(key).capitalize())
	body.add_child(commodity_picker)
	var direction_picker := OptionButton.new()
	direction_picker.add_item("Export to partner")
	direction_picker.add_item("Import from partner")
	body.add_child(direction_picker)
	var units_input := SpinBox.new()
	units_input.min_value = 1
	units_input.max_value = 1000000
	units_input.step = 100
	units_input.value = 1000
	units_input.prefix = "Units: "
	body.add_child(units_input)
	var execute := _button("EXECUTE TRADE", GREEN, func():
		if trade_partners.is_empty():
			_show_toast("No active trade agreement. Establish one in Diplomacy first.")
			return
		var partner: Dictionary = trade_partners[partner_picker.selected]
		var commodity := ["food", "energy", "metals", "goods"][commodity_picker.selected]
		var direction := "export" if direction_picker.selected == 0 else "import"
		if GameState.trade_with_country(str(partner.get("id", "")), commodity, direction, units_input.value):
			_show_trade()
		else:
			_show_toast("Trade failed: check agreement, stockpile, treasury or transaction size.")
	)
	body.add_child(execute)
	body.add_child(_muted_label("Last transaction: %s" % GameState.last_trade_report))
	body.add_child(_muted_label("Prices are simulated index values; tariffs apply to imports. AI counterparties settle against their simulated treasury. Trade is currently player-initiated, not autonomous AI market activity."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_industry() -> void:
	current_screen = "industry"
	var body := _base("Industry & resources", "National production, industrial capacity, employment and strategic stockpiles.")
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 10)
	body.add_child(stats)
	stats.add_child(_stat_card("FACTORIES", _format_number(GameState.factory_count), "INDUSTRIAL FACILITIES"))
	stats.add_child(_stat_card("INDUSTRIAL OUTPUT", _money(GameState.industrial_output), "MONTHLY VALUE ADDED"))
	stats.add_child(_stat_card("INDUSTRIAL JOBS", _format_number(GameState.industrial_jobs), "ESTIMATED WORKFORCE"))
	var capacity_panel := PanelContainer.new()
	capacity_panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(capacity_panel)
	var capacity_column := VBoxContainer.new()
	capacity_column.add_theme_constant_override("separation", 8)
	capacity_panel.add_child(capacity_column)
	capacity_column.add_child(_section_label("INDUSTRIAL CAPACITY"))
	capacity_column.add_child(_muted_label("Capacity: %.1f%% of national GDP base" % (GameState.industrial_capacity * 100.0)))
	capacity_column.add_child(_muted_label("Average monthly output per industrial worker: %s" % _money(GameState.average_industrial_wage)))
	capacity_column.add_child(_muted_label("Factories consume energy and metals; output is reduced when strategic inputs run out."))
	var resources := PanelContainer.new()
	resources.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(resources)
	var resource_column := VBoxContainer.new()
	resource_column.add_theme_constant_override("separation", 8)
	resources.add_child(resource_column)
	resource_column.add_child(_section_label("NATIONAL RESOURCE STOCKPILES"))
	for key in ["food", "energy", "metals", "goods"]:
		resource_column.add_child(_muted_label("%s: %s units" % [str(key).capitalize(), _format_number(int(GameState.resource_stockpiles.get(key, 0.0)))]))
	resource_column.add_child(_muted_label("Stockpiles are abstract simulation units, not real-world tonnes."))
	var investment_cost := maxf(GameState.gdp * 0.002, 100000000.0)
	body.add_child(_button("BUILD FACTORY  •  %s" % _money(investment_cost), GREEN, func():
		if GameState.invest_in_factory():
			_show_industry()
		else:
			_show_toast("Factory investment unavailable: insufficient treasury or factory limit reached.")
	))
	body.add_child(_muted_label("Each factory increases capacity by 1.2 percentage points, creates jobs and costs 0.2% of GDP (minimum $100M)."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_military() -> void:
	current_screen = "military"
	var body := _base("Military & defense", "Armed forces, readiness, equipment procurement and defense funding.")
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 10)
	body.add_child(stats)
	stats.add_child(_stat_card("ACTIVE PERSONNEL", _format_number(GameState.military_personnel), "SERVICE MEMBERS"))
	stats.add_child(_stat_card("MILITARY READINESS", "%.0f%%" % GameState.military_readiness, "OPERATIONAL READINESS"))
	stats.add_child(_stat_card("MILITARY POWER", _format_number(int(GameState.military_strength())), "COMPOSITE INDEX"))
	var equipment := PanelContainer.new()
	equipment.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(equipment)
	var equipment_column := VBoxContainer.new()
	equipment_column.add_theme_constant_override("separation", 10)
	equipment.add_child(equipment_column)
	equipment_column.add_child(_section_label("FORCE STRUCTURE"))
	equipment_column.add_child(_muted_label("Main battle tanks: %s" % _format_number(GameState.tanks)))
	equipment_column.add_child(_muted_label("Military aircraft: %s" % _format_number(GameState.aircraft)))
	equipment_column.add_child(_muted_label("Naval vessels: %s" % _format_number(GameState.naval_vessels)))
	equipment_column.add_child(_muted_label("Monthly defense cost: %s" % _money(GameState.monthly_defense_cost)))
	var policy := PanelContainer.new()
	policy.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(policy)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	policy.add_child(controls)
	controls.add_child(_section_label("DEFENSE BUDGET"))
	var defense_label := _muted_label("Defense allocation: %.1f%% of GDP" % (GameState.defense_budget_rate * 100.0))
	controls.add_child(defense_label)
	var slider := HSlider.new()
	slider.min_value = 2
	slider.max_value = 12
	slider.step = 0.5
	slider.value = GameState.defense_budget_rate * 100.0
	slider.value_changed.connect(func(value: float): defense_label.text = "Defense allocation: %.1f%% of GDP" % value)
	controls.add_child(slider)
	controls.add_child(_muted_label("Higher funding improves readiness over time but increases monthly government expenses."))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	body.add_child(actions)
	actions.add_child(_button("APPLY DEFENSE BUDGET", BLUE, func(): GameState.set_defense_budget(slider.value / 100.0); _show_military()))
	actions.add_child(_button("RECRUIT 10,000", GREEN, func():
		if GameState.recruit_personnel():
			_show_military()
		else:
			_show_toast("Recruitment unavailable: insufficient funds or personnel cap reached.")
	))
	actions.add_child(_button("PROCURE EQUIPMENT", GOLD, func():
		if GameState.procure_equipment():
			_show_military()
		else:
			_show_toast("Insufficient treasury for equipment procurement.")
	))
	body.add_child(_muted_label("Procurement adds 80 tanks, 24 aircraft and 8 naval vessels. Recruitment and procurement are charged immediately."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_diplomacy() -> void:
	current_screen = "diplomacy"
	var body := _base("Diplomacy & foreign affairs", "Manage bilateral relations, trade agreements, alliances, sanctions and war.")
	var summary := HBoxContainer.new()
	summary.add_theme_constant_override("separation", 10)
	body.add_child(summary)
	var trade_count := 0
	var alliance_count := 0
	var war_count := 0
	for relation_value in GameState.diplomacy_relations.values():
		var relation: Dictionary = relation_value
		if bool(relation.get("trade_agreement", false)):
			trade_count += 1
		if bool(relation.get("alliance", false)):
			alliance_count += 1
		if bool(relation.get("at_war", false)):
			war_count += 1
	summary.add_child(_stat_card("TRADE PARTNERS", str(trade_count), "ACTIVE AGREEMENTS"))
	summary.add_child(_stat_card("ALLIANCES", str(alliance_count), "DEFENSE PARTNERS"))
	summary.add_child(_stat_card("ACTIVE WARS", str(war_count), "MILITARY CONFLICTS"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 6)
	scroll.add_child(rows)
	var nations := GameState.ai_countries.duplicate(true)
	nations.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: Dictionary = GameState.get_diplomacy(str(a.get("id", "")))
		var rb: Dictionary = GameState.get_diplomacy(str(b.get("id", "")))
		return float(ra.get("relation", 0.0)) > float(rb.get("relation", 0.0))
	)
	for nation in nations:
		var nation_id := str(nation.get("id", ""))
		var relation: Dictionary = GameState.get_diplomacy(nation_id)
		var status := _diplomacy_status(relation)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		rows.add_child(line)
		var identity := Label.new()
		identity.text = "%s  %s  (%s)" % [nation.get("flag", "🏳"), nation.get("name", "Unknown"), nation_id]
		identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		identity.add_theme_color_override("font_color", TEXT)
		line.add_child(identity)
		var score := Label.new()
		score.text = "%s  •  %+.0f" % [status, float(relation.get("relation", 0.0))]
		score.custom_minimum_size.x = 150
		score.add_theme_color_override("font_color", GOLD if status == "ALLIED" else (GREEN if status == "FRIENDLY" else MUTED))
		line.add_child(score)
		var open := _button("MANAGE", BLUE, func(id: String = nation_id): _open_diplomacy_detail(id))
		open.custom_minimum_size.x = 110
		line.add_child(open)
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _open_diplomacy_detail(country_id: String) -> void:
	selected_diplomacy_id = country_id
	_show_diplomacy_detail()

func _diplomacy_status(relation: Dictionary) -> String:
	if bool(relation.get("at_war", false)):
		return "AT WAR"
	if bool(relation.get("alliance", false)):
		return "ALLIED"
	if bool(relation.get("sanctions", false)):
		return "SANCTIONED"
	var score := float(relation.get("relation", 0.0))
	if score >= 50.0:
		return "FRIENDLY"
	if score <= -35.0:
		return "HOSTILE"
	return "NEUTRAL"

func _show_diplomacy_detail() -> void:
	current_screen = "diplomacy_detail"
	var nation := GameState.get_ai_country(selected_diplomacy_id)
	var relation := GameState.get_diplomacy(selected_diplomacy_id)
	if nation.is_empty() or relation.is_empty():
		_show_diplomacy()
		return
	var body := _base("%s  %s" % [nation.get("flag", "🏳"), nation.get("name", "Nation")], "BILATERAL RELATIONS  /  FOREIGN AFFAIRS")
	body.add_child(_stat_card("RELATIONSHIP", "%+.0f / 100" % float(relation.get("relation", 0.0)), _diplomacy_status(relation)))
	body.add_child(_muted_label("Capital: %s  •  GDP: %s  •  Population: %s" % [nation.get("capital", "Not listed"), _money(float(nation.get("gdp", 0.0))), _format_number(int(nation.get("population", 0)))]))
	body.add_child(_muted_label("Trade agreement: %s  •  Alliance: %s" % ["ACTIVE" if relation.get("trade_agreement", false) else "NONE", "ACTIVE" if relation.get("alliance", false) else "NONE"]))
	body.add_child(_muted_label("Sanctions: %s  •  War: %s" % ["ACTIVE" if relation.get("sanctions", false) else "NONE", "ACTIVE" if relation.get("at_war", false) else "NONE"]))
	body.add_child(_section_label("DIPLOMATIC ACTIONS"))
	body.add_child(_button("Improve relations  •  cost %s" % _money(maxf(GameState.gdp * 0.00015, 100000.0)), GREEN, func():
		if GameState.improve_relations(selected_diplomacy_id):
			_show_diplomacy_detail()
		else:
			_show_toast("Action unavailable: check treasury or war status.")
	))
	body.add_child(_button("Establish trade agreement", BLUE, func():
		if GameState.establish_trade_agreement(selected_diplomacy_id):
			_show_diplomacy_detail()
		else:
			_show_toast("Trade requires relation above -20 and no war or sanctions.")
	))
	body.add_child(_button("Form alliance", GOLD, func():
		if GameState.establish_alliance(selected_diplomacy_id):
			_show_diplomacy_detail()
		else:
			_show_toast("Alliance requires a trade pact and relation of at least +50.")
	))
	body.add_child(_button("Impose economic sanctions", PANEL_ALT, func():
		if GameState.impose_sanctions(selected_diplomacy_id):
			_show_diplomacy_detail()
		else:
			_show_toast("Sanctions cannot be imposed during war.")
	))
	body.add_child(_button("Declare war", Color("#873d49"), func():
		if GameState.declare_war(selected_diplomacy_id):
			_show_diplomacy_detail()
		else:
			_show_toast("War action unavailable.")
	))
	if bool(relation.get("at_war", false)):
		body.add_child(_button("Negotiate peace", GREEN, func():
			GameState.make_peace(selected_diplomacy_id)
			_show_diplomacy_detail()
		))
	body.add_child(_button("BACK TO DIPLOMACY", PANEL_ALT, _show_diplomacy))

func _show_budget() -> void:
	current_screen = "budget"
	var country: Dictionary = GameState.selected_country
	var body := _base("National budget", "%s  /  Fiscal policy and monthly public finances" % country.get("name", "Nation"))
	var summary := HBoxContainer.new()
	summary.add_theme_constant_override("separation", 10)
	body.add_child(summary)
	summary.add_child(_stat_card("PROJECTED REVENUE", _money(GameState.monthly_revenue), "MONTHLY TAX COLLECTION"))
	summary.add_child(_stat_card("PROJECTED EXPENSES", _money(GameState.monthly_expenses), "MONTHLY PUBLIC SPENDING"))
	summary.add_child(_stat_card("PROJECTED BALANCE", _money(GameState.monthly_balance), "BEFORE DEBT REPAYMENT"))
	var debt_panel := PanelContainer.new()
	debt_panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(debt_panel)
	var debt_info := VBoxContainer.new()
	debt_panel.add_child(debt_info)
	debt_info.add_child(_section_label("FISCAL POSITION"))
	debt_info.add_child(_muted_label("Public debt: %s  •  Debt-to-GDP: %.1f%%" % [_money(GameState.debt), (GameState.debt / maxf(GameState.gdp, 1.0)) * 100.0]))
	debt_info.add_child(_muted_label("Treasury: %s" % _money(GameState.treasury)))
	var policy := PanelContainer.new()
	policy.size_flags_vertical = Control.SIZE_EXPAND_FILL
	policy.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(policy)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 12)
	policy.add_child(controls)
	controls.add_child(_section_label("FISCAL POLICY"))
	var tax_label := _muted_label("Average tax rate: %.1f%%" % (GameState.tax_rate * 100.0))
	controls.add_child(tax_label)
	var tax_slider := HSlider.new()
	tax_slider.min_value = 5
	tax_slider.max_value = 40
	tax_slider.step = 0.5
	tax_slider.value = GameState.tax_rate * 100.0
	tax_slider.value_changed.connect(func(value: float): tax_label.text = "Average tax rate: %.1f%%" % value)
	controls.add_child(tax_slider)
	var spend_label := _muted_label("Public spending: %.1f%% of GDP" % (GameState.spending_rate * 100.0))
	controls.add_child(spend_label)
	var spend_slider := HSlider.new()
	spend_slider.min_value = 5
	spend_slider.max_value = 45
	spend_slider.step = 0.5
	spend_slider.value = GameState.spending_rate * 100.0
	spend_slider.value_changed.connect(func(value: float): spend_label.text = "Public spending: %.1f%% of GDP" % value)
	controls.add_child(spend_slider)
	controls.add_child(_muted_label("Figures are a monthly projection based on current GDP and policy. Fiscal settings are applied at the next month-end simulation tick. The balance shown is before scheduled debt repayment."))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	body.add_child(actions)
	actions.add_child(_button("APPLY FISCAL POLICY", BLUE, func(): GameState.set_budget_policy(tax_slider.value / 100.0, spend_slider.value / 100.0); _show_budget()))
	actions.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))


func _show_cities() -> void:
	current_screen = "cities"
	var country: Dictionary = GameState.selected_country
	var regions := GameState.get_regions()
	var body := _base("Cities & regional administration", "%s  /  %d cities across %d simulated regions" % [country.get("name", "Nation"), GameState.cities.size(), regions.size()])
	var regional_panel := PanelContainer.new()
	regional_panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(regional_panel)
	var regional_box := VBoxContainer.new()
	regional_box.add_theme_constant_override("separation", 8)
	regional_panel.add_child(regional_box)
	regional_box.add_child(_section_label("REGIONAL OVERVIEW"))
	if regions.is_empty():
		regional_box.add_child(_muted_label("No regional records available."))
	else:
		for region in regions:
			var region_row := HBoxContainer.new()
			region_row.add_theme_constant_override("separation", 10)
			regional_box.add_child(region_row)
			var region_label := Label.new()
			region_label.text = "%s  •  %d cities  •  %s residents" % [region.get("name", "Region"), int(region.get("city_count", 0)), _format_number(int(region.get("population", 0)))]
			region_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			region_label.add_theme_color_override("font_color", TEXT)
			region_row.add_child(region_label)
			var region_metrics := Label.new()
			region_metrics.text = "%s GDP  •  QoL %.1f" % [_money(float(region.get("gdp", 0.0))), float(region.get("average_quality_of_life", 0.0))]
			region_metrics.add_theme_color_override("font_color", MUTED)
			region_row.add_child(region_metrics)
			region_row.add_child(_button("MANAGE", BLUE, func(name: String = str(region.get("name", ""))):
				GameState.selected_region_name = name
				_show_cities()
			))
	var region_detail := GameState.get_region_detail(GameState.selected_region_name)
	if not region_detail.is_empty():
		var management_panel := PanelContainer.new()
		management_panel.add_theme_stylebox_override("panel", _style(PANEL_ALT, CYAN, 1, 10))
		body.add_child(management_panel)
		var management_box := VBoxContainer.new()
		management_box.add_theme_constant_override("separation", 7)
		management_panel.add_child(management_box)
		management_box.add_child(_section_label("REGIONAL GOVERNMENT  /  " + GameState.selected_region_name.to_upper()))
		management_box.add_child(_muted_label("%d cities  •  %s residents  •  %s GDP  •  QoL %.1f  •  Employment %.1f%%" % [int(region_detail.get("city_count", 0)), _format_number(int(region_detail.get("population", 0))), _money(float(region_detail.get("gdp", 0.0))), float(region_detail.get("average_quality_of_life", 0.0)), float(region_detail.get("average_employment", 0.0))]))
		management_box.add_child(_muted_label("Regional development fund: " + _money(float(region_detail.get("funds", 0.0)))))
		var allocation_row := HBoxContainer.new()
		allocation_row.add_theme_constant_override("separation", 8)
		management_box.add_child(allocation_row)
		var allocation := SpinBox.new()
		allocation.min_value = 1000000
		allocation.max_value = maxf(treasury, 1000000.0)
		allocation.step = 1000000
		allocation.value = minf(10000000.0, maxf(treasury, 1000000.0))
		allocation.prefix = "$"
		allocation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		allocation_row.add_child(allocation)
		allocation_row.add_child(_button("ALLOCATE FUNDS", GREEN, func():
			if GameState.allocate_region_budget(GameState.selected_region_name, allocation.value):
				_show_cities()
			else:
				_show_toast("Budget allocation failed: check national treasury and amount.")
		))
		var investment_row := HFlowContainer.new()
		investment_row.add_theme_constant_override("h_separation", 7)
		management_box.add_child(investment_row)
		for category in ["roads", "power", "housing", "health", "education"]:
			investment_row.add_child(_button("UPGRADE " + category.to_upper(), PANEL, func(kind: String = category):
				if GameState.invest_in_region(GameState.selected_region_name, kind):
					_show_cities()
				else:
					_show_toast("Regional fund is insufficient or all cities reached the level cap.")
			))
	var city_map := Control.new()
	city_map.set_script(load("res://scripts/city_map.gd"))
	city_map.custom_minimum_size = Vector2(0, 230)
	city_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(city_map)
	var search := LineEdit.new()
	search.placeholder_text = "Search city or region..."
	search.custom_minimum_size.y = 42
	body.add_child(search)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 7)
	scroll.add_child(rows)
	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 8)
	body.add_child(detail)
	var selected := GameState.get_city(GameState.selected_city_id)
	if selected.is_empty() and not GameState.cities.is_empty():
		selected = GameState.cities[0]
		GameState.selected_city_id = str(selected.get("id", ""))
	var refresh_detail := func() -> void:
		for child in detail.get_children():
			child.queue_free()
		if selected.is_empty():
			detail.add_child(_muted_label("No cities are available for this country in the offline catalogue."))
			return
		detail.add_child(_section_label("CITY PROFILE  /  " + str(selected.get("region", "Region"))))
		var metrics := HBoxContainer.new()
		metrics.add_theme_constant_override("separation", 8)
		detail.add_child(metrics)
		metrics.add_child(_stat_card("POPULATION", _format_number(int(selected.get("population", 0))), "CITY RESIDENTS"))
		metrics.add_child(_stat_card("GDP", _money(float(selected.get("gdp", 0.0))), "CITY ECONOMIC BASE"))
		metrics.add_child(_stat_card("QUALITY OF LIFE", "%.1f / 100" % float(selected.get("quality_of_life", 0.0)), "DEVELOPMENT INDEX"))
		detail.add_child(_muted_label("Employment %.1f%%  •  Development %.1f / 100  •  Coordinates %.2f°, %.2f°" % [float(selected.get("employment", 0.0)), float(selected.get("development_index", 0.0)), float(selected.get("lat", 0.0)), float(selected.get("lon", 0.0))]))
		var projects := HFlowContainer.new()
		projects.add_theme_constant_override("h_separation", 7)
		projects.add_theme_constant_override("v_separation", 7)
		detail.add_child(projects)
		for category in ["roads", "power", "housing", "health", "education"]:
			var cost := GameState.city_upgrade_cost(str(selected.get("id", "")), category)
			var project_button := _button("%s  L%d  •  %s" % [category.to_upper(), int(selected.get(category, 1)), _money(cost)], PANEL_ALT, func(kind: String = category):
				if GameState.upgrade_city(str(selected.get("id", "")), kind):
					_show_cities()
				else:
					_show_toast("Project unavailable: insufficient treasury or maximum level reached.")
			)
			project_button.custom_minimum_size.x = 170
			projects.add_child(project_button)
	search.text_changed.connect(func(query: String):
		for child in rows.get_children():
			child.queue_free()
		for city in GameState.cities:
			var haystack := (str(city.get("name", "")) + " " + str(city.get("region", ""))).to_lower()
			if not query.strip_edges().is_empty() and not haystack.contains(query.to_lower()):
				continue
			var line := HBoxContainer.new()
			line.add_theme_constant_override("separation", 10)
			rows.add_child(line)
			var label := Label.new()
			label.text = "%s  •  %s  •  %s residents" % [city.get("name", "City"), city.get("region", "Region"), _format_number(int(city.get("population", 0)))]
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.add_theme_color_override("font_color", TEXT)
			line.add_child(label)
			line.add_child(_button("OPEN", BLUE, func(id: String = str(city.get("id", ""))):
				GameState.selected_city_id = id
				selected = GameState.get_city(id)
				refresh_detail.call()
			))
	)
	search.text_changed.emit("")
	city_map.connect("city_selected", func(city_id: String):
		GameState.selected_city_id = city_id
		selected = GameState.get_city(city_id)
		refresh_detail.call()
	)
	refresh_detail.call()
	body.add_child(_muted_label("City population is capped at 60% of the national baseline for catalogued urban centres; GDP is an estimated 70% urban allocation. Regional totals aggregate listed cities only. Administrative labels are not yet complete province boundary data."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))


func _on_map_country_selected(country: Dictionary) -> void:
	var full_country := GameState.find_country(str(country.get("id", "")))
	if full_country.is_empty():
		full_country = country.duplicate(true)
	selected_country = full_country
	_show_toast("Map focus: %s  •  %s" % [full_country.get("name", "Unknown"), full_country.get("id", "")])

func _refresh_dashboard() -> void:
	if current_screen == "dashboard":
		_show_dashboard()

func _toggle_pause() -> void:
	GameState.is_paused = not GameState.is_paused
	_show_dashboard()

func _save_game() -> void:
	if GameState.save_game():
		_show_toast("Game saved locally.")
	else:
		_show_toast("Save failed. Check device storage.")

func _action_button(label: String, message: String) -> Button:
	return _button(label, PANEL_ALT, func(): _show_toast(message))

func _stat_card(label: String, value: String, foot: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 10))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	panel.add_child(column)
	var top := Label.new()
	top.text = label
	top.add_theme_font_size_override("font_size", 10)
	top.add_theme_color_override("font_color", MUTED)
	column.add_child(top)
	var number := Label.new()
	number.text = value
	number.add_theme_font_size_override("font_size", 18)
	number.add_theme_color_override("font_color", TEXT)
	column.add_child(number)
	var bottom := Label.new()
	bottom.text = foot
	bottom.add_theme_font_size_override("font_size", 9)
	bottom.add_theme_color_override("font_color", GREEN)
	column.add_child(bottom)
	return panel

func _button(label: String, color: Color, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _style(color, BORDER, 1, 8))
	button.add_theme_stylebox_override("hover", _style(color.lightened(0.12), CYAN, 1, 8))
	button.add_theme_stylebox_override("pressed", _style(color.darkened(0.15), CYAN, 1, 8))
	button.pressed.connect(action)
	return button

func _section_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_color_override("font_color", GOLD)
	label.add_theme_font_size_override("font_size", 10)
	return label

func _muted_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_color_override("font_color", MUTED)
	label.add_theme_font_size_override("font_size", 12)
	return label

func _style(color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border_color
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box

func _format_number(value: int) -> String:
	if value >= 1000000000:
		return "%.2fB" % (float(value) / 1000000000.0)
	if value >= 1000000:
		return "%.1fM" % (float(value) / 1000000.0)
	if value >= 1000:
		return "%.1fK" % (float(value) / 1000.0)
	return str(value)

func _money(value: float) -> String:
	if value >= 1000000000000.0:
		return "$%.2fT" % (value / 1000000000000.0)
	if value >= 1000000000.0:
		return "$%.2fB" % (value / 1000000000.0)
	if value >= 1000000.0:
		return "$%.1fM" % (value / 1000000.0)
	return "$%.0f" % value

func _show_toast(message: String) -> void:
	if toast_label != null and is_instance_valid(toast_label):
		toast_label.queue_free()
	toast_label = Label.new()
	toast_label.text = message
	toast_label.add_theme_color_override("font_color", TEXT)
	toast_label.add_theme_stylebox_override("normal", _style(PANEL_ALT, CYAN, 1, 8))
	toast_label.position = Vector2(24, size.y - 58)
	toast_label.size = Vector2(500, 40)
	add_child(toast_label)
