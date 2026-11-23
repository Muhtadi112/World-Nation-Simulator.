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

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_show_home()

func _on_viewport_resized() -> void:
	if is_inside_tree():
		match current_screen:
			"home": _show_home()
			"countries": _show_country_select()
			"dashboard": _show_dashboard()

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
	stats.add_child(_stat_card("POPULATION", _format_number(GameState.population), "+0.8%"))
	stats.add_child(_stat_card("GDP", _money(GameState.gdp), "NATIONAL OUTPUT"))
	stats.add_child(_stat_card("TREASURY", _money(GameState.treasury), "AVAILABLE FUNDS"))
	stats.add_child(_stat_card("INFLATION", "%.1f%%" % GameState.inflation, "ANNUAL"))
	stats.add_child(_stat_card("UNEMPLOYMENT", "%.1f%%" % GameState.unemployment, "LABOR MARKET"))
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
	side.add_child(_action_button("National budget", "Budget management coming in Phase 2"))
	side.add_child(_action_button("Cabinet & ministries", "Government simulation coming in Phase 2"))
	side.add_child(_action_button("Diplomacy", "International relations coming in Phase 2"))
	side.add_child(_section_label("DEVELOPMENT"))
	side.add_child(_action_button("Infrastructure", "City construction coming in Phase 2"))
	side.add_child(_action_button("Industry & trade", "Business simulation coming in Phase 2"))
	side.add_child(_action_button("Research", "Technology tree coming in Phase 2"))
	side.add_child(_button("MAIN MENU", PANEL_ALT, _show_home))
	var note := Label.new()
	note.text = "Real country boundaries • 177 mapped features • baseline statistics are approximate historical estimates."
	note.add_theme_color_override("font_color", MUTED)
	note.add_theme_font_size_override("font_size", 10)
	body.add_child(note)
	GameState.state_changed.connect(_refresh_dashboard, CONNECT_ONE_SHOT)

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
