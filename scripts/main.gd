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
			"cities": _show_cities(),
			"transport": _show_transport()
			"companies": _show_companies()
			"banking": _show_banking(),
			"government": _show_government(),
			"research": _show_research(),
			"environment": _show_environment(),
			"energy": _show_energy(),
			"mining": _show_mining(),
			"space": _show_space(),
			"intelligence": _show_intelligence(),
			"immigration": _show_immigration(),
			"media": _show_media()

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
	detail.add_child(_muted_label("Population: %s" % _format_format_number(int(chosen["population"]))))
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
	stats.add_child(_stat_card("POPULATION", _format_format_number(GameState.population), "NATIONAL RESIDENTS"))
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
	side.add_child(_button("Cabinet & ministries", PANEL_ALT, _show_government))
	side.add_child(_button("Diplomacy & foreign affairs", PANEL_ALT, _show_diplomacy))
	side.add_child(_button("Military & defense", PANEL_ALT, _show_military))
	side.add_child(_section_label("DEVELOPMENT"))
	side.add_child(_button("Infrastructure", PANEL_ALT, _show_infrastructure))
	side.add_child(_button("City & regional management", PANEL_ALT, _show_cities))
	side.add_child(_button("Transport network", PANEL_ALT, _show_transport))
	side.add_child(_button("Industry & trade", PANEL_ALT, _show_industry))
	side.add_child(_button("Companies & employment", PANEL_ALT, _show_companies))
	side.add_child(_button("Banking & central bank", PANEL_ALT, _show_banking))
	side.add_child(_button("Population & social policy", PANEL_ALT, _show_society))
	side.add_child(_button("International trade", PANEL_ALT, _show_trade))
	side.add_child(_button("Research & technology", PANEL_ALT, _show_research))
	side.add_child(_button("Environment & disasters", PANEL_ALT, _show_environment))
	side.add_child(_button("Energy & power grid", PANEL_ALT, _show_energy))
	side.add_child(_button("Mining & natural resources", PANEL_ALT, _show_mining))
	side.add_child(_button("Space agency & exploration", PANEL_ALT, _show_space))
	side.add_child(_button("Intelligence & cyber security", PANEL_ALT, _show_intelligence))
	side.add_child(_button("Immigration & citizenship", PANEL_ALT, _show_immigration))
	side.add_child(_button("National media & public opinion", PANEL_ALT, _show_media))
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
		people.text = "Pop. %s   •   Stability %.0f" % [_format_format_number(int(nation.get("population", 0))), float(nation.get("stability", 0.0))]
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
		market_column.add_child(_muted_label("%s  •  %s per unit  •  Stockpile: %s" % [str(key).capitalize(), _money(float(GameState.market_prices.get(key, 0.0))), _format_format_number(int(GameState.resource_stockpiles.get(key, 0.0)))]))
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
	stats.add_child(_stat_card("FACTORIES", _format_format_number(GameState.factory_count), "INDUSTRIAL FACILITIES"))
	stats.add_child(_stat_card("INDUSTRIAL OUTPUT", _money(GameState.industrial_output), "MONTHLY VALUE ADDED"))
	stats.add_child(_stat_card("INDUSTRIAL JOBS", _format_format_number(GameState.industrial_jobs), "ESTIMATED WORKFORCE"))
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
		resource_column.add_child(_muted_label("%s: %s units" % [str(key).capitalize(), _format_format_number(int(GameState.resource_stockpiles.get(key, 0.0)))]))
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
	stats.add_child(_stat_card("ACTIVE PERSONNEL", _format_format_number(GameState.military_personnel), "SERVICE MEMBERS"))
	stats.add_child(_stat_card("MILITARY READINESS", "%.0f%%" % GameState.military_readiness, "OPERATIONAL READINESS"))
	stats.add_child(_stat_card("MILITARY POWER", _format_format_number(int(GameState.military_strength())), "COMPOSITE INDEX"))
	var equipment := PanelContainer.new()
	equipment.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(equipment)
	var equipment_column := VBoxContainer.new()
	equipment_column.add_theme_constant_override("separation", 10)
	equipment.add_child(equipment_column)
	equipment_column.add_child(_section_label("FORCE STRUCTURE"))
	equipment_column.add_child(_muted_label("Main battle tanks: %s" % _format_format_number(GameState.tanks)))
	equipment_column.add_child(_muted_label("Military aircraft: %s" % _format_format_number(GameState.aircraft)))
	equipment_column.add_child(_muted_label("Naval vessels: %s" % _format_format_number(GameState.naval_vessels)))
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
	body.add_child(_muted_label("Capital: %s  •  GDP: %s  •  Population: %s" % [nation.get("capital", "Not listed"), _money(float(nation.get("gdp", 0.0))), _format_format_number(int(nation.get("population", 0)))]))
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


func _show_transport() -> void:
	current_screen = "transport"
	var body := _base("National transport network", "%s  /  Intercity road connections and logistics capacity" % GameState.selected_country.get("name", "Nation"))
	var summary := HBoxContainer.new()
	summary.add_theme_constant_override("separation", 10)
	body.add_child(summary)
	summary.add_child(_stat_card("ACTIVE ROUTES", str(GameState.transport_routes.size()), "INTERCITY CONNECTIONS"))
	var total_distance := 0.0
	var average_congestion := 0.0
	for route in GameState.transport_routes:
		total_distance += float(route.get("distance_km", 0.0))
		average_congestion += float(route.get("congestion", 0.0))
	if not GameState.transport_routes.is_empty():
		average_congestion /= float(GameState.transport_routes.size())
	summary.add_child(_stat_card("NETWORK LENGTH", "%.0f km" % total_distance, "MODELLED ROAD DISTANCE"))
	summary.add_child(_stat_card("AVG. CONGESTION", "%.1f%%" % average_congestion, "ESTIMATED TRAFFIC PRESSURE"))
	var builder := PanelContainer.new()
	builder.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 12))
	body.add_child(builder)
	var builder_box := VBoxContainer.new()
	builder_box.add_theme_constant_override("separation", 8)
	builder.add_child(builder_box)
	builder_box.add_child(_section_label("PLAN A NEW INTERCITY ROAD"))
	if GameState.cities.size() < 2:
		builder_box.add_child(_muted_label("At least two catalogued cities are required to construct a route."))
	else:
		var selectors := HBoxContainer.new()
		selectors.add_theme_constant_override("separation", 8)
		builder_box.add_child(selectors)
		var from_picker := OptionButton.new()
		var to_picker := OptionButton.new()
		from_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		to_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for city in GameState.cities:
			var city_name := str(city.get("name", "City"))
			from_picker.add_item(city_name)
			to_picker.add_item(city_name)
		if to_picker.item_count > 1:
			to_picker.select(1)
		selectors.add_child(from_picker)
		selectors.add_child(to_picker)
		var mode_picker := OptionButton.new()
		mode_picker.add_item("Road")
		mode_picker.add_item("Rail")
		mode_picker.add_item("Air")
		mode_picker.add_item("Sea")
		builder_box.add_child(mode_picker)
		var estimate := _muted_label("")
		builder_box.add_child(estimate)
		var update_estimate := func() -> void:
			var a := str(GameState.cities[from_picker.selected].get("id", ""))
			var b := str(GameState.cities[to_picker.selected].get("id", ""))
			var mode := ["road", "rail", "air", "sea"][mode_picker.selected]
			var cost := GameState.transport_route_cost(a, b, mode)
			estimate.text = "Estimated %s construction cost: %s" % [mode.to_upper(), _money(cost) if cost >= 0.0 else "Unavailable: build both terminals or check existing route"]
		from_picker.item_selected.connect(func(_index: int): update_estimate.call())
		to_picker.item_selected.connect(func(_index: int): update_estimate.call())
		mode_picker.item_selected.connect(func(_index: int): update_estimate.call())
		update_estimate.call()
		builder_box.add_child(_button("CONSTRUCT ROAD CONNECTION", BLUE, func():
			var a := str(GameState.cities[from_picker.selected].get("id", ""))
			var b := str(GameState.cities[to_picker.selected].get("id", ""))
			var mode := ["road", "rail", "air", "sea"][mode_picker.selected]
			if GameState.build_transport_route(a, b, mode):
				_show_transport()
			else:
				_show_toast("Construction failed: choose two different unconnected cities and check treasury.")
		))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 7)
	scroll.add_child(rows)
	rows.add_child(_section_label("ROAD CONNECTION REGISTER"))
	if GameState.transport_routes.is_empty():
		rows.add_child(_muted_label("No intercity roads have been built. Select two cities above to establish the first connection."))
	else:
		for route in GameState.transport_routes:
			var panel := PanelContainer.new()
			panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 8))
			rows.add_child(panel)
			var info := VBoxContainer.new()
			panel.add_child(info)
			info.add_child(_muted_label("%s  ↔  %s  •  %s" % [route.get("from_name", "City"), route.get("to_name", "City"), str(route.get("mode", "road")).to_upper()]))
			info.add_child(_muted_label("%.0f km  •  Road level %d  •  Traffic %.0f / %.0f  •  Congestion %.1f%%" % [float(route.get("distance_km", 0.0)), int(route.get("road_level", 1)), float(route.get("traffic", 0.0)), float(route.get("capacity", 80000.0)), float(route.get("congestion", 0.0))]))
	var terminal_panel := PanelContainer.new()
	terminal_panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 10))
	body.add_child(terminal_panel)
	var terminal_box := VBoxContainer.new()
	terminal_box.add_child(_section_label("RAIL STATIONS  /  AIRPORTS  /  SEAPORTS"))
	terminal_panel.add_child(terminal_box)
	var terminal_city := OptionButton.new()
	for city in GameState.cities:
		terminal_city.add_item(str(city.get("name", "City")))
	terminal_box.add_child(terminal_city)
	var terminal_stats := _muted_label("")
	terminal_box.add_child(terminal_stats)
	var refresh_terminals := func() -> void:
		if GameState.cities.is_empty():
			terminal_stats.text = "No cities available."
			return
		var city: Dictionary = GameState.cities[terminal_city.selected]
		terminal_stats.text = "Rail L%d  •  Airport L%d  •  Seaport L%d" % [int(city.get("rail_station", 0)), int(city.get("airport", 0)), int(city.get("seaport", 0))]
	terminal_city.item_selected.connect(func(_index: int): refresh_terminals.call())
	refresh_terminals.call()
	var terminal_buttons := HFlowContainer.new()
	terminal_box.add_child(terminal_buttons)
	for facility in ["rail_station", "airport", "seaport"]:
		terminal_buttons.add_child(_button("UPGRADE " + facility.to_upper().replace("_", " "), BLUE, func(kind: String = facility):
			var city_id := str(GameState.cities[terminal_city.selected].get("id", ""))
			if GameState.upgrade_transport_facility(city_id, kind):
				_show_transport()
			else:
				_show_toast("Upgrade failed: insufficient funds or facility level cap reached.")
		))
	body.add_child(_muted_label("Transport is a strategic prototype: route distance uses city coordinates; traffic and capacity are simplified estimates, not turn-by-turn pathfinding or real road geometry. Rail, air and sea routes require matching terminals at both cities."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))







func _show_media() -> void:
	current_screen = "media"
	var body := _base("National media & public opinion", "PRESS FREEDOM  /  PUBLIC TRUST  /  INFORMATION RESILIENCE")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("MEDIA TRUST", "%.1f / 100" % GameState.media_trust, "PUBLIC CONFIDENCE"))
	summary.add_child(_stat_card("MEDIA REACH", "%.1f / 100" % GameState.media_reach, "INFORMATION ACCESS"))
	summary.add_child(_stat_card("PRESS FREEDOM", "%.1f / 100" % GameState.media_freedom, "EDITORIAL INDEPENDENCE"))
	summary.add_child(_stat_card("PUBLIC APPROVAL", "%.1f%%" % GameState.government_approval, "GOVERNMENT APPROVAL"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 10)
	scroll.add_child(sections)
	sections.add_child(_section_label("MEDIA ECOSYSTEM"))
	sections.add_child(_muted_label("TV stations: %d  •  Newspaper groups: %d  •  Digital networks: %d" % [GameState.tv_stations, GameState.newspaper_groups, GameState.digital_networks]))
	sections.add_child(_muted_label("Misinformation pressure %.1f  •  Polarization %.1f  •  Press safety %.1f  •  Monthly public media cost %s" % [GameState.misinformation_pressure, GameState.public_polarization, GameState.press_safety, _money(GameState.monthly_media_cost)]))
	for kind in ["tv", "newspaper", "digital"]:
		var title := {"tv": "BUILD TV STATION", "newspaper": "ESTABLISH NEWSPAPER GROUP", "digital": "EXPAND DIGITAL NETWORK"}[kind]
		sections.add_child(_button("%s  •  %s" % [title, _money(GameState.media_investment_cost(kind))], BLUE, func(k: String = kind):
			if GameState.invest_in_media(k):
				_show_media()
			else:
				_show_toast("Investment failed: insufficient treasury or institution level cap reached.")
		))
	sections.add_child(_section_label("MEDIA POLICY SETTINGS"))
	var freedom := HSlider.new()
	freedom.min_value = 0
	freedom.max_value = 100
	freedom.step = 5
	freedom.value = GameState.media_freedom
	sections.add_child(freedom)
	var freedom_label := _muted_label("Press freedom: %.0f / 100" % freedom.value)
	sections.add_child(freedom_label)
	freedom.value_changed.connect(func(v: float): freedom_label.text = "Press freedom: %.0f / 100" % v)
	var regulation := HSlider.new()
	regulation.min_value = 0
	regulation.max_value = 100
	regulation.step = 5
	regulation.value = GameState.media_regulation
	sections.add_child(regulation)
	var regulation_label := _muted_label("Media regulation: %.0f / 100" % regulation.value)
	sections.add_child(regulation_label)
	regulation.value_changed.connect(func(v: float): regulation_label.text = "Media regulation: %.0f / 100" % v)
	var literacy := HSlider.new()
	literacy.min_value = 0
	literacy.max_value = 100
	literacy.step = 5
	literacy.value = GameState.media_literacy
	sections.add_child(literacy)
	var literacy_label := _muted_label("Public media literacy: %.0f / 100" % literacy.value)
	sections.add_child(literacy_label)
	literacy.value_changed.connect(func(v: float): literacy_label.text = "Public media literacy: %.0f / 100" % v)
	var funding := HSlider.new()
	funding.min_value = 0.1
	funding.max_value = 2.0
	funding.step = 0.1
	funding.value = GameState.media_budget_rate * 100.0
	sections.add_child(funding)
	var funding_label := _muted_label("Public media budget: %.1f%% GDP" % funding.value)
	sections.add_child(funding_label)
	funding.value_changed.connect(func(v: float): funding_label.text = "Public media budget: %.1f%% GDP" % v)
	sections.add_child(_button("APPLY MEDIA POLICY", GREEN, func():
		GameState.set_media_policy(freedom.value, regulation.value, literacy.value, funding.value / 100.0)
		_show_media()
	))
	sections.add_child(_section_label("PUBLIC INFORMATION PROGRAMS"))
	sections.add_child(_button("PUBLIC INFORMATION CAMPAIGN", BLUE, func():
		if GameState.run_media_campaign("public_info"):
			_show_media()
		else:
			_show_toast("Campaign unavailable: check treasury and two-month cooldown.")
	))
	sections.add_child(_button("MEDIA LITERACY PROGRAM", GREEN, func():
		if GameState.run_media_campaign("literacy"):
			_show_media()
		else:
			_show_toast("Campaign unavailable: check treasury and two-month cooldown.")
	))
	sections.add_child(_button("STATE PROPAGANDA CAMPAIGN  •  HIGH SOCIAL COST", GOLD, func():
		if GameState.run_media_campaign("propaganda"):
			_show_media()
		else:
			_show_toast("Campaign unavailable: check treasury and two-month cooldown.")
	))
	sections.add_child(_muted_label("Campaign cooldown: %d months  •  %s" % [GameState.media_campaign_cooldown, GameState.media_report]))
	sections.add_child(_muted_label("This is an abstract fictional simulation. Propaganda has explicit trust, freedom and polarization penalties; it does not model real-world targeting or persuasion tactics."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_immigration() -> void:
	current_screen = "immigration"
	var body := _base("Immigration & citizenship", "MIGRATION POLICY  /  PASSPORTS  /  REFUGEE PROTECTION")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("POPULATION", _format_number(GameState.population), "TOTAL RESIDENTS"))
	summary.add_child(_stat_card("IMMIGRANTS", _format_number(GameState.immigrant_population), "FOREIGN-BORN RESIDENTS"))
	summary.add_child(_stat_card("FOREIGN-BORN SHARE", "%.1f%%" % GameState.foreign_born_share, "POPULATION COMPOSITION"))
	summary.add_child(_stat_card("NET MIGRATION", _format_number(GameState.monthly_net_migration), "LAST MONTH"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 10)
	scroll.add_child(sections)
	sections.add_child(_section_label("IMMIGRATION & VISA POLICY"))
	var openness := HSlider.new()
	openness.min_value = 0
	openness.max_value = 100
	openness.step = 5
	openness.value = GameState.immigration_openness
	sections.add_child(openness)
	var openness_label := _muted_label("Visa and work-permit openness: %.0f / 100" % openness.value)
	sections.add_child(openness_label)
	openness.value_changed.connect(func(value: float): openness_label.text = "Visa and work-permit openness: %.0f / 100" % value)
	sections.add_child(_button("APPLY VISA & WORK PERMIT POLICY", BLUE, func():
		GameState.set_immigration_openness(openness.value)
		_show_immigration()
	))
	sections.add_child(_section_label("REFUGEE & ASYLUM POLICY"))
	var refugees := HSlider.new()
	refugees.min_value = 0
	refugees.max_value = 100
	refugees.step = 5
	refugees.value = GameState.refugee_acceptance_rate
	sections.add_child(refugees)
	var refugee_label := _muted_label("Refugee acceptance: %.0f / 100" % refugees.value)
	sections.add_child(refugee_label)
	refugees.value_changed.connect(func(value: float): refugee_label.text = "Refugee acceptance: %.0f / 100" % value)
	sections.add_child(_button("APPLY REFUGEE POLICY", BLUE, func():
		GameState.set_refugee_acceptance(refugees.value)
		_show_immigration()
	))
	sections.add_child(_section_label("CITIZENSHIP & NATIONALITY"))
	var citizenship := HSlider.new()
	citizenship.min_value = 0
	citizenship.max_value = 100
	citizenship.step = 5
	citizenship.value = GameState.citizenship_access
	sections.add_child(citizenship)
	var citizenship_label := _muted_label("Citizenship access: %.0f / 100" % citizenship.value)
	sections.add_child(citizenship_label)
	citizenship.value_changed.connect(func(value: float): citizenship_label.text = "Citizenship access: %.0f / 100" % value)
	sections.add_child(_button("APPLY CITIZENSHIP RULES", BLUE, func():
		GameState.set_citizenship_access(citizenship.value)
		_show_immigration()
	))
	sections.add_child(_muted_label("Pending citizenship applications: %s  •  Granted: %s" % [_format_number(GameState.citizenship_applications), _format_number(GameState.citizenship_granted)]))
	sections.add_child(_button("PROCESS CITIZENSHIP APPLICATIONS", GREEN, func():
		if GameState.process_citizenship_applications():
			_show_immigration()
		else:
			_show_toast("No eligible applications or insufficient treasury.")
	))
	sections.add_child(_section_label("PASSPORT SERVICES"))
	var passport_slider := HSlider.new()
	passport_slider.min_value = 0
	passport_slider.max_value = 100
	passport_slider.step = 5
	passport_slider.value = GameState.passport_access
	sections.add_child(passport_slider)
	var passport_label := _muted_label("Passport service access: %.0f / 100" % passport_slider.value)
	sections.add_child(passport_label)
	passport_slider.value_changed.connect(func(value: float): passport_label.text = "Passport service access: %.0f / 100" % value)
	sections.add_child(_button("APPLY PASSPORT SERVICE POLICY", BLUE, func():
		GameState.set_passport_access(passport_slider.value)
		_show_immigration()
	))
	sections.add_child(_muted_label("Passports issued: %s" % _format_format_number(GameState.passports_issued)))
	sections.add_child(_button("ISSUE PASSPORTS TO ELIGIBLE CITIZENS", GREEN, func():
		if GameState.issue_passports():
			_show_immigration()
		else:
			_show_toast("Passport issuance unavailable or insufficient treasury.")
	))
	sections.add_child(_section_label("BORDER & INTEGRATION CAPACITY"))
	sections.add_child(_muted_label("Border security %.1f / 100  •  Integration capacity %.1f / 100" % [GameState.border_security, GameState.integration_capacity]))
	sections.add_child(_button("STRENGTHEN BORDER SECURITY", PANEL_ALT, func():
		if GameState.strengthen_border_security():
			_show_immigration()
		else:
			_show_toast("Upgrade unavailable or insufficient treasury.")
	))
	sections.add_child(_button("INVEST IN SETTLEMENT & INTEGRATION", GREEN, func():
		if GameState.invest_in_integration():
			_show_immigration()
		else:
			_show_toast("Upgrade unavailable or insufficient treasury.")
	))
	sections.add_child(_section_label("MONTHLY MIGRATION REPORT"))
	sections.add_child(_muted_label(GameState.immigration_report))
	sections.add_child(_muted_label("Estimated monthly public-service and settlement cost: %s" % _money(GameState.monthly_immigration_cost)))
	sections.add_child(_muted_label("Migration flows are simplified gameplay estimates. Visa, asylum and citizenship settings do not represent real legal procedures or official population statistics."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_intelligence() -> void:
	current_screen = "intelligence"
	var body := _base("Intelligence & cyber security", "NATIONAL INTELLIGENCE  /  COUNTERINTELLIGENCE  /  CYBER DEFENSE")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("AGENCY", "LEVEL %d" % GameState.intelligence_agency_level, "INTELLIGENCE CAPACITY"))
	summary.add_child(_stat_card("CYBER DEFENSE", "%.1f / 100" % GameState.cyber_defense_rating, "NATIONAL SECURITY"))
	summary.add_child(_stat_card("COUNTERINTELLIGENCE", "%.1f / 100" % GameState.counterintelligence_rating, "THREAT DETECTION"))
	summary.add_child(_stat_card("INTELLIGENCE POINTS", "%.0f" % GameState.intelligence_points, "STRATEGIC KNOWLEDGE"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 10)
	scroll.add_child(sections)
	sections.add_child(_section_label("NATIONAL SECURITY STATUS"))
	sections.add_child(_muted_label("Threat level %.1f / 100  •  Monthly intelligence cost %s  •  %s" % [GameState.national_threat_level, _money(GameState.monthly_intelligence_cost), GameState.intelligence_report]))
	var funding := HSlider.new()
	funding.min_value = 0.1
	funding.max_value = 3.0
	funding.step = 0.1
	funding.value = GameState.intelligence_budget_rate * 100.0
	sections.add_child(funding)
	var funding_label := _muted_label("Intelligence budget: %.1f%% GDP" % funding.value)
	sections.add_child(funding_label)
	funding.value_changed.connect(func(value: float): funding_label.text = "Intelligence budget: %.1f%% GDP" % value)
	sections.add_child(_button("APPLY INTELLIGENCE BUDGET", BLUE, func():
		GameState.set_intelligence_budget(funding.value / 100.0)
		_show_intelligence()
	))
	sections.add_child(_button("UPGRADE INTELLIGENCE AGENCY  •  %s" % _money(GameState.intelligence_agency_upgrade_cost()), GREEN, func():
		if GameState.upgrade_intelligence_agency():
			_show_intelligence()
		else:
			_show_toast("Upgrade unavailable: check funds or agency level cap.")
	))
	sections.add_child(_button("UPGRADE CYBER DEFENSE", BLUE, func():
		if GameState.upgrade_cyber_defense():
			_show_intelligence()
		else:
			_show_toast("Cyber defense upgrade unavailable or insufficient funds.")
	))
	sections.add_child(_section_label("INTELLIGENCE OPERATIONS"))
	if not GameState.active_intelligence_operation.is_empty():
		var active: Dictionary = GameState.active_intelligence_operation
		sections.add_child(_muted_label("%s  •  Target: %s  •  Progress: %d / %d months" % [active.get("name", "Operation"), active.get("target_name", "Unknown"), int(active.get("progress", 0)), int(active.get("duration", 2))]))
	else:
		var nation_picker := OptionButton.new()
		for nation in GameState.ai_countries:
			nation_picker.add_item("%s  (%s)" % [str(nation.get("name", "Nation")), str(nation.get("id", ""))])
			nation_picker.set_item_metadata(nation_picker.item_count - 1, str(nation.get("id", "")))
		sections.add_child(nation_picker)
		var operation_picker := OptionButton.new()
		operation_picker.add_item("Foreign intelligence gathering")
		operation_picker.add_item("Technology intelligence operation")
		operation_picker.add_item("Strategic cyber disruption (hostile / wartime only)")
		sections.add_child(operation_picker)
		sections.add_child(_button("LAUNCH OPERATION", GREEN, func():
			if nation_picker.item_count == 0:
				_show_toast("No target nations available.")
				return
			var target_id := str(nation_picker.get_item_metadata(nation_picker.selected))
			var operation_ids := ["foreign_intel", "technology_espionage", "cyber_disruption"]
			if GameState.launch_intelligence_operation(target_id, operation_ids[operation_picker.selected]):
				_show_intelligence()
			else:
				_show_toast("Operation rejected: check target, treasury, diplomatic posture or active operation.")
		))
	sections.add_child(_section_label("OPERATION HISTORY"))
	if GameState.intelligence_operation_log.is_empty():
		sections.add_child(_muted_label("No completed intelligence operations."))
	else:
		for entry in GameState.intelligence_operation_log:
			sections.add_child(_muted_label("%s  •  %s  •  %s  •  %s" % [entry.get("date", ""), entry.get("name", "Operation"), entry.get("target", "Target"), entry.get("status", "")]))
	sections.add_child(_muted_label("Fictional abstract strategy-game mechanics. Outcomes are gameplay probabilities, not real operational guidance or threat intelligence."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_space() -> void:
	current_screen = "space"
	var body := _base("Space agency & exploration", "NATIONAL SPACE PROGRAM  /  SATELLITES  /  DEEP SPACE")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("SPACE AGENCY", "LEVEL %d" % GameState.space_agency_level, "INSTITUTIONAL CAPACITY"))
	summary.add_child(_stat_card("SPACE CENTERS", str(GameState.space_centers), "LAUNCH FACILITIES"))
	summary.add_child(_stat_card("ACTIVE SATELLITES", str(GameState.operational_satellites), "ORBITAL ASSETS"))
	summary.add_child(_stat_card("MONTHLY PROGRAM COST", _money(GameState.monthly_space_cost), "BUDGET ALLOCATION"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 10)
	scroll.add_child(sections)
	sections.add_child(_section_label("SPACE INFRASTRUCTURE"))
	if not GameState.completed_technologies.has("orbital_launch"):
		sections.add_child(_muted_label("LOCKED: Complete Orbital Launch Systems in Research & Technology to establish a national space center."))
	else:
		sections.add_child(_button("BUILD SPACE CENTER  •  %s" % _money(GameState.space_center_cost()), GREEN, func():
			if GameState.build_space_center():
				_show_space()
			else:
				_show_toast("Cannot build: check orbital research, treasury and facility limit.")
		))
	sections.add_child(_button("UPGRADE SPACE AGENCY  •  %s" % _money(GameState.space_agency_upgrade_cost()), BLUE, func():
		if GameState.upgrade_space_agency():
			_show_space()
		else:
			_show_toast("Agency upgrade requires a space center and sufficient funds.")
	))
	sections.add_child(_section_label("PROGRAM FUNDING"))
	var funding := HSlider.new()
	funding.min_value = 0.1
	funding.max_value = 3.0
	funding.step = 0.1
	funding.value = GameState.space_program_budget_rate * 100.0
	sections.add_child(funding)
	var funding_label := _muted_label("Space program budget: %.1f%% of GDP" % funding.value)
	sections.add_child(funding_label)
	funding.value_changed.connect(func(value: float): funding_label.text = "Space program budget: %.1f%% of GDP" % value)
	sections.add_child(_button("APPLY SPACE BUDGET", BLUE, func():
		GameState.set_space_program_budget(funding.value / 100.0)
		_show_space()
	))
	sections.add_child(_section_label("MISSION CONTROL"))
	if GameState.active_space_mission.is_empty():
		sections.add_child(_muted_label("No active mission. Launch capacity and technology requirements must be met."))
	else:
		var mission: Dictionary = GameState.active_space_mission
		var progress := float(mission.get("progress", 0)) / maxf(float(mission.get("duration", 1)), 1.0) * 100.0
		sections.add_child(_muted_label("%s  •  MONTH %d / %d" % [str(mission.get("name", "Mission")), int(mission.get("progress", 0)), int(mission.get("duration", 1))]))
		var bar := ProgressBar.new()
		bar.max_value = 100.0
		bar.value = progress
		sections.add_child(bar)
	if GameState.space_centers > 0:
		for mission in GameState.space_mission_catalog():
			var mission_id := str(mission.get("id", ""))
			var required_tech := str(mission.get("tech", "orbital_launch"))
			var unlocked := GameState.completed_technologies.has(required_tech)
			var mission_cost := maxf(GameState.gdp * float(mission.get("cost", 0.001)), 25000000.0)
			var label := "%s  •  %d months  •  %s" % [str(mission.get("name", "Mission")), int(mission.get("duration", 3)), _money(mission_cost)]
			if unlocked and GameState.active_space_mission.is_empty():
				sections.add_child(_button("LAUNCH  /  " + label, PANEL_ALT, func(id: String = mission_id):
					if GameState.start_space_mission(id):
						_show_space()
					else:
						_show_toast("Launch failed: check treasury or mission requirements.")
				))
			else:
				sections.add_child(_muted_label(("LOCKED  /  " if not unlocked else "MISSION SLOT OCCUPIED  /  ") + label))
	sections.add_child(_section_label("MISSION HISTORY"))
	if GameState.space_mission_log.is_empty():
		sections.add_child(_muted_label("No completed missions yet."))
	else:
		for record in GameState.space_mission_log:
			sections.add_child(_muted_label("%s  •  %s  •  %s" % [str(record.get("date", "")), str(record.get("name", "")), str(record.get("status", ""))]))
	sections.add_child(_muted_label("REPORT  /  " + GameState.space_report))
	sections.add_child(_muted_label("Spaceflight is an abstract strategic simulation. Missions progress by month; costs, research rewards and satellite counts are gameplay values, not real launch schedules or engineering estimates."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_research() -> void:
	current_screen = "research"
	var body := _base("Research & technology", "NATIONAL SCIENCE  /  TECHNOLOGY TREE  /  INNOVATION")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("RESEARCH LABS", str(GameState.research_labs), "NATIONAL FACILITIES"))
	summary.add_child(_stat_card("SCIENTISTS", _format_number(GameState.scientists), "RESEARCH WORKFORCE"))
	summary.add_child(_stat_card("TECHNOLOGIES", "%d / %d" % [GameState.completed_technologies.size(), GameState.technology_tree.size()], "UNLOCKED"))
	summary.add_child(_stat_card("RESEARCH FUNDING", "%.2f%% GDP" % (GameState.research_budget_rate * 100.0), "MONTHLY ALLOCATION"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 12)
	scroll.add_child(sections)
	sections.add_child(_section_label("RESEARCH POLICY"))
	var funding := HSlider.new()
	funding.min_value = 0.5
	funding.max_value = 6.0
	funding.step = 0.25
	funding.value = GameState.research_budget_rate * 100.0
	sections.add_child(funding)
	var funding_label := _muted_label("Research budget: %.2f%% of GDP" % funding.value)
	sections.add_child(funding_label)
	funding.value_changed.connect(func(value: float):
		funding_label.text = "Research budget: %.2f%% of GDP" % value
	)
	sections.add_child(_button("APPLY RESEARCH BUDGET", BLUE, func():
		GameState.set_research_budget(funding.value / 100.0)
		_show_research()
	))
	sections.add_child(_button("EXPAND RESEARCH LAB  •  EST. %s" % _money(maxf(GameState.gdp * 0.0018, 50000000.0) * float(GameState.research_labs + 1)), GREEN, func():
		if GameState.invest_in_research_lab():
			_show_research()
		else:
			_show_toast("Cannot expand: insufficient treasury or laboratory limit reached.")
	))
	if not GameState.active_research_id.is_empty():
		var active_name := GameState.active_research_id
		var required_points := 100.0
		for item in GameState.technology_tree:
			if str(item.get("id", "")) == active_name:
				active_name = str(item.get("name", active_name))
				required_points = float(item.get("cost", 100.0))
		var progress := clampf(GameState.research_points / maxf(required_points, 1.0), 0.0, 1.0)
		sections.add_child(_section_label("ACTIVE PROJECT"))
		sections.add_child(_muted_label("%s  •  %.1f / %.0f points  •  %.0f%%" % [active_name, GameState.research_points, required_points, progress * 100.0]))
		var bar := ProgressBar.new()
		bar.max_value = 100.0
		bar.value = progress * 100.0
		sections.add_child(bar)
	else:
		sections.add_child(_muted_label("No active project. Select an available technology below."))
	sections.add_child(_section_label("TECHNOLOGY TREE"))
	var current_field := ""
	for technology in GameState.technology_tree:
		var field := str(technology.get("field", "General"))
		if field != current_field:
			current_field = field
			sections.add_child(_section_label(current_field.to_upper()))
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 8))
		sections.add_child(card)
		var box := VBoxContainer.new()
		card.add_child(box)
		box.add_child(_muted_label("%s  •  %.0f research points" % [str(technology.get("name", "Technology")), float(technology.get("cost", 100.0))]))
		box.add_child(_muted_label(str(technology.get("description", ""))))
		var tech_id := str(technology.get("id", ""))
		if bool(technology.get("unlocked", false)) or GameState.completed_technologies.has(tech_id):
			box.add_child(_muted_label("UNLOCKED"))
		elif tech_id == "deep_space_missions" and not GameState.completed_technologies.has("orbital_launch"):
			box.add_child(_muted_label("LOCKED  •  Requires Orbital Launch Systems"))
		elif not GameState.active_research_id.is_empty():
			box.add_child(_muted_label("RESEARCH SLOT OCCUPIED"))
		else:
			box.add_child(_button("START RESEARCH", BLUE, func(id: String = tech_id):
				if GameState.start_research(id):
					_show_research()
				else:
					_show_toast("Unable to start this research project.")
			))
	sections.add_child(_section_label("LATEST SCIENCE REPORT"))
	sections.add_child(_muted_label(GameState.research_report))
	sections.add_child(_muted_label("Research is an abstract national model. Technologies apply strategic modifiers; no real-world scientific discovery or individual researcher simulation is represented."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_environment() -> void:
	current_screen = "environment"
	var body := _base("Environment & natural disasters", "CLIMATE  /  POLLUTION  /  CONSERVATION  /  DISASTER RESILIENCE")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("CO₂ EMISSIONS", "%.1f Mt / index" % GameState.carbon_emissions, "ABSTRACT NATIONAL ESTIMATE"))
	summary.add_child(_stat_card("ENVIRONMENT QUALITY", "%.1f / 100" % GameState.environmental_quality, "HIGHER IS BETTER"))
	summary.add_child(_stat_card("FOREST COVER", "%.1f%%" % GameState.forest_cover, "ESTIMATED LAND COVER"))
	summary.add_child(_stat_card("CLIMATE / HAZARD RISK", "%.1f / 100" % GameState.climate_risk, "SIMPLIFIED RISK INDEX"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 11)
	scroll.add_child(sections)
	sections.add_child(_section_label("NATIONAL ENVIRONMENTAL INDICATORS"))
	sections.add_child(_muted_label("Air pollution %.1f / 100  •  Water pollution %.1f / 100  •  Biodiversity %.1f / 100  •  Renewable energy %.1f%%  •  Disaster resilience %.1f / 100" % [GameState.air_pollution, GameState.water_pollution, GameState.biodiversity, GameState.renewable_energy_share, GameState.disaster_resilience]))
	sections.add_child(_section_label("ENVIRONMENTAL POLICY & FUNDING"))
	var funding := HSlider.new()
	funding.min_value = 0.2
	funding.max_value = 6.0
	funding.step = 0.2
	funding.value = GameState.environment_budget_rate * 100.0
	sections.add_child(funding)
	var funding_label := _muted_label("Environment budget: %.1f%% GDP  •  %s/month" % [funding.value, _money(GameState.monthly_environment_cost)])
	sections.add_child(funding_label)
	funding.value_changed.connect(func(value: float):
		funding_label.text = "Environment budget: %.1f%% GDP  •  %s/month" % [value, _money(GameState.gdp * value / 1200.0)]
	)
	sections.add_child(_button("APPLY ENVIRONMENT BUDGET", BLUE, func():
		GameState.set_environment_budget(funding.value / 100.0)
		_show_environment()
	))
	sections.add_child(_section_label("NATIONAL ENVIRONMENT PROJECTS"))
	var projects := [["reforestation", "REFORESTATION"], ["pollution_cleanup", "POLLUTION CLEANUP"], ["renewable_transition", "RENEWABLE TRANSITION"], ["flood_defense", "FLOOD DEFENSE"], ["disaster_preparedness", "DISASTER PREPAREDNESS"]]
	for project in projects:
		var project_id := str(project[0])
		var project_name := str(project[1])
		var cost := GameState.environment_project_cost(project_id)
		sections.add_child(_button("%s  •  %s" % [project_name, _money(cost)], GREEN, func(id: String = project_id):
			if GameState.invest_in_environment_project(id):
				_show_environment()
			else:
				_show_toast("Project failed: insufficient treasury.")
		))
	sections.add_child(_section_label("NATURAL DISASTER MONITOR"))
	sections.add_child(_muted_label("Resilience %.1f / 100  •  Next-event cooldown %d months" % [GameState.disaster_resilience, GameState.disaster_cooldown]))
	sections.add_child(_muted_label("LATEST REPORT  /  " + GameState.last_disaster_report))
	if GameState.disaster_history.is_empty():
		sections.add_child(_muted_label("No major events in the recorded history."))
	else:
		for event in GameState.disaster_history:
			sections.add_child(_muted_label("%02d/%d  •  %s  •  Severity %.0f/100  •  Estimated damage %s" % [int(event.get("month", 1)), int(event.get("year", 2026)), str(event.get("type", "Event")), float(event.get("severity", 0.0)), _money(float(event.get("damage", 0.0)))]))
	sections.add_child(_muted_label("Disaster occurrence and damage are abstract game estimates. Hazard weights are not based on precise local geology, elevation, coastlines or live climate data. Environmental indicators are not official scientific measurements."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))


func _show_mining() -> void:
	current_screen = "mining"
	var body := _base("Mining & natural resources", "GEOLOGICAL SURVEYS  /  EXTRACTION  /  COMMODITY TRADE")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("ACTIVE MINE SITES", str(GameState.mining_sites.size()), "NATIONAL OPERATIONS"))
	summary.add_child(_stat_card("MINING WORKFORCE", _format_format_number(GameState.mining_jobs), "DIRECT MINE EMPLOYMENT"))
	summary.add_child(_stat_card("MONTHLY SALES VALUE", _money(GameState.monthly_mining_revenue), "ESTIMATED OUTPUT VALUE"))
	summary.add_child(_stat_card("MINING TAX", "%.1f%%" % (GameState.mining_tax_rate * 100.0), "RESOURCE EXTRACTION LEVY"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 9)
	scroll.add_child(sections)
	sections.add_child(_section_label("NATIONAL RESOURCE RESERVES  /  ABSTRACT GAME UNITS"))
	for resource in GameState.mining_resources:
		var reserve := float(GameState.resource_reserves.get(resource, 0.0))
		var stock := float(GameState.resource_inventory.get(resource, 0.0))
		var output := float(GameState.resource_production.get(resource, 0.0))
		var price := float(GameState.resource_market_prices.get(resource, 0.0))
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		sections.add_child(line)
		var info := Label.new()
		info.text = "%s  •  %.2f reserve  •  %.2f stock  •  %.2f/month  •  %s/unit" % [resource.replace("_", " ").to_upper(), reserve, stock, output, _money(price)]
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_color_override("font_color", TEXT)
		line.add_child(info)
		line.add_child(_button("SURVEY  %s" % _money(GameState.resource_exploration_cost(resource)), BLUE, func(kind: String = resource):
			if GameState.explore_resource(kind):
				_show_mining()
			else:
				_show_toast("Survey unavailable: insufficient funds or exploration limit reached.")
		))
		line.add_child(_button("OPEN MINE  %s" % _money(GameState.mine_construction_cost(resource)), GREEN, func(kind: String = resource):
			var region_name := "National Territory"
			var regions := GameState.get_regions()
			if not regions.is_empty():
				region_name = str(regions[0].get("name", region_name))
			if GameState.open_mine(kind, region_name):
				_show_mining()
			else:
				_show_toast("Mine construction unavailable: discover reserves and check treasury.")
		))
	sections.add_child(_section_label("MINE REGISTER  /  %d SITES" % GameState.mining_sites.size()))
	if GameState.mining_sites.is_empty():
		sections.add_child(_muted_label("No mines established. Run a geological survey, then construct a mine."))
	else:
		for site in GameState.mining_sites:
			var site_id := str(site.get("id", ""))
			var resource_name := str(site.get("resource", "unknown"))
			sections.add_child(_button("%s  •  %s  •  LEVEL %d  •  %.2f capacity/month  •  %s workers  •  UPGRADE %s" % [site_id, str(site.get("region", "Region")), int(site.get("level", 1)), float(site.get("capacity", 0.0)), _format_format_number(int(site.get("workers", 0))), _money(GameState.mine_upgrade_cost(site_id))], PANEL_ALT, func(id: String = site_id):
				if GameState.upgrade_mine(id):
					_show_mining()
				else:
					_show_toast("Mine upgrade unavailable: insufficient treasury or level cap reached.")
			))
	sections.add_child(_section_label("MINING FISCAL POLICY"))
	var tax_slider := HSlider.new()
	tax_slider.min_value = 2
	tax_slider.max_value = 30
	tax_slider.step = 1
	tax_slider.value = GameState.mining_tax_rate * 100.0
	sections.add_child(tax_slider)
	var tax_label := _muted_label("Extraction tax: %.0f%%" % tax_slider.value)
	sections.add_child(tax_label)
	tax_slider.value_changed.connect(func(value: float): tax_label.text = "Extraction tax: %.0f%%" % value)
	sections.add_child(_button("APPLY MINING TAX POLICY", BLUE, func():
		GameState.set_mining_tax(tax_slider.value / 100.0)
		_show_mining()
	))
	sections.add_child(_section_label("INTERNATIONAL RESOURCE MARKET"))
	var partner := OptionButton.new()
	partner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for nation in GameState.ai_countries:
		partner.add_item("%s  •  %s" % [str(nation.get("flag", "")), str(nation.get("name", "Nation"))])
		partner.set_item_metadata(partner.item_count - 1, str(nation.get("id", "")))
	sections.add_child(partner)
	var resource_choice := OptionButton.new()
	for resource in GameState.mining_resources:
		resource_choice.add_item(resource.replace("_", " ").capitalize())
		resource_choice.set_item_metadata(resource_choice.item_count - 1, resource)
	sections.add_child(resource_choice)
	var quantity := SpinBox.new()
	quantity.min_value = 0.1
	quantity.max_value = 100000.0
	quantity.step = 0.1
	quantity.value = 1.0
	sections.add_child(quantity)
	var trade_buttons := HBoxContainer.new()
	trade_buttons.add_child(_button("EXPORT RESOURCE", GREEN, func():
		if partner.item_count > 0 and resource_choice.item_count > 0:
			var country_id := str(partner.get_item_metadata(partner.selected))
			var resource_id := str(resource_choice.get_item_metadata(resource_choice.selected))
			if GameState.trade_natural_resource_with_country(country_id, resource_id, "export", quantity.value):
				_show_mining()
			else:
				_show_toast("Export failed: trade pact, stock or partner funds may be missing.")
	))
	trade_buttons.add_child(_button("IMPORT RESOURCE", BLUE, func():
		if partner.item_count > 0 and resource_choice.item_count > 0:
			var country_id := str(partner.get_item_metadata(partner.selected))
			var resource_id := str(resource_choice.get_item_metadata(resource_choice.selected))
			if GameState.trade_natural_resource_with_country(country_id, resource_id, "import", quantity.value):
				_show_mining()
			else:
				_show_toast("Import failed: trade pact, partner stock or treasury may be missing.")
	))
	sections.add_child(trade_buttons)
	sections.add_child(_muted_label("REPORT  /  " + GameState.mining_report))
	sections.add_child(_muted_label("Deposit sizes, commodity prices, AI inventories and extraction volumes are abstract gameplay values, not verified geological reserves or live market quotations. Mines increase pollution; environmental policy can offset some pressure. Resource trade requires an active bilateral trade agreement and no war or sanctions."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_energy() -> void:
	current_screen = "energy"
	var body := _base("National energy & power grid", "GENERATION  /  FUEL SECURITY  /  TRANSMISSION  /  REGIONAL ACCESS")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("POWER GENERATION", "%.1f GW" % GameState.energy_generation, "AVAILABLE OUTPUT"))
	summary.add_child(_stat_card("NATIONAL DEMAND", "%.1f GW" % GameState.energy_demand, "CURRENT LOAD"))
	summary.add_child(_stat_card("SUPPLY COVERAGE", "%.1f%%" % (GameState.energy_supply_ratio * 100.0), "GENERATION / DEMAND"))
	summary.add_child(_stat_card("BLACKOUT RISK", "%.1f%%" % GameState.blackout_risk, "SIMPLIFIED GRID RISK"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 10)
	scroll.add_child(sections)
	sections.add_child(_section_label("GRID STATUS"))
	sections.add_child(_muted_label("Transmission capacity %.1f GW  •  Energy price %s / unit  •  Monthly power system cost %s" % [GameState.grid_capacity, _money(GameState.energy_price), _money(GameState.monthly_power_cost)]))
	sections.add_child(_muted_label("Coal reserves %.1f  •  Gas reserves %.1f  •  Uranium reserves %.1f" % [float(GameState.energy_fuel_reserves.get("coal", 0.0)), float(GameState.energy_fuel_reserves.get("gas", 0.0)), float(GameState.energy_fuel_reserves.get("uranium", 0.0))]))
	sections.add_child(_muted_label("REPORT  /  " + GameState.last_energy_report))
	sections.add_child(_button("UPGRADE NATIONAL TRANSMISSION GRID  •  %s" % _money(maxf(GameState.gdp * (0.0007 + GameState.grid_capacity / maxf(GameState.energy_demand, 1.0) * 0.00012), 25000000.0)), BLUE, func():
		if GameState.upgrade_national_grid():
			_show_energy()
		else:
			_show_toast("Grid upgrade unavailable or insufficient treasury.")
	))
	sections.add_child(_section_label("POWER GENERATION FLEET"))
	for plant in GameState.power_plants:
		sections.add_child(_muted_label("%s  •  %s  •  %.2f GW  •  %s" % [str(plant.get("name", "Power station")), str(plant.get("type", "unknown")).to_upper(), float(plant.get("capacity", 0.0)), "ONLINE" if bool(plant.get("operating", true)) else "OFFLINE"]))
	sections.add_child(_section_label("BUILD A POWER STATION"))
	var plant_types := [["coal", "COAL"], ["gas", "NATURAL GAS"], ["nuclear", "NUCLEAR"], ["hydro", "HYDRO"], ["solar", "SOLAR"], ["wind", "WIND"]]
	for option in plant_types:
		var kind := str(option[0])
		var cost := GameState.energy_plant_cost(kind)
		sections.add_child(_button("%s PLANT  •  %s" % [str(option[1]), _money(cost)], GREEN, func(plant_kind: String = kind):
			if GameState.build_power_plant(plant_kind):
				_show_energy()
			else:
				_show_toast("Construction failed: insufficient treasury or station limit reached.")
		))
	sections.add_child(_section_label("REGIONAL ELECTRICITY DISTRIBUTION"))
	if GameState.regional_power_access.is_empty():
		sections.add_child(_muted_label("Regional access data will appear when regional city data is available."))
	else:
		for region_name in GameState.regional_power_access.keys():
			var name := str(region_name)
			var access := float(GameState.regional_power_access[name])
			sections.add_child(_button("%s  •  %.1f%% access  •  UPGRADE %s" % [name, access, _money(maxf(GameState.gdp * 0.00025, 15000000.0))], PANEL_ALT, func(region: String = name):
				if GameState.upgrade_regional_grid(region):
					_show_energy()
				else:
					_show_toast("Regional grid is fully upgraded or treasury is insufficient.")
			))
	sections.add_child(_muted_label("Fuel use, generation capacity, grid access and costs are abstract national-level game systems. They do not represent measured power plants or real-time electricity dispatch."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_government() -> void:
	current_screen = "government"
	var body := _base("Government & parliament", "CABINET  /  POLITICAL PARTIES  /  ELECTIONS  /  NATIONAL REFORMS")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("PUBLIC APPROVAL", "%.1f%%" % GameState.government_approval, "NATIONAL GOVERNMENT"))
	summary.add_child(_stat_card("COALITION SEATS", "%d / %d" % [GameState.government_coalition_seats(), GameState.parliament_seats], "PARLIAMENTARY SUPPORT"))
	summary.add_child(_stat_card("NEXT ELECTION", "%d MONTHS" % GameState.months_until_election, "FOUR-YEAR CYCLE"))
	summary.add_child(_stat_card("GOVERNMENT TYPE", GameState.government_type, "POLITICAL SYSTEM"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 12)
	scroll.add_child(sections)
	sections.add_child(_section_label("CABINET AND MINISTRIES"))
	var minister_name := LineEdit.new()
	minister_name.placeholder_text = "Enter replacement minister name"
	sections.add_child(minister_name)
	var ministry_picker := OptionButton.new()
	for ministry in GameState.cabinet:
		ministry_picker.add_item(str(ministry.get("ministry", "Ministry")))
		ministry_picker.set_item_metadata(ministry_picker.item_count - 1, str(ministry.get("id", "")))
	sections.add_child(ministry_picker)
	sections.add_child(_button("APPOINT / REPLACE MINISTER", BLUE, func():
		if ministry_picker.item_count > 0 and GameState.appoint_minister(str(ministry_picker.get_item_metadata(ministry_picker.selected)), minister_name.text):
			_show_government()
		else:
			_show_toast("Appointment failed: enter a name between 3 and 36 characters.")
	))
	for ministry in GameState.cabinet:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 8))
		sections.add_child(panel)
		var row := HBoxContainer.new()
		panel.add_child(row)
		var label := Label.new()
		label.text = "%s  •  %s" % [str(ministry.get("ministry", "Ministry")), str(ministry.get("minister", "Vacant"))]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", TEXT)
		row.add_child(label)
		row.add_child(_muted_label("Approval %.0f%%" % float(ministry.get("approval", 50.0))))
	sections.add_child(_section_label("POLITICAL PARTIES AND PARLIAMENT"))
	var parties := GameState.political_parties.duplicate(true)
	parties.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("seats", 0)) > int(b.get("seats", 0))
	)
	for party in parties:
		var is_government := bool(party.get("government", false))
		sections.add_child(_muted_label("%s  •  %s  •  %d seats  •  %.1f%% support%s" % [
			str(party.get("name", "Party")), str(party.get("ideology", "Independent")),
			int(party.get("seats", 0)), float(party.get("popularity", 0.0)),
			"  •  GOVERNMENT" if is_government else "  •  OPPOSITION"
		]))
	sections.add_child(_muted_label("Coalition status: %s. %s" % [
		"MAJORITY" if GameState.government_has_majority() else "MINORITY",
		GameState.last_election_report
	]))
	sections.add_child(_button("CALL EARLY GENERAL ELECTION", GOLD, func():
		GameState.hold_election(true)
		_show_government()
	))
	sections.add_child(_section_label("NATIONAL LEGISLATION"))
	var laws := [
		["education_act", "National Education Act", "Expand schools and improve social mobility"],
		["healthcare_act", "Universal Healthcare Act", "Expand hospitals and social protection"],
		["green_transition", "Green Transition Act", "Invest in power infrastructure and cleaner growth"],
		["infrastructure_act", "National Infrastructure Act", "Expand roads and airport capacity"]
	]
	for law in laws:
		var law_id := str(law[0])
		var law_panel := PanelContainer.new()
		law_panel.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 8))
		sections.add_child(law_panel)
		var law_box := VBoxContainer.new()
		law_panel.add_child(law_box)
		law_box.add_child(_muted_label("%s  •  %s" % [str(law[1]), str(law[2])]))
		if GameState.enacted_laws.has(law_id):
			law_box.add_child(_muted_label("ENACTED"))
		else:
			law_box.add_child(_button("PASS BILL  •  EST. %s" % _money(GameState.gdp * (0.003 if law_id == "infrastructure_act" else (0.0025 if law_id == "green_transition" else (0.002 if law_id == "education_act" or law_id == "healthcare_act" else 0.0015)))), GREEN, func(id: String = law_id):
				if GameState.pass_legislation(id):
					_show_government()
				else:
					_show_toast("Bill failed: coalition needs a majority and treasury must cover the cost.")
			))
	sections.add_child(_muted_label("Political simulation is a strategic model: party popularity and seats are simulated, ministers are player-assigned names, and laws apply national-level effects. It does not represent real elected officials or a complete constitutional/legal system."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_society() -> void:
	current_screen = "society"
	var body := _base("Population & social policy", "CITIZENS  /  LABOUR MARKET  /  INCOME DISTRIBUTION")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("POPULATION", _format_number(GameState.population), "TOTAL RESIDENTS"))
	summary.add_child(_stat_card("LABOUR FORCE", _format_number(GameState.labor_force), "62% OF POPULATION ESTIMATE"))
	summary.add_child(_stat_card("EMPLOYED", _format_number(GameState.employed_citizens), "WORKING CITIZENS"))
	summary.add_child(_stat_card("UNEMPLOYED", _format_number(GameState.unemployed_citizens), "%.1f%% OF LABOUR FORCE" % GameState.unemployment))
	summary.add_child(_stat_card("AVG MONTHLY INCOME", _money(GameState.average_monthly_income), "MODELLED PER-CAPITA WAGE"))
	summary.add_child(_stat_card("HOUSEHOLD CONSUMPTION", _money(GameState.household_consumption), "MONTHLY NATIONAL ESTIMATE"))
	body.add_child(_section_label("INCOME DISTRIBUTION"))
	var distribution := HFlowContainer.new()
	distribution.add_theme_constant_override("h_separation", 10)
	body.add_child(distribution)
	distribution.add_child(_stat_card("LOW-INCOME / POVERTY", "%.1f%%" % GameState.poverty_rate, "ESTIMATED SHARE"))
	distribution.add_child(_stat_card("MIDDLE CLASS", "%.1f%%" % GameState.middle_class_share, "ESTIMATED SHARE"))
	distribution.add_child(_stat_card("WEALTHY", "%.1f%%" % GameState.wealthy_share, "ESTIMATED SHARE"))
	distribution.add_child(_stat_card("INEQUALITY INDEX", "%.3f" % GameState.income_inequality, "GINI-LIKE INDICATOR"))
	distribution.add_child(_stat_card("SOCIAL MOBILITY", "%.1f / 100" % GameState.social_mobility, "EDUCATION + CITY SERVICES"))
	body.add_child(_section_label("SOCIAL WELFARE POLICY"))
	var welfare_slider := HSlider.new()
	welfare_slider.min_value = 0.0
	welfare_slider.max_value = 8.0
	welfare_slider.step = 0.25
	welfare_slider.value = GameState.social_welfare_rate * 100.0
	welfare_slider.custom_minimum_size.x = 280
	body.add_child(welfare_slider)
	var welfare_label := _muted_label("Welfare allocation: %.2f%% of GDP • monthly cost %s" % [GameState.social_welfare_rate * 100.0, _money(GameState.monthly_welfare_cost)])
	body.add_child(welfare_label)
	welfare_slider.value_changed.connect(func(value: float): welfare_label.text = "Welfare allocation: %.2f%% of GDP • monthly cost %s" % [value, _money(GameState.gdp * value / 1200.0)])
	body.add_child(_button("APPLY WELFARE POLICY", GREEN, func():
		GameState.set_social_welfare_rate(welfare_slider.value / 100.0)
		_show_society()
	))
	body.add_child(_muted_label("Income groups, poverty, inequality and social mobility are national-level estimates. They are not individual citizen records, and the current model does not yet simulate each household, occupation or personal salary."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_banking() -> void:
	current_screen = "banking"
	var body := _base("Banking & central bank", "MONETARY POLICY  /  PRIVATE BANKS  /  BUSINESS CREDIT")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	summary.add_child(_stat_card("BANK DEPOSITS", _money(GameState.bank_deposits), "ESTIMATED SYSTEM DEPOSITS"))
	summary.add_child(_stat_card("BANK RESERVES", _money(GameState.bank_reserves), "LIQUID RESERVE ASSETS"))
	summary.add_child(_stat_card("LOAN BOOK", _money(GameState.bank_loan_book), "OUTSTANDING COMPANY CREDIT"))
	summary.add_child(_stat_card("HOUSEHOLD CREDIT", _money(GameState.household_credit), "AGGREGATE ESTIMATE"))
	summary.add_child(_stat_card("NON-PERFORMING", _money(GameState.nonperforming_loans), "DELINQUENT COMPANY LOANS"))
	summary.add_child(_stat_card("MONTHLY INTEREST", _money(GameState.monthly_bank_interest), "INTEREST RECEIVED"))
	body.add_child(_section_label("CENTRAL BANK POLICY RATE"))
	var rate_slider := HSlider.new()
	rate_slider.min_value = 0.5
	rate_slider.max_value = 20.0
	rate_slider.step = 0.25
	rate_slider.value = GameState.central_bank_rate * 100.0
	rate_slider.custom_minimum_size.x = 280
	body.add_child(rate_slider)
	var rate_label := _muted_label("Policy interest rate: %.2f%%" % (GameState.central_bank_rate * 100.0))
	body.add_child(rate_label)
	rate_slider.value_changed.connect(func(value: float): rate_label.text = "Policy interest rate: %.2f%%" % value)
	body.add_child(_button("APPLY MONETARY POLICY", BLUE, func():
		GameState.set_central_bank_rate(rate_slider.value / 100.0)
		_show_banking()
	))
	body.add_child(_section_label("BANK RESERVE REQUIREMENT"))
	var reserve_slider := HSlider.new()
	reserve_slider.min_value = 5
	reserve_slider.max_value = 30
	reserve_slider.step = 1
	reserve_slider.value = GameState.reserve_requirement * 100.0
	reserve_slider.custom_minimum_size.x = 280
	body.add_child(reserve_slider)
	var reserve_label := _muted_label("Required reserves: %.0f%%" % (GameState.reserve_requirement * 100.0))
	body.add_child(reserve_label)
	reserve_slider.value_changed.connect(func(value: float): reserve_label.text = "Required reserves: %.0f%%" % value)
	body.add_child(_button("APPLY RESERVE POLICY", PANEL_ALT, func():
		GameState.set_reserve_requirement(reserve_slider.value / 100.0)
		_show_banking()
	))
	body.add_child(_section_label("ISSUE A BUSINESS LOAN"))
	var eligible := OptionButton.new()
	for company in GameState.companies:
		if str(company.get("status", "Operating")) == "Operating":
			eligible.add_item(str(company.get("name", "Company")))
			eligible.set_item_metadata(eligible.item_count - 1, str(company.get("id", "")))
	body.add_child(eligible)
	var loan_amount := SpinBox.new()
	loan_amount.min_value = 1000000
	loan_amount.max_value = maxf(GameState.banking_available_credit(), 1000000.0)
	loan_amount.step = 1000000
	loan_amount.value = minf(25000000.0, loan_amount.max_value)
	loan_amount.prefix = "$"
	body.add_child(loan_amount)
	body.add_child(_button("APPROVE COMPANY LOAN", GREEN, func():
		if eligible.item_count > 0 and GameState.issue_company_loan(str(eligible.get_item_metadata(eligible.selected)), loan_amount.value):
			_show_banking()
		else:
			_show_toast("Loan rejected: check company status, credit limit or bank liquidity.")
	))
	body.add_child(_section_label("CORPORATE LOAN REGISTER"))
	if GameState.company_loans.is_empty():
		body.add_child(_muted_label("No business loans have been issued."))
	else:
		var loan_scroll := ScrollContainer.new()
		loan_scroll.custom_minimum_size.y = 170
		loan_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		body.add_child(loan_scroll)
		var loan_rows := VBoxContainer.new()
		loan_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		loan_scroll.add_child(loan_rows)
		for loan in GameState.company_loans:
			loan_rows.add_child(_muted_label("%s  •  Outstanding %s  •  Rate %.2f%%  •  %s  •  Missed %d" % [str(loan.get("company_name", "Company")), _money(float(loan.get("balance", 0.0))), float(loan.get("annual_rate", 0.0)) * 100.0, str(loan.get("status", "Performing")), int(loan.get("missed_payments", 0))]))
	body.add_child(_muted_label("Banking is an aggregate prototype: deposits, household credit and reserves are estimated national balances, not individual citizen accounts or independently simulated bank institutions. Business loans are issued against company revenue and repaid from company cash reserves."))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))

func _show_companies() -> void:
	current_screen = "companies"
	var body := _base("Companies & employment", "PRIVATE SECTOR  /  CORPORATE TAX  /  LABOUR MARKET")
	var summary := HFlowContainer.new()
	summary.add_theme_constant_override("h_separation", 8)
	summary.add_theme_constant_override("v_separation", 8)
	body.add_child(summary)
	var active_count := 0
	var bankrupt_count := 0
	var total_revenue := 0.0
	var total_profit := 0.0
	for company in GameState.companies:
		if str(company.get("status", "")) == "Bankrupt":
			bankrupt_count += 1
		else:
			active_count += 1
			total_revenue += float(company.get("revenue", 0.0))
			total_profit += float(company.get("profit", 0.0))
	summary.add_child(_stat_card("ACTIVE COMPANIES", str(active_count), "%d BANKRUPT" % bankrupt_count))
	summary.add_child(_stat_card("PRIVATE JOBS", _format_format_number(GameState.private_sector_jobs), "ESTIMATED EMPLOYEES"))
	summary.add_child(_stat_card("MONTHLY REVENUE", _money(total_revenue), "COMPANY TURNOVER"))
	summary.add_child(_stat_card("MONTHLY PROFIT", _money(total_profit), "BEFORE CORPORATE TAX"))
	summary.add_child(_stat_card("CORPORATE TAX", _money(GameState.monthly_corporate_tax), "MONTHLY GOVERNMENT RECEIPTS"))
	body.add_child(_section_label("CORPORATE TAX POLICY"))
	var tax_slider := HSlider.new()
	tax_slider.min_value = 5
	tax_slider.max_value = 35
	tax_slider.step = 1
	tax_slider.value = GameState.corporate_tax_rate * 100.0
	tax_slider.custom_minimum_size.x = 260
	body.add_child(tax_slider)
	var tax_label := _muted_label("Corporate tax rate: %.0f%%" % (GameState.corporate_tax_rate * 100.0))
	body.add_child(tax_label)
	tax_slider.value_changed.connect(func(value: float): tax_label.text = "Corporate tax rate: %.0f%%" % value)
	body.add_child(_button("APPLY CORPORATE TAX", BLUE, func():
		GameState.set_corporate_tax(tax_slider.value / 100.0)
		_show_companies()
	))
	body.add_child(_section_label("ESTABLISH A NEW COMPANY"))
	var city_picker := OptionButton.new()
	for city in GameState.cities:
		city_picker.add_item(str(city.get("name", "City")))
		city_picker.set_item_metadata(city_picker.item_count - 1, str(city.get("id", "")))
	body.add_child(city_picker)
	var sector_picker := OptionButton.new()
	for sector in ["Manufacturing", "Retail & services", "Technology", "Construction", "Logistics", "Energy"]:
		sector_picker.add_item(sector)
	body.add_child(sector_picker)
	var selected_city_id := str(city_picker.get_item_metadata(0)) if city_picker.item_count > 0 else ""
	var cost_label := _muted_label("Investment cost: select a city to establish a company.")
	body.add_child(cost_label)
	city_picker.item_selected.connect(func(index: int):
		selected_city_id = str(city_picker.get_item_metadata(index))
		var city_data := GameState.get_city(selected_city_id)
		cost_label.text = "Investment cost: " + _money(maxf(float(city_data.get("gdp", 0.0)) * 0.0015, 15000000.0))
	)
	if city_picker.item_count > 0:
		var initial_city := GameState.get_city(selected_city_id)
		cost_label.text = "Investment cost: " + _money(maxf(float(initial_city.get("gdp", 0.0)) * 0.0015, 15000000.0))
	body.add_child(_button("FOUND COMPANY", GREEN, func():
		if GameState.create_company(selected_city_id, sector_picker.get_item_text(sector_picker.selected)):
			_show_companies()
		else:
			_show_toast("Company founding failed: check treasury, city selection or company cap.")
	))
	body.add_child(_section_label("COMPANY REGISTER  /  %d ENTRIES" % GameState.companies.size()))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 5)
	scroll.add_child(rows)
	var sorted_companies := GameState.companies.duplicate(true)
	sorted_companies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.get("profit", 0.0)) > float(b.get("profit", 0.0)))
	for company in sorted_companies:
		var city_name := "Unknown city"
		for city in GameState.cities:
			if str(city.get("id", "")) == str(company.get("city_id", "")):
				city_name = str(city.get("name", city_name))
				break
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _style(PANEL, BORDER, 1, 8))
		rows.add_child(row)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 3)
		row.add_child(column)
		column.add_child(_muted_label("%s  •  %s  •  %s" % [str(company.get("name", "Company")), str(company.get("sector", "Sector")), city_name]))
		column.add_child(_muted_label("%s employees  •  Wage %s  •  Revenue %s  •  Profit %s  •  %s" % [_format_format_number(int(company.get("employees", 0))), _money(float(company.get("average_wage", 0.0))), _money(float(company.get("revenue", 0.0))), _money(float(company.get("profit", 0.0))), str(company.get("status", "Operating"))]))
	body.add_child(_button("BACK TO NATION", PANEL_ALT, _show_dashboard))


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
			region_label.text = "%s  •  %d cities  •  %s residents" % [region.get("name", "Region"), int(region.get("city_count", 0)), _format_format_number(int(region.get("population", 0)))]
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
		management_box.add_child(_muted_label("%d cities  •  %s residents  •  %s GDP  •  QoL %.1f  •  Employment %.1f%%" % [int(region_detail.get("city_count", 0)), _format_format_number(int(region_detail.get("population", 0))), _money(float(region_detail.get("gdp", 0.0))), float(region_detail.get("average_quality_of_life", 0.0)), float(region_detail.get("average_employment", 0.0))]))
		management_box.add_child(_muted_label("Regional development fund: " + _money(float(region_detail.get("funds", 0.0)))))
		var allocation_row := HBoxContainer.new()
		allocation_row.add_theme_constant_override("separation", 8)
		management_box.add_child(allocation_row)
		var allocation := SpinBox.new()
		allocation.min_value = 1000000
		allocation.max_value = maxf(GameState.treasury, 1000000.0)
		allocation.step = 1000000
		allocation.value = minf(10000000.0, maxf(GameState.treasury, 1000000.0))
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
		metrics.add_child(_stat_card("POPULATION", _format_format_number(int(selected.get("population", 0))), "CITY RESIDENTS"))
		metrics.add_child(_stat_card("GDP", _money(float(selected.get("gdp", 0.0))), "CITY ECONOMIC BASE"))
		metrics.add_child(_stat_card("QUALITY OF LIFE", "%.1f / 100" % float(selected.get("quality_of_life", 0.0)), "DEVELOPMENT INDEX"))
		detail.add_child(_muted_label("Employment %.1f%%  •  Development %.1f / 100  •  Coordinates %.2f°, %.2f°" % [float(selected.get("employment", 0.0)), float(selected.get("development_index", 0.0)), float(selected.get("lat", 0.0)), float(selected.get("lon", 0.0))]))
		detail.add_child(_section_label("RESIDENT NEEDS  /  MONTHLY DEMOGRAPHICS"))
		var social_metrics := HFlowContainer.new()
		social_metrics.add_theme_constant_override("h_separation", 7)
		social_metrics.add_theme_constant_override("v_separation", 7)
		detail.add_child(social_metrics)
		social_metrics.add_child(_stat_card("HOUSING PRESSURE", "%.1f%%" % float(selected.get("housing_pressure", 93.0)), "LOWER IS BETTER"))
		social_metrics.add_child(_stat_card("FOOD SECURITY", "%.1f%%" % float(selected.get("food_security", 100.0)), "ESTIMATED SUPPLY COVERAGE"))
		social_metrics.add_child(_stat_card("HEALTH ACCESS", "%.1f" % float(selected.get("health_access", 49.0)), "SERVICE INDEX / 100"))
		social_metrics.add_child(_stat_card("EDUCATION ACCESS", "%.1f" % float(selected.get("education_access", 46.0)), "SERVICE INDEX / 100"))
		social_metrics.add_child(_stat_card("SATISFACTION", "%.1f / 100" % float(selected.get("resident_satisfaction", selected.get("quality_of_life", 58.0))), "RESIDENT SENTIMENT"))
		detail.add_child(_muted_label("Housing affordability %.1f / 100  •  Births %s  •  Deaths %s  •  Net migration %s residents this month" % [float(selected.get("housing_affordability", 65.0)), _format_format_number(int(selected.get("births_monthly", 0))), _format_format_number(int(selected.get("deaths_monthly", 0))), _format_format_number(int(selected.get("monthly_migration", 0)))]))
		detail.add_child(_muted_label("Migration is an abstract monthly estimate driven by satisfaction relative to other listed cities. Food security uses the national food stockpile as a shared proxy, not a city distribution simulation."))
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
		detail.add_child(_section_label("CITY ZONING  /  LAND DEVELOPMENT"))
		var zones: Dictionary = selected.get("zones", {"residential": 2, "industrial": 1, "commercial": 1, "government": 1})
		detail.add_child(_muted_label("Land value index: %.1f  •  Zone levels: Residential %d  /  Industrial %d  /  Commercial %d  /  Government %d" % [float(selected.get("land_value", 100.0)), int(zones.get("residential", 1)), int(zones.get("industrial", 1)), int(zones.get("commercial", 1)), int(zones.get("government", 1))]))
		var zone_buttons := HFlowContainer.new()
		zone_buttons.add_theme_constant_override("h_separation", 6)
		detail.add_child(zone_buttons)
		for zone_type in ["residential", "industrial", "commercial", "government"]:
			var zone_cost := GameState.city_zone_cost(str(selected.get("id", "")), zone_type)
			zone_buttons.add_child(_button("ZONE " + zone_type.to_upper() + "  •  " + _money(zone_cost), PANEL_ALT, func(kind: String = zone_type):
				if GameState.develop_city_zone(str(selected.get("id", "")), kind):
					_show_cities()
				else:
					_show_toast("Zone upgrade failed: insufficient treasury or level cap.")
			))
		detail.add_child(_section_label("CONSTRUCT CITY BUILDINGS"))
		var building_buttons := HFlowContainer.new()
		building_buttons.add_theme_constant_override("h_separation", 6)
		building_buttons.add_theme_constant_override("v_separation", 6)
		detail.add_child(building_buttons)
		for building_type in ["factory", "mall", "apartments", "hospital", "university", "power_plant"]:
			var building_cost := GameState.city_building_cost(str(selected.get("id", "")), building_type)
			building_buttons.add_child(_button(building_type.to_upper().replace("_", " ") + "  •  " + _money(building_cost), BLUE, func(kind: String = building_type):
				if GameState.build_city_building(str(selected.get("id", "")), kind):
					_show_cities()
				else:
					_show_toast("Construction failed: insufficient treasury or building limit reached.")
			))
		var buildings: Array = selected.get("buildings", [])
		detail.add_child(_section_label("CITY BUILDING REGISTER  /  %d STRUCTURES" % buildings.size()))
		if buildings.is_empty():
			detail.add_child(_muted_label("No constructed buildings yet."))
		else:
			for building in buildings:
				detail.add_child(_muted_label("• %s  —  %s jobs  /  %s monthly output" % [str(building.get("name", "Building")), _format_format_number(int(building.get("jobs", 0))), _money(float(building.get("monthly_output", 0.0)))]))
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
			label.text = "%s  •  %s  •  %s residents" % [city.get("name", "City"), city.get("region", "Region"), _format_format_number(int(city.get("population", 0)))]
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

func _format_format_number(value: int) -> String:
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
