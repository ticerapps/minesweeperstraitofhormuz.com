class_name ZoomController
extends Node

const ControlPanelChrome := preload("res://scripts/core/ControlPanelChrome.gd")
const BoardRendering := preload("res://scripts/core/BoardViewportRendering.gd")

# Shared board-zoom controller, lifted verbatim from GameScreen (solo) so every
# experience zooms IDENTICALLY: point-anchored scale (pinch midpoint / cursor /
# slider-on-centre), one-finger drag-pan, clamp-to-edges, a transient percentage +
# compact lens-ended micro-slider, and the shared tap-action selector.
#
# It operates on a `board` Control that fills its play area (the grid is centred
# INSIDE it). The host adds this as a child, forwards _input + resize, and wires
# the few host-specific hooks below.

const ZOOM_MIN := 1.0
const ZOOM_MAX := 7.5
const ZOOM_STEP := 0.1
const PAN_SLOP := 14.0
const ZOOM_HUD_IDLE_ALPHA := 1.0 # Whole-instrument compatibility contract.
const ZOOM_READOUT_IDLE_ALPHA := 0.0
const ZOOM_READOUT_HOLD_SECONDS := 1.5
const ZOOM_READOUT_FADE_SECONDS := 0.25
const ZOOM_STEP_IDLE_ALPHA := 0.70
const ZOOM_STEP_ACTIVE_ALPHA := 1.0
# Endpoints remain readable at the same requested idle opacity; the disabled
# Button state still prevents activation and its tooltip/accessibility remains.
const ZOOM_STEP_DISABLED_ALPHA := 0.70
const ZOOM_STEP_FEEDBACK_HOLD_SECONDS := 1.5
const ZOOM_STEP_FEEDBACK_FADE_SECONDS := 0.25
const ZOOM_STEP_RAILWARD_OFFSET := 10.0
const ZOOM_STEP_RAILWARD_OFFSET_MOBILE := 24.0
const ZOOM_IN_ACCESSIBILITY_NAME := "ZOOM IN"
const ZOOM_OUT_ACCESSIBILITY_NAME := "ZOOM OUT"
const ZOOM_RULER_ACCESSIBILITY_NAME := "ZOOM LEVEL"
const ZOOM_RULER_ACCESSIBILITY_DESCRIPTION := \
	"Tap or drag to set zoom from 100% to 750%."
const HINT_COLOR := Color(0.365, 0.792, 0.647, 1.0)
const ZOOM_HUD_X := 65.0   # ~10% closer to the phone edge while remaining camera-safe
const ZOOM_RULER_LENGTH := 92.0
const ZOOM_RULER_LENGTH_MOBILE := 222.0
const ZOOM_RULER_SIDE_LENGTH := 120.0
const ZOOM_RULER_BAND := 55.0
const DOCK_GAP := 8
const DOCK_EDGE_GAP := 12.0
# The fixed horizontal command rail shares the footer's exact 40u content
# keylines: actions/HINT begin where the TAP/HOLD pill begins, and zoom ends
# where ABORT ends.
const HORIZONTAL_DOCK_EDGE_INSET := 40.0
const CONTROL_TARGET := 55.0
const CONTROL_TARGET_MOBILE := 132.0
const ZOOM_SECTION_GAP := 0
const ZOOM_HORIZONTAL_MOBILE_WIDTH := 486.0
const ZOOM_MOBILE_MINUS_X := 0.0
const ZOOM_MOBILE_TRACK_X := 132.0
const ZOOM_MOBILE_PLUS_X := 354.0
const ZOOM_READOUT_BUBBLE_SIZE := Vector2(50.0, 22.0)
const ZOOM_READOUT_BUBBLE_SIZE_MOBILE := Vector2(112.0, 52.0)
const ZOOM_READOUT_SIDE_GAP := 6.0
const ZOOM_READOUT_SIDE_GAP_MOBILE := 10.0
# INTEL seat. The zoom micro-slider keeps one stable width whether this command
# is present or not; only the command plate grows to host the button.
const HINT_SEAT_WIDTH_DESKTOP := 73.0
const HINT_SEAT_WIDTH_MOBILE := 175.0
const ZOOM_STEP_VISUAL := Vector2(44.0, 44.0)
const ZOOM_STEP_VISUAL_MOBILE := Vector2(104.0, 104.0)
# 65% alpha: command plates float over the map; they do not wall it off.
const DOCK_BG := Color(ControlPanelChrome.SURFACE, 0.65)
const DOCK_BORDER := ControlPanelChrome.KEYLINE
const DOCK_CONTROL := Color("29302F")
const DOCK_TEAL := Color("57A38A")
const DOCK_NEUTRAL := Color("AEB5BC")
const DOCK_KEYLINE_WIDTH := ControlPanelChrome.KEYLINE_WIDTH
const DOCK_CORNER_RADIUS := ControlPanelChrome.CORNER_RADIUS
# Reference rail dimensions. They grew when INTEL took a seat between the actions
# and the instrument, and again when the section keylines went from a sub-pixel
# 1u hairline to a line that actually renders (see _make_dock_divider).
const HORIZONTAL_DOCK_SIZE_DESKTOP := Vector2(614.0, 86.0)
const HORIZONTAL_DOCK_SIZE_MOBILE := Vector2(1110.0, 132.0)
const HORIZONTAL_DOCK_PADDING_LEFT_DESKTOP := 12.0
const HORIZONTAL_DOCK_PADDING_LEFT_MOBILE := 18.0
const HORIZONTAL_DOCK_PADDING_TOP_DESKTOP := 8.0
const HORIZONTAL_DOCK_PADDING_TOP_MOBILE := 0.0
const HORIZONTAL_DOCK_PADDING_RIGHT_DESKTOP := 12.0
const HORIZONTAL_DOCK_PADDING_RIGHT_MOBILE := 18.0
const HORIZONTAL_DOCK_PADDING_BOTTOM_DESKTOP := 8.0
const HORIZONTAL_DOCK_PADDING_BOTTOM_MOBILE := 0.0

# Dormant LEFT / RIGHT compatibility layouts use framed actions at the top, an
# unplated zoom instrument in the middle, and (when available) a framed HINT at
# the bottom. These tokens stay separate from the live fixed-bottom composition.
# Cap width is the horizontal selector's exact 368u mobile / 179u desktop
# footprint plus that rail's own side insets. Its thickness likewise matches
# the horizontal panel, so changing edge no longer changes the control rhythm.
const SIDE_DOCK_WIDTH_DESKTOP := 203.0
const SIDE_DOCK_WIDTH_MOBILE := 404.0
const SIDE_DOCK_PREFERRED_HEIGHT_DESKTOP := 420.0
const SIDE_DOCK_PREFERRED_HEIGHT_MOBILE := 736.0
const SIDE_DOCK_MIN_HEIGHT_DESKTOP := 330.0
const SIDE_DOCK_MIN_HEIGHT_MOBILE := 660.0
# A visible map gap keeps each side component independent while the transparent
# root preserves one stable placement/rebuild contract for the HUD.
const SIDE_PANEL_GAP_DESKTOP := 10.0
const SIDE_PANEL_GAP_MOBILE := 16.0
# A full-width action panel, compact HINT panel, and narrow unplated zoom lane.
# The lower panel hugs the actual hint ink with the
# same visual breathing room as the action shells, while its interaction seat
# retains the full mobile touch target.
const SIDE_CAP_PAD_DESKTOP := 12.0
const SIDE_CAP_PAD_MOBILE := 18.0
const SIDE_ACTION_CAP_HEIGHT_DESKTOP := 86.0
const SIDE_ACTION_CAP_HEIGHT_MOBILE := 132.0
const SIDE_STEM_WIDTH_DESKTOP := 76.0
const SIDE_STEM_WIDTH_MOBILE := 144.0
const SIDE_STEM_READOUT_HEIGHT_DESKTOP := 30.0
const SIDE_STEM_READOUT_HEIGHT_MOBILE := 48.0
const SIDE_VERTICAL_RULER_MIN_LENGTH := 40.0
const SIDE_HINT_CAP_HEIGHT_DESKTOP := 86.0
const SIDE_HINT_CAP_HEIGHT_MOBILE := 132.0
# Puzzle matches have no INTEL action. In the dormant side-layout compatibility
# path, their dock therefore stops after the zoom instrument instead of reserving
# the absent action's lower seat. Remove that seat and one of the two gaps to
# preserve the same compatibility geometry.
const SIDE_T_DOCK_PREFERRED_HEIGHT_DESKTOP := \
	SIDE_DOCK_PREFERRED_HEIGHT_DESKTOP - SIDE_HINT_CAP_HEIGHT_DESKTOP \
	- SIDE_PANEL_GAP_DESKTOP
const SIDE_T_DOCK_PREFERRED_HEIGHT_MOBILE := \
	SIDE_DOCK_PREFERRED_HEIGHT_MOBILE - SIDE_HINT_CAP_HEIGHT_MOBILE \
	- SIDE_PANEL_GAP_MOBILE
const SIDE_T_DOCK_MIN_HEIGHT_DESKTOP := \
	SIDE_DOCK_MIN_HEIGHT_DESKTOP - SIDE_HINT_CAP_HEIGHT_DESKTOP \
	- SIDE_PANEL_GAP_DESKTOP
const SIDE_T_DOCK_MIN_HEIGHT_MOBILE := \
	SIDE_DOCK_MIN_HEIGHT_MOBILE - SIDE_HINT_CAP_HEIGHT_MOBILE \
	- SIDE_PANEL_GAP_MOBILE
# Insets from the action cap to its outermost rendered button shells. Reusing
# these around the HINT ink makes the compact lower flange share the top cap's
# exact visual rhythm instead of sizing itself around an oversized empty target.
const SIDE_HINT_INK_PAD_X_DESKTOP := 15.0
const SIDE_HINT_INK_PAD_X_MOBILE := 24.0
const SIDE_HINT_INK_PAD_Y_DESKTOP := 25.0
const SIDE_HINT_INK_PAD_Y_MOBILE := 17.0
# Font.get_height() includes the typeface's invisible line box. These optical
# ink bounds match the actually painted amber capitals/diamond, so the visible
# top/bottom air equals the action shells instead of being several pixels looser.
const SIDE_HINT_OPTICAL_INK_HEIGHT_DESKTOP := 13.0
const SIDE_HINT_OPTICAL_INK_HEIGHT_MOBILE := 28.0
const SIDE_HINT_OPTICAL_OFFSET_Y_DESKTOP := 0.0
const SIDE_HINT_OPTICAL_OFFSET_Y_MOBILE := 0.0
const SIDE_ZOOM_STEP_VISUAL_DESKTOP := Vector2(44.0, 44.0)
const SIDE_ZOOM_STEP_VISUAL_MOBILE := Vector2(104.0, 104.0)

const ZoomRulerArt := preload("res://scripts/core/ZoomRulerArt.gd")

signal zoom_changed(zoom: float)   # emitted whenever the zoom level changes (tutorial tracks it)

# ── Host wiring (set in setup) ──
var board: Control
var hud: Control                 # owns TopBar / BottomBar; set_tap_mode(mode)
var _is_blocked: Callable        # () -> bool   (a modal / dialogue is up)
var _cancel_holds: Callable      # () -> void   (kill in-flight cell long-presses)
var _get_tap_mode: Callable      # () -> int
var _set_tap_mode: Callable      # (mode:int) -> void  (drive the external selector)
var _relayout_board: Callable    # () -> void   (host re-insets the board band on resize)
var _clamp_pan: Callable         # (zoom:float, proposed:Vector2) -> Vector2
var _get_play_frame: Callable    # () -> Rect2 (optional host-aware safe placement band)
var _puzzle_mode := false        # also feeds the dormant puzzle side-layout seam

# ── State ──
var _board_zoom := 1.0
var _board_base_pos := Vector2.ZERO
var _touches: Dictionary = {}
var _mouse_pan_armed := false
var _touch_gesture_consumed := false
var _touch_mouse_quiet_until := 0
const TOUCH_MOUSE_QUIET_MSEC := 700
var _pinching := false
var _pinch_last_dist := 0.0
var _pinch_last_mid := Vector2.ZERO
var _panning := false
var _pan_start := Vector2.ZERO
var _zoom_wrap: PanelContainer
var _dock_layout: BoxContainer
var _horizontal_action_plate: PanelContainer
# The keyline fencing INTEL off inside the rail. Held so it can follow the
# button's visibility instead of being decided once at build time.
var _hint_divider: Control
var _zoom_section: BoxContainer
var _zoom_label: Label
var _zoom_ruler: Control
var _zoom_out_button: Button
var _zoom_in_button: Button
var _zoom_readout_tween: Tween
var _zoom_readout_generation := 0
var _zoom_direction_tween: Tween
var _zoom_direction_generation := 0
var _active_zoom_direction := 0
var _active_zoom_icon_alpha := ZOOM_STEP_IDLE_ALPHA
var _zoom_direction_feedback_engaged := false
var _zoom_direction_changed_during_engagement := false
var _side_action_lane: Control    # top cap — the docked tap selector row
var _side_zoom_lane: Control      # the stem — readout, +, track, −
var _side_hint_cap: Control       # bottom cap — the seated INTEL button
var _side_zoom_responsive_horizontal := false
# Retired echo-badge handle kept null for compatibility probes; no node is built.
var _mode_badge: Control
var _zoom_built_pos := -1
var _rest_pan_enabled := false
var _dock_visible := true
var _subpixel_viewport: Viewport


func _enter_tree() -> void:
	# Also covers a configured controller being removed and re-added to a tree.
	_acquire_board_viewport.call_deferred()


func _exit_tree() -> void:
	BoardRendering.release(_subpixel_viewport)
	_subpixel_viewport = null


func _acquire_board_viewport() -> void:
	if not is_inside_tree() or not is_instance_valid(board) or not board.is_inside_tree():
		return
	var viewport := board.get_viewport()
	if viewport == _subpixel_viewport:
		return
	BoardRendering.release(_subpixel_viewport)
	_subpixel_viewport = viewport
	BoardRendering.acquire(_subpixel_viewport)

func setup(p_board: Control, p_hud: Control, p_is_blocked: Callable,
		p_cancel_holds: Callable, p_get_tap_mode: Callable,
		p_set_tap_mode: Callable, p_relayout_board: Callable,
		p_clamp_pan: Callable = Callable(),
		p_get_play_frame: Callable = Callable(),
		p_puzzle_mode: bool = false) -> void:
	board = p_board
	# Never toggle snapping per zoom step: switching it at 100% or on release
	# would introduce a new pop. One policy covers zoom, pan, and settled play.
	_acquire_board_viewport()
	# Capture the host's authored resting band immediately. Some targets begin at
	# a non-zero Y (classic boards/tutorials), while a geographic MapCanvas rests
	# at zero; resize restoration must preserve either shape exactly.
	_board_base_pos = board.position
	hud = p_hud
	_is_blocked = p_is_blocked
	_cancel_holds = p_cancel_holds
	_get_tap_mode = p_get_tap_mode
	_set_tap_mode = p_set_tap_mode
	_relayout_board = p_relayout_board
	_clamp_pan = p_clamp_pan
	_get_play_frame = p_get_play_frame
	_puzzle_mode = p_puzzle_mode
	build_column()
	position_column.call_deferred()

func _zoom_pos() -> int:
	# The action + zoom rail has one authored home in every orientation. Keep the
	# enum-valued seam so the dormant side builders remain compatibility-safe, but
	# never let a legacy saved edge move the live controls away from the bottom.
	return SaveData.ControlDockPosition.BOTTOM

func _zoom_horizontal() -> bool:
	return _zoom_pos() >= 2  # 2 bottom, 3 top → horizontal ruler


func _ruler_horizontal() -> bool:
	# The live fixed-BOTTOM rail is always horizontal. A dormant, height-constrained
	# LEFT/RIGHT compatibility layout may rotate only its ruler/step instrument.
	return _zoom_horizontal() or _side_zoom_responsive_horizontal

func get_zoom() -> float:
	return _board_zoom

func set_rest_pan_enabled(enabled: bool) -> void:
	_rest_pan_enabled = enabled
	_clamp_board_pan()

func can_pan() -> bool:
	return _board_zoom > 1.0 or _rest_pan_enabled

# The host changed the play band WITHOUT a viewport resize (an optional HUD row
# was toggled). `_board_base_pos` is the resting anchor every pan clamp snaps
# back to, so a stale one silently undoes the host's new inset. Rest the board
# first, let the host re-band it, then adopt the settled position as the anchor.
func release_board_to_rest() -> void:
	if not is_instance_valid(board):
		return
	if _board_zoom != 1.0 or board.position != _board_base_pos:
		_cancel_zoom_direction_feedback()
		_board_zoom = 1.0
		board.scale = Vector2.ONE
		board.position = _board_base_pos
		_update_zoom_indicator()


# Call one layout pass after the host re-insets: a Control's position only
# follows its new offsets on the next pass, so reading it sooner re-captures the
# old band.
func rebase_board_band() -> void:
	if not is_instance_valid(board):
		return
	_board_base_pos = board.position
	_clamp_board_pan()
	position_column()


# Re-apply the host's live bounds after the map image or viewport is reframed.
# Input paths already clamp every drag/zoom step; this public hook covers layout
# changes that move the legal image envelope without changing logical zoom.
func reclamp_pan() -> void:
	if is_instance_valid(board):
		_clamp_board_pan()

func column_node() -> Control:
	return _zoom_section

func dock_node() -> Control:
	return _zoom_wrap

func set_dock_visible(show: bool) -> void:
	# Keep this as controller state rather than a one-off node hide. A viewport or
	# orientation reflow may rebuild ControlDock; preserve the host's inspection
	# visibility choice for its actions, hint, and zoom ruler.
	_dock_visible = show
	if is_instance_valid(_zoom_wrap):
		_zoom_wrap.visible = show
	if not show:
		_hide_zoom_readout_immediate()
		_cancel_zoom_direction_feedback()

func _blocked() -> bool:
	return _is_blocked.is_valid() and bool(_is_blocked.call())

# ── Unified action + zoom command dock ──
func build_column() -> void:
	_cancel_zoom_readout_tween()
	_cancel_zoom_direction_feedback()
	_zoom_built_pos = _zoom_pos()
	var horizontal := _zoom_horizontal()
	if horizontal:
		_side_zoom_responsive_horizontal = false
	_zoom_wrap = PanelContainer.new()
	_zoom_wrap.name = "ControlDock"
	_zoom_wrap.visible = _dock_visible
	_zoom_wrap.set_meta("control_dock", true)
	_zoom_wrap.set_meta("dock_position", _zoom_built_pos)
	_zoom_wrap.set_meta("horizontal", horizontal)
	_zoom_wrap.set_meta("pan_start_policy",
		"interactive_regions_only" if horizontal \
		else "painted_and_interactive_regions_only")
	_publish_zoom_direction_state()
	if horizontal:
		_zoom_wrap.custom_minimum_size = HORIZONTAL_DOCK_SIZE_MOBILE \
			if Platform.is_mobile() else HORIZONTAL_DOCK_SIZE_DESKTOP
	_zoom_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The composite root owns placement only. Chrome belongs to the controls that
	# need a backing plate; the zoom instrument deliberately floats over the map.
	_zoom_wrap.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_dock_layout = HBoxContainer.new() if horizontal else VBoxContainer.new()
	_dock_layout.name = "ControlDockLayout"
	_dock_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	_dock_layout.add_theme_constant_override("separation", DOCK_GAP)
	_dock_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom_wrap.add_child(_dock_layout)
	hud.add_child(_zoom_wrap)
	if not horizontal:
		_build_side_column()
		_update_zoom_indicator()
		return

	# The fixed BOTTOM rail uses one invisible geometry host for tap actions + INTEL. It
	# preserves the proven spacing and touch rectangles while the actions float
	# directly over the map beside the already-unplated zoom instrument.
	_horizontal_action_plate = PanelContainer.new()
	_horizontal_action_plate.name = "ControlActionsPanel"
	_horizontal_action_plate.set_meta("control_dock_panel_role", "actions_hint")
	_horizontal_action_plate.set_meta("presentation", "floating_row")
	_horizontal_action_plate.set_meta("shellless", true)
	_horizontal_action_plate.set_meta("corner_brackets", false)
	_horizontal_action_plate.set_meta("baseline", false)
	_horizontal_action_plate.set_meta("shared_centerline", true)
	_horizontal_action_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_horizontal_action_plate.add_theme_stylebox_override("panel", _dock_style())
	var action_layout := HBoxContainer.new()
	action_layout.name = "ControlActionsLayout"
	action_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	action_layout.add_theme_constant_override("separation", DOCK_GAP)
	action_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_layout.set_meta("shared_centerline", true)
	action_layout.set_meta("leading_content_inset",
		HORIZONTAL_DOCK_PADDING_LEFT_MOBILE if Platform.is_mobile() \
		else HORIZONTAL_DOCK_PADDING_LEFT_DESKTOP)
	_horizontal_action_plate.add_child(action_layout)
	_dock_layout.add_child(_horizontal_action_plate)
	_zoom_wrap.set_meta("horizontal_panel_count", 0)
	_zoom_wrap.set_meta("horizontal_painted_chrome", false)
	_zoom_wrap.set_meta("shared_centerline", true)

	# HUD retains ownership of the selector and its signals; the plate only hosts
	# it while the dock is alive.
	if hud.has_method("dock_tap_selector"):
		hud.call("dock_tap_selector", action_layout, true)

	# INTEL shares the floating row with the selector. The transparent legacy
	# divider remains only as a width-preserving spacer, so hiding INTEL still
	# collapses the exact same geometry without painting a vertical rule.
	var hint_seat := _hint_seat_button()
	if hint_seat != null:
		_hint_divider = _make_dock_divider("ControlDockDivider", horizontal)
		action_layout.add_child(_hint_divider)
		hud.call("dock_hint_button", action_layout,
			Vector2(_hint_seat_width(), CONTROL_TARGET_MOBILE \
				if Platform.is_mobile() else CONTROL_TARGET))
		_sync_hint_divider()
		if not hint_seat.visibility_changed.is_connected(_sync_hint_divider):
			hint_seat.visibility_changed.connect(_sync_hint_divider)
	elif hud != null and hud.has_method("release_hint_button_from_dock"):
		hud.call("release_hint_button_from_dock")

	# The command rail is deliberately open across its middle. This spacer absorbs
	# the live viewport width while remaining pointer-transparent, pinning the
	# actions/HINT to the footer's leading keyline and the zoom instrument to its
	# trailing keyline without creating a map-input dead zone.
	var rail_spacer := Control.new()
	rail_spacer.name = "ControlDockSpacer"
	rail_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rail_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rail_spacer.set_meta("control_dock_role", "open_spacer")
	rail_spacer.set_meta("input_passthrough", true)
	_dock_layout.add_child(rail_spacer)

	_zoom_section = HBoxContainer.new() if horizontal else VBoxContainer.new()
	_zoom_section.name = "ZoomControls"
	_zoom_section.set_meta("control_dock_role", "zoom")
	_zoom_section.set_meta("shared_centerline", true)
	_zoom_section.alignment = BoxContainer.ALIGNMENT_CENTER
	_zoom_section.add_theme_constant_override("separation", ZOOM_SECTION_GAP)
	_zoom_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dock_layout.add_child(_zoom_section)
	var horizontal_instrument: Control
	var zoom_parent: Control = _zoom_section
	if Platform.is_mobile() and horizontal:
		horizontal_instrument = Control.new()
		horizontal_instrument.name = "ZoomHorizontalInstrument"
		horizontal_instrument.custom_minimum_size = Vector2(
			_mobile_instrument_width(hint_seat != null), CONTROL_TARGET_MOBILE)
		horizontal_instrument.mouse_filter = Control.MOUSE_FILTER_IGNORE
		horizontal_instrument.set_meta("non_overlapping_hit_layout", true)
		_zoom_section.add_child(horizontal_instrument)
		zoom_parent = horizontal_instrument

	_zoom_out_button = _make_zoom_step_button("ZoomOutButton", -ZOOM_STEP)
	_zoom_in_button = _make_zoom_step_button("ZoomInButton", ZOOM_STEP)
	if horizontal:
		zoom_parent.add_child(_zoom_out_button)
	_zoom_ruler = Control.new()
	_zoom_ruler.name = "ZoomTrack"
	_zoom_ruler.set_meta("control_dock_role", "zoom_track")
	_zoom_ruler.set_meta("live_horizontal", true)
	_configure_zoom_ruler_accessibility()
	var cross_band := CONTROL_TARGET_MOBILE if Platform.is_mobile() \
		else ZOOM_RULER_BAND
	var ruler_length := _horizontal_ruler_length(hint_seat != null)
	var side_length := maxf(ZOOM_RULER_SIDE_LENGTH,
		(CONTROL_TARGET_MOBILE if Platform.is_mobile() else CONTROL_TARGET) * 2.0 + 8.0)
	_zoom_ruler.custom_minimum_size = Vector2(ruler_length, cross_band) \
		if horizontal else Vector2(cross_band,
			maxf(side_length, ruler_length))
	_zoom_ruler.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_zoom_ruler.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_zoom_ruler.clip_contents = false
	_zoom_ruler.mouse_filter = Control.MOUSE_FILTER_STOP
	_zoom_ruler.mouse_default_cursor_shape = Control.CURSOR_HSIZE
	_zoom_ruler.gui_input.connect(_on_zoom_ruler_input)
	_zoom_ruler.draw.connect(func(): ZoomRulerArt.draw(_zoom_ruler, _board_zoom,
		ZOOM_MIN, ZOOM_MAX, _ruler_horizontal(),
		_horizontal_ruler_trailing_extension()))
	_zoom_ruler.resized.connect(_position_zoom_readout)
	_zoom_label = _make_zoom_readout_label()
	_zoom_ruler.add_child(_zoom_label)
	if horizontal:
		zoom_parent.add_child(_zoom_ruler)
		zoom_parent.add_child(_zoom_in_button)
		if horizontal_instrument != null:
			_layout_mobile_horizontal_instrument(horizontal_instrument)
	else:
		# Keep the public side dock/zoom contracts vertical while using one compact
		# instrument row inside it. The +/− buttons align with the vertical ruler's
		# high/low ends instead of stacking another 264 units above and below it.
		var side_row := HBoxContainer.new()
		side_row.name = "SideZoomRow"
		side_row.alignment = BoxContainer.ALIGNMENT_CENTER
		side_row.add_theme_constant_override("separation", 8)
		side_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_zoom_section.add_child(side_row)
		side_row.add_child(_zoom_ruler)
		var step_column := VBoxContainer.new()
		step_column.name = "ZoomStepButtons"
		step_column.alignment = BoxContainer.ALIGNMENT_CENTER
		step_column.add_theme_constant_override("separation", 8)
		step_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		step_column.add_child(_zoom_in_button)
		step_column.add_child(_zoom_out_button)
		side_row.add_child(step_column)
	_update_zoom_indicator()


# Dormant LEFT / RIGHT compatibility layouts intentionally use their own builder.
# Keeping this branch out of the live horizontal builder protects the approved
# fixed-BOTTOM rail while retaining parse-safe support for older callers.
func _build_side_column() -> void:
	var mobile := Platform.is_mobile()
	var puzzle_t := _puzzle_mode
	_side_zoom_responsive_horizontal = false
	var preferred_size := Vector2(
		SIDE_DOCK_WIDTH_MOBILE if mobile else SIDE_DOCK_WIDTH_DESKTOP,
		(SIDE_T_DOCK_PREFERRED_HEIGHT_MOBILE if mobile \
			else SIDE_T_DOCK_PREFERRED_HEIGHT_DESKTOP) if puzzle_t else \
		(SIDE_DOCK_PREFERRED_HEIGHT_MOBILE if mobile \
			else SIDE_DOCK_PREFERRED_HEIGHT_DESKTOP))
	_zoom_wrap.custom_minimum_size = preferred_size
	_zoom_wrap.size = preferred_size
	_zoom_wrap.set_meta("side_layout", true)
	_zoom_wrap.set_meta("side_detached_layout", true)
	_zoom_wrap.set_meta("side_i_layout", false)
	_zoom_wrap.set_meta("side_t_layout", false)
	_zoom_wrap.set_meta("side_panel_count", 1 if puzzle_t else 2)
	_zoom_wrap.set_meta("side_zoom_layout", "vertical")
	_zoom_wrap.set_meta("side_panel_gap",
		SIDE_PANEL_GAP_MOBILE if mobile else SIDE_PANEL_GAP_DESKTOP)
	# LEFT and RIGHT wear the identical detached column; only root placement
	# changes, so there is no mirrored lane order.
	_zoom_wrap.set_meta("mirrored", false)
	_zoom_wrap.set_meta("preferred_size", preferred_size)
	_zoom_wrap.set_meta("minimum_side_height",
		(SIDE_T_DOCK_MIN_HEIGHT_MOBILE if mobile \
			else SIDE_T_DOCK_MIN_HEIGHT_DESKTOP) if puzzle_t else \
		(SIDE_DOCK_MIN_HEIGHT_MOBILE if mobile \
			else SIDE_DOCK_MIN_HEIGHT_DESKTOP))
	_zoom_wrap.set_meta("side_plate_material", {
		"fill": DOCK_BG,
		"border": ControlPanelChrome.KEYLINE,
		"border_width": ControlPanelChrome.KEYLINE_WIDTH,
		"corner_radius": ControlPanelChrome.CORNER_RADIUS,
		"shadow": ControlPanelChrome.SHADOW,
		"shadow_size": ControlPanelChrome.SHADOW_SIZE,
	})
	_dock_layout.add_theme_constant_override("separation",
		roundi(SIDE_PANEL_GAP_MOBILE if mobile else SIDE_PANEL_GAP_DESKTOP))
	# The root remains transparent. Only the action and optional INTEL caps paint
	# rounded panels; the center zoom instrument floats directly over the map.
	_zoom_wrap.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_zoom_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not _zoom_wrap.draw.is_connected(_draw_side_panels):
		_zoom_wrap.draw.connect(_draw_side_panels)

	_side_action_lane = Control.new()
	_side_action_lane.name = "SideActionCap"
	_side_action_lane.custom_minimum_size.y = SIDE_ACTION_CAP_HEIGHT_MOBILE \
		if mobile else SIDE_ACTION_CAP_HEIGHT_DESKTOP
	_side_action_lane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side_action_lane.mouse_filter = Control.MOUSE_FILTER_STOP
	_side_action_lane.set_meta("side_cap_role", "actions")
	_side_action_lane.set_meta("side_panel_role", "actions")
	_dock_layout.add_child(_side_action_lane)

	_zoom_section = VBoxContainer.new()
	_zoom_section.name = "ZoomControls"
	_zoom_section.set_meta("control_dock_role", "zoom")
	_zoom_section.set_meta("side_zoom_instrument", true)
	_zoom_section.set_meta("side_instrument_role", "zoom")
	_zoom_section.set_meta("side_zoom_layout", "vertical")
	_zoom_section.alignment = BoxContainer.ALIGNMENT_CENTER
	_zoom_section.add_theme_constant_override("separation", 0)
	# The stem has no painted panel, so only its concrete controls consume input.
	_zoom_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom_section.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_zoom_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_zoom_section.custom_minimum_size.x = SIDE_STEM_WIDTH_MOBILE if mobile \
		else SIDE_STEM_WIDTH_DESKTOP
	_side_zoom_lane = Control.new()
	_side_zoom_lane.name = "SideStemLayout"
	_side_zoom_lane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side_zoom_lane.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_side_zoom_lane.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_side_zoom_lane.set_meta("side_zoom_lane", true)
	_side_zoom_lane.set_meta("side_zoom_layout", "vertical")
	_zoom_section.add_child(_side_zoom_lane)
	_dock_layout.add_child(_zoom_section)

	# Puzzle mode has no HINT button, so it owns no lower interaction seat,
	# panel, or second gap.
	if not puzzle_t:
		_side_hint_cap = Control.new()
		_side_hint_cap.name = "SideHintCap"
		_side_hint_cap.custom_minimum_size = Vector2(
			HINT_SEAT_WIDTH_MOBILE if mobile else HINT_SEAT_WIDTH_DESKTOP,
			SIDE_HINT_CAP_HEIGHT_MOBILE if mobile \
				else SIDE_HINT_CAP_HEIGHT_DESKTOP)
		_side_hint_cap.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_side_hint_cap.mouse_filter = Control.MOUSE_FILTER_STOP
		_side_hint_cap.set_meta("side_cap_role", "hint")
		_side_hint_cap.set_meta("side_panel_role", "hint")
		_dock_layout.add_child(_side_hint_cap)

	# The top cap seats the tap selector as a horizontal row. Ordinary play seats
	# INTEL below; puzzles intentionally stop after the zoom stem.
	if hud.has_method("dock_tap_selector"):
		hud.call("dock_tap_selector", _side_action_lane, true, true)
	if is_instance_valid(_side_hint_cap) and hud.has_method("dock_hint_button"):
		var hint_size := Vector2(
			HINT_SEAT_WIDTH_MOBILE if mobile else HINT_SEAT_WIDTH_DESKTOP,
			CONTROL_TARGET_MOBILE if mobile else CONTROL_TARGET)
		hud.call("dock_hint_button", _side_hint_cap, hint_size)
		var hint := hud.call("hint_button") as Button \
			if hud.has_method("hint_button") else null
		if hint != null:
			var ink_size := _side_hint_ink_size(hint)
			var plate_size := Vector2(
				ink_size.x + (SIDE_HINT_INK_PAD_X_MOBILE if mobile \
					else SIDE_HINT_INK_PAD_X_DESKTOP) * 2.0,
				ink_size.y + (SIDE_HINT_INK_PAD_Y_MOBILE if mobile \
					else SIDE_HINT_INK_PAD_Y_DESKTOP) * 2.0)
			plate_size = plate_size.ceil()
			_side_hint_cap.custom_minimum_size.x = plate_size.x
			_side_hint_cap.set_meta("hint_ink_size", ink_size)
			_side_hint_cap.set_meta("hint_plate_size", plate_size)
			_side_hint_cap.set_meta("hint_plate_offset_y",
				SIDE_HINT_OPTICAL_OFFSET_Y_MOBILE if mobile \
					else SIDE_HINT_OPTICAL_OFFSET_Y_DESKTOP)
			# The transparent Button remains a full-height accessible target; only
			# the painted flange contracts around its centered text.
			hint.custom_minimum_size.x = plate_size.x

	_zoom_out_button = _make_zoom_step_button("ZoomOutButton", -ZOOM_STEP)
	_zoom_in_button = _make_zoom_step_button("ZoomInButton", ZOOM_STEP)
	_set_side_step_visual(_zoom_in_button)
	_set_side_step_visual(_zoom_out_button)
	_side_zoom_lane.add_child(_zoom_in_button)

	_zoom_ruler = Control.new()
	_zoom_ruler.name = "ZoomTrack"
	_zoom_ruler.set_meta("control_dock_role", "zoom_track")
	_zoom_ruler.set_meta("side_vertical_track", true)
	_zoom_ruler.set_meta("side_horizontal_track", false)
	_zoom_ruler.set_meta("live_horizontal", false)
	_configure_zoom_ruler_accessibility()
	var track_band := CONTROL_TARGET_MOBILE if mobile else ZOOM_RULER_BAND
	_zoom_ruler.custom_minimum_size = Vector2(track_band, 1.0)
	_zoom_ruler.clip_contents = false
	_zoom_ruler.mouse_filter = Control.MOUSE_FILTER_STOP
	_zoom_ruler.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	_zoom_ruler.gui_input.connect(_on_zoom_ruler_input)
	_zoom_ruler.draw.connect(func(): ZoomRulerArt.draw(_zoom_ruler,
		_board_zoom, ZOOM_MIN, ZOOM_MAX, _ruler_horizontal()))
	_zoom_ruler.resized.connect(_position_zoom_readout)
	_zoom_label = _make_zoom_readout_label()
	_zoom_ruler.add_child(_zoom_label)
	_side_zoom_lane.add_child(_zoom_ruler)
	_side_zoom_lane.add_child(_zoom_out_button)

	_zoom_wrap.resized.connect(_layout_side_dock)
	_side_zoom_lane.resized.connect(_layout_side_stem)
	_layout_side_dock.call_deferred()


func _set_side_step_visual(button: Button) -> void:
	var visual := button.find_child("*Visual", true, false) as Control
	if visual == null:
		return
	var visual_size := SIDE_ZOOM_STEP_VISUAL_MOBILE if Platform.is_mobile() \
		else SIDE_ZOOM_STEP_VISUAL_DESKTOP
	visual.set_meta("visual_size", visual_size)
	visual.set_meta("side_visual", true)
	_position_zoom_step_visual(button)


func _side_hint_ink_size(hint: Button) -> Vector2:
	if hint == null:
		return Vector2.ZERO
	var font := hint.get_theme_font("font")
	var font_size := hint.get_theme_font_size("font_size")
	return Vector2(
		ceilf(font.get_string_size(hint.text, HORIZONTAL_ALIGNMENT_LEFT,
			-1.0, font_size).x),
		SIDE_HINT_OPTICAL_INK_HEIGHT_MOBILE if Platform.is_mobile() \
			else SIDE_HINT_OPTICAL_INK_HEIGHT_DESKTOP)


func _layout_side_dock() -> void:
	if not is_instance_valid(_side_action_lane) \
			or not is_instance_valid(_zoom_section):
		return
	# Center the seated selector row in the top cap.
	var selector := hud.call("selector_node") as Control \
		if hud != null and hud.has_method("selector_node") else null
	if selector != null and selector.get_parent() == _side_action_lane:
		var selector_size := selector.get_combined_minimum_size()
		selector.size = selector_size
		selector.position = Vector2(
			maxf(0.0, (_side_action_lane.size.x - selector_size.x) * 0.5),
			maxf(0.0, (_side_action_lane.size.y - selector_size.y) * 0.5))
	# Center the seated INTEL button in the bottom cap.
	var hint := hud.call("hint_button") as Control \
		if hud != null and hud.has_method("hint_button") else null
	if hint != null and hint.get_parent() == _side_hint_cap:
		var hint_size := hint.custom_minimum_size
		hint.size = hint_size
		hint.position = (_side_hint_cap.size - hint_size) * 0.5
	var plate_rects := _side_plate_rects()
	_zoom_wrap.set_meta("side_plate_rects", plate_rects)
	if is_instance_valid(_side_hint_cap):
		_zoom_wrap.set_meta("side_hint_interaction_rect",
			Rect2(_side_hint_cap.position, _side_hint_cap.size))
	elif _zoom_wrap.has_meta("side_hint_interaction_rect"):
		_zoom_wrap.remove_meta("side_hint_interaction_rect")
	_zoom_wrap.queue_redraw()
	_layout_side_stem.call_deferred()


func _layout_side_stem() -> void:
	if not is_instance_valid(_side_zoom_lane) \
			or not is_instance_valid(_zoom_in_button) \
			or not is_instance_valid(_zoom_out_button) \
			or not is_instance_valid(_zoom_ruler):
		return
	var mobile := Platform.is_mobile()
	var target := CONTROL_TARGET_MOBILE if mobile else CONTROL_TARGET
	var readout_height := SIDE_STEM_READOUT_HEIGHT_MOBILE if mobile \
		else SIDE_STEM_READOUT_HEIGHT_DESKTOP
	var lane_size := _side_zoom_lane.size
	if lane_size.y <= 0.0:
		return
	var vertical_min_height := readout_height + target * 2.0 \
		+ SIDE_VERTICAL_RULER_MIN_LENGTH
	var responsive_horizontal := lane_size.y < vertical_min_height
	_zoom_wrap.set_meta("side_vertical_min_height", vertical_min_height)
	_side_zoom_lane.set_meta("vertical_min_height", vertical_min_height)
	var wanted_width := (SIDE_DOCK_WIDTH_MOBILE if mobile \
		else SIDE_DOCK_WIDTH_DESKTOP) if responsive_horizontal else \
		(SIDE_STEM_WIDTH_MOBILE if mobile else SIDE_STEM_WIDTH_DESKTOP)
	# VBoxContainer owns the section width. Change its minimum first, then lay out
	# after the container has expanded/contracted the live lane; drawing against the
	# stale width would produce a one-frame collapsed ruler during rotation.
	if not is_equal_approx(_zoom_section.custom_minimum_size.x, wanted_width) \
			or not is_equal_approx(lane_size.x, wanted_width):
		_zoom_section.custom_minimum_size.x = wanted_width
		_zoom_section.update_minimum_size()
		if is_instance_valid(_dock_layout):
			_dock_layout.queue_sort()
		_layout_side_stem.call_deferred()
		return

	_side_zoom_responsive_horizontal = responsive_horizontal
	var layout_name := "responsive_horizontal" if responsive_horizontal \
		else "vertical"
	_zoom_wrap.set_meta("side_zoom_layout", layout_name)
	_zoom_section.set_meta("side_zoom_layout", layout_name)
	_side_zoom_lane.set_meta("side_zoom_layout", layout_name)
	_zoom_ruler.set_meta("live_horizontal", responsive_horizontal)
	_zoom_ruler.set_meta("side_horizontal_track", responsive_horizontal)
	_zoom_ruler.set_meta("side_vertical_track", not responsive_horizontal)
	_zoom_ruler.mouse_default_cursor_shape = Control.CURSOR_HSIZE \
		if responsive_horizontal else Control.CURSOR_VSIZE
	_position_zoom_step_visuals()

	if responsive_horizontal:
		var row_y := maxf(0.0, (lane_size.y - target) * 0.5)
		row_y = minf(row_y, maxf(0.0, lane_size.y - target))
		var track_width := maxf(1.0, lane_size.x - target * 2.0)
		_zoom_out_button.position = Vector2(0.0, row_y)
		_zoom_out_button.size = Vector2(target, target)
		_zoom_ruler.position = Vector2(target, row_y)
		_zoom_ruler.size = Vector2(track_width, target)
		_zoom_in_button.position = Vector2(target + track_width, row_y)
		_zoom_in_button.size = Vector2(target, target)
		_side_zoom_lane.set_meta("responsive_row_rect",
			Rect2(0.0, row_y, lane_size.x, target))
	else:
		if _side_zoom_lane.has_meta("responsive_row_rect"):
			_side_zoom_lane.remove_meta("responsive_row_rect")
		var button_x := (lane_size.x - target) * 0.5
		_zoom_in_button.position = Vector2(button_x, 0.0)
		_zoom_in_button.size = Vector2(target, target)
		_zoom_out_button.position = Vector2(button_x, lane_size.y - target)
		_zoom_out_button.size = Vector2(target, target)
		_zoom_ruler.position = Vector2(0.0, target)
		_zoom_ruler.size = Vector2(lane_size.x,
			maxf(1.0, lane_size.y - target * 2.0))
	_zoom_ruler.set_meta("live_side_rect",
		Rect2(_zoom_ruler.position, _zoom_ruler.size))
	_zoom_ruler.queue_redraw()
	_position_zoom_readout.call_deferred()


# The independently painted side panels in wrap-local space. `hint_seat` is the
# larger invisible accessible target; `hint_cap` is its compact visible panel.
func _side_plate_rects() -> Dictionary:
	var rects := {}
	if is_instance_valid(_side_action_lane):
		rects["top_cap"] = Rect2(_side_action_lane.position,
			_side_action_lane.size)
	if is_instance_valid(_side_hint_cap):
		var hint_seat := Rect2(_side_hint_cap.position, _side_hint_cap.size)
		var requested_size := _side_hint_cap.get_meta("hint_plate_size",
			hint_seat.size) as Vector2
		var plate_size := Vector2(
			minf(requested_size.x, hint_seat.size.x),
			minf(requested_size.y, hint_seat.size.y))
		var hint_cap := Rect2(
			hint_seat.position + (hint_seat.size - plate_size) * 0.5,
			plate_size)
		hint_cap.position.y += float(_side_hint_cap.get_meta(
			"hint_plate_offset_y", 0.0))
		rects["hint_cap"] = hint_cap
		rects["hint_seat"] = hint_seat
	return rects


# The action and INTEL caps use the same rounded material as the horizontal
# command plate. The zoom stem is deliberately omitted so the map shows through.
func _draw_side_panels() -> void:
	if not is_instance_valid(_zoom_wrap):
		return
	var rects := _side_plate_rects()
	if not rects.has("top_cap"):
		return
	var style := ControlPanelChrome.make_style(0.0, 0.0, 0.0, 0.0)
	style.bg_color = DOCK_BG
	_zoom_wrap.draw_style_box(style, rects["top_cap"] as Rect2)
	var drawn := 1
	if rects.has("hint_cap"):
		_zoom_wrap.draw_style_box(style, rects["hint_cap"] as Rect2)
		drawn += 1
	_zoom_wrap.set_meta("side_panel_draw_count", drawn)


func _apply_side_dock_size(frame: Rect2) -> void:
	if _zoom_horizontal() or not is_instance_valid(_zoom_wrap):
		return
	var mobile := Platform.is_mobile()
	var width := SIDE_DOCK_WIDTH_MOBILE if mobile else SIDE_DOCK_WIDTH_DESKTOP
	var preferred := (SIDE_T_DOCK_PREFERRED_HEIGHT_MOBILE if mobile \
		else SIDE_T_DOCK_PREFERRED_HEIGHT_DESKTOP) if _puzzle_mode else \
		(SIDE_DOCK_PREFERRED_HEIGHT_MOBILE if mobile \
		else SIDE_DOCK_PREFERRED_HEIGHT_DESKTOP)
	var minimum := (SIDE_T_DOCK_MIN_HEIGHT_MOBILE if mobile \
		else SIDE_T_DOCK_MIN_HEIGHT_DESKTOP) if _puzzle_mode else \
		(SIDE_DOCK_MIN_HEIGHT_MOBILE if mobile \
		else SIDE_DOCK_MIN_HEIGHT_DESKTOP)
	var available := maxf(1.0, frame.size.y - DOCK_EDGE_GAP * 2.0)
	var live_height := minf(preferred, available)
	if available >= minimum:
		live_height = maxf(minimum, live_height)
	var live_size := Vector2(width, live_height)
	_zoom_wrap.custom_minimum_size = live_size
	_zoom_wrap.size = live_size
	_zoom_wrap.set_meta("live_side_size", live_size)
	_zoom_wrap.set_meta("side_height_clamped", live_height < preferred)
	_layout_side_dock.call_deferred()


# INTEL sizing remains independent from the zoom micro-slider. The slider owns
# three adjacent, non-overlapping hit regions; its visual gaps come from the
# smaller shells and inset hairline rather than dead or overlapping targets.
func _hint_seat_width() -> float:
	return HINT_SEAT_WIDTH_MOBILE if Platform.is_mobile() \
		else HINT_SEAT_WIDTH_DESKTOP


func _horizontal_ruler_length(_seated: bool) -> float:
	return ZOOM_RULER_LENGTH_MOBILE if Platform.is_mobile() \
		else ZOOM_RULER_LENGTH


func _mobile_instrument_width(_seated: bool) -> float:
	return ZOOM_HORIZONTAL_MOBILE_WIDTH


# Any host with an INTEL button buys a seat, visible or not. Gating on
# visibility looked equivalent and was not: the button is installed hidden and
# revealed later, so whenever the rail happened to build first the action was
# released to the footer and stayed there for the rest of the match — the same
# control living in two different places depending on frame ordering.
func _hint_seat_button() -> Button:
	if hud == null or not hud.has_method("hint_button") \
			or not hud.has_method("dock_hint_button"):
		return null
	return hud.call("hint_button") as Button


# The seat is permanent; only its transparent spacing shim comes and goes with
# the button. Keeping the node avoids shifting the long-tested row geometry.
func _sync_hint_divider() -> void:
	if not is_instance_valid(_hint_divider):
		return
	var btn := _hint_seat_button()
	_hint_divider.visible = btn != null and btn.visible


# Retained width tokens for the transparent spacing shim between actions and
# HINT. It deliberately paints no line in the floating horizontal treatment.
const DOCK_DIVIDER_THICKNESS_MOBILE := 3.0
const DOCK_DIVIDER_THICKNESS_DESKTOP := 2.0
const DOCK_DIVIDER_INK := Color("50615B", 0.62)

func _make_dock_divider(node_name: String, horizontal: bool) -> ColorRect:
	var divider := ColorRect.new()
	divider.name = node_name
	divider.color = Color.TRANSPARENT
	var thickness := DOCK_DIVIDER_THICKNESS_MOBILE if Platform.is_mobile() \
		else DOCK_DIVIDER_THICKNESS_DESKTOP
	divider.set_meta("visual_role", "spacing")
	divider.set_meta("painted", false)
	divider.set_meta("baseline", false)
	divider.set_meta("thickness", thickness)
	divider.custom_minimum_size = Vector2(thickness, 64.0) if horizontal \
		else Vector2(170.0, thickness)
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return divider


func _layout_mobile_horizontal_instrument(instrument: Control) -> void:
	var target := CONTROL_TARGET_MOBILE
	var track_length := ZOOM_RULER_LENGTH_MOBILE
	instrument.size = Vector2(ZOOM_HORIZONTAL_MOBILE_WIDTH, target)
	_zoom_out_button.position = Vector2(ZOOM_MOBILE_MINUS_X, 0.0)
	_zoom_out_button.size = Vector2(target, target)
	_zoom_ruler.position = Vector2(ZOOM_MOBILE_TRACK_X, 0.0)
	_zoom_ruler.size = Vector2(track_length, target)
	_zoom_in_button.position = Vector2(ZOOM_MOBILE_PLUS_X, 0.0)
	_zoom_in_button.size = Vector2(target, target)
	_position_zoom_step_visuals()
	_position_zoom_readout.call_deferred()

func _dock_style() -> StyleBoxEmpty:
	# This is a shell-less action seat. Retain the small content margin that keeps
	# every full accessibility target inside its panel; HUD aligns the selected
	# action's painted halo independently of that invisible layout inset.
	var style := StyleBoxEmpty.new()
	style.content_margin_left = HORIZONTAL_DOCK_PADDING_LEFT_MOBILE \
		if Platform.is_mobile() else HORIZONTAL_DOCK_PADDING_LEFT_DESKTOP
	style.content_margin_top = HORIZONTAL_DOCK_PADDING_TOP_MOBILE \
		if Platform.is_mobile() else HORIZONTAL_DOCK_PADDING_TOP_DESKTOP
	style.content_margin_right = HORIZONTAL_DOCK_PADDING_RIGHT_MOBILE \
		if Platform.is_mobile() else HORIZONTAL_DOCK_PADDING_RIGHT_DESKTOP
	style.content_margin_bottom = HORIZONTAL_DOCK_PADDING_BOTTOM_MOBILE \
		if Platform.is_mobile() else HORIZONTAL_DOCK_PADDING_BOTTOM_DESKTOP
	return style

func _make_zoom_step_button(node_name: String, delta: float) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = ""
	var accessibility_copy := ZOOM_IN_ACCESSIBILITY_NAME if delta > 0.0 \
		else ZOOM_OUT_ACCESSIBILITY_NAME
	button.accessibility_name = accessibility_copy
	button.tooltip_text = accessibility_copy
	var target := CONTROL_TARGET_MOBILE if Platform.is_mobile() else CONTROL_TARGET
	button.custom_minimum_size = Vector2(target, target)
	# The empty focus StyleBox preserves the authored visuals while the real Button
	# remains reachable and activatable through ordinary keyboard/controller focus.
	button.focus_mode = Control.FOCUS_ALL
	button.flat = true
	button.set_meta("ui_click", true)
	button.set_meta("control_dock_role", "zoom_step")
	button.set_meta("zoom_direction", "in" if delta > 0.0 else "out")
	button.set_meta("keyboard_activatable", true)
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, empty)
	var visual := Control.new()
	visual.name = "%sVisual" % node_name
	visual.set_meta("control_dock_visual", true)
	visual.set_meta("control_dock_visual_role", "zoom_step")
	visual.set_meta("zoom_icon_style", "magnifier")
	visual.set_meta("zoom_icon_modifier", "plus" if delta > 0.0 else "minus")
	visual.set_meta("shellless", true)
	visual.set_meta("base_opacity", ZOOM_STEP_IDLE_ALPHA)
	visual.set_meta("active_opacity", ZOOM_STEP_ACTIVE_ALPHA)
	var visual_size := ZOOM_STEP_VISUAL_MOBILE if Platform.is_mobile() \
		else ZOOM_STEP_VISUAL
	visual.set_meta("visual_size", visual_size)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.draw.connect(func(): _draw_zoom_step_visual(visual, button, delta))
	button.add_child(visual)
	_position_zoom_step_visual(button)
	button.mouse_entered.connect(visual.queue_redraw)
	button.mouse_exited.connect(visual.queue_redraw)
	button.button_down.connect(visual.queue_redraw)
	button.button_up.connect(visual.queue_redraw)
	button.focus_entered.connect(visual.queue_redraw)
	button.focus_exited.connect(visual.queue_redraw)
	button.pressed.connect(func() -> void:
		if not _blocked():
			_set_zoom_hud_bright(true)
			_set_zoom_centered(_board_zoom + delta)
			_set_zoom_hud_bright(false))
	return button


func _position_zoom_step_visual(button: Button) -> void:
	if not is_instance_valid(button):
		return
	var visual := button.find_child("*Visual", true, false) as Control
	if visual == null:
		return
	var visual_size := visual.get_meta("visual_size",
		ZOOM_STEP_VISUAL_MOBILE if Platform.is_mobile() \
		else ZOOM_STEP_VISUAL) as Vector2
	var magnitude := ZOOM_STEP_RAILWARD_OFFSET_MOBILE \
		if Platform.is_mobile() else ZOOM_STEP_RAILWARD_OFFSET
	var zoom_in := str(button.get_meta("zoom_direction", "out")) == "in"
	var railward := Vector2.ZERO
	if _ruler_horizontal():
		railward.x = -magnitude if zoom_in else magnitude
	else:
		railward.y = magnitude if zoom_in else -magnitude
	var optical_shift := Vector2.ZERO
	if _ruler_horizontal() and zoom_in and _zoom_horizontal():
		# The full target already ends on ABORT's right keyline. Translate only
		# the painted magnifier until its actual ink ends there too; retaining the
		# original railward Control placement keeps layout/input geometry intact.
		var target := CONTROL_TARGET_MOBILE if Platform.is_mobile() \
			else CONTROL_TARGET
		var optical := _zoom_step_optical_ink_rect(visual_size)
		optical_shift.x = target * 0.5 + visual_size.x * 0.5 \
			- railward.x - optical.end.x
	visual.set_anchors_preset(Control.PRESET_CENTER)
	visual.offset_left = -visual_size.x * 0.5 + railward.x
	visual.offset_top = -visual_size.y * 0.5 + railward.y
	visual.offset_right = visual_size.x * 0.5 + railward.x
	visual.offset_bottom = visual_size.y * 0.5 + railward.y
	visual.set_meta("railward_offset", railward)
	visual.set_meta("optical_edge_shift", optical_shift)
	var optical_rect := _zoom_step_optical_ink_rect(visual_size)
	optical_rect.position += optical_shift
	visual.set_meta("optical_ink_rect", optical_rect)
	visual.queue_redraw()


func _position_zoom_step_visuals() -> void:
	_position_zoom_step_visual(_zoom_out_button)
	_position_zoom_step_visual(_zoom_in_button)
	if is_instance_valid(_zoom_ruler):
		_zoom_ruler.queue_redraw()


func _global_zoom_step_optical_rect(button: Button) -> Rect2:
	if not is_instance_valid(button):
		return Rect2()
	var visual := button.find_child("*Visual", true, false) as Control
	if visual == null or not visual.has_meta("optical_ink_rect"):
		return Rect2()
	var local_variant: Variant = visual.get_meta("optical_ink_rect")
	if not local_variant is Rect2:
		return Rect2()
	var local_rect := local_variant as Rect2
	return Rect2(visual.get_global_rect().position + local_rect.position,
		local_rect.size)


func _horizontal_ruler_trailing_extension() -> float:
	# Only the live fixed-bottom ruler gets this passive connector. Dormant side
	# layouts keep their established vertical/responsive art unchanged.
	if not _zoom_horizontal() or not _ruler_horizontal() \
			or not is_instance_valid(_zoom_ruler):
		return 0.0
	var minus_ink := _global_zoom_step_optical_rect(_zoom_out_button)
	var plus_ink := _global_zoom_step_optical_rect(_zoom_in_button)
	if minus_ink.size == Vector2.ZERO or plus_ink.size == Vector2.ZERO:
		return 0.0
	var bounds := ZoomRulerArt.axis_bounds(_zoom_ruler.size, true)
	var track_x := _zoom_ruler.get_global_rect().position.x
	var left_gap := track_x + bounds.x - minus_ink.end.x
	var right_gap := plus_ink.position.x - (track_x + bounds.y)
	return maxf(0.0, right_gap - left_gap)


func _make_zoom_readout_label() -> Label:
	var mobile := Platform.is_mobile()
	var label := Label.new()
	label.name = "ZoomValue"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",
		Typography.mobile_font(16) if mobile else 12)
	label.add_theme_color_override("font_color", Color("76D6C0"))
	label.add_theme_font_override("font", Typography.MONO_FONT)
	var bubble := StyleBoxFlat.new()
	bubble.bg_color = Color("091A1F", 0.94)
	bubble.border_color = Color(DOCK_TEAL, 0.42)
	bubble.set_border_width_all(2 if mobile else 1)
	bubble.set_corner_radius_all(9 if mobile else 4)
	bubble.content_margin_left = 8.0 if mobile else 4.0
	bubble.content_margin_right = 8.0 if mobile else 4.0
	label.add_theme_stylebox_override("normal", bubble)
	label.custom_minimum_size = ZOOM_READOUT_BUBBLE_SIZE_MOBILE if mobile \
		else ZOOM_READOUT_BUBBLE_SIZE
	label.size = label.custom_minimum_size
	label.z_index = 2
	label.accessibility_name = "ZOOM PERCENTAGE"
	label.set_meta("_typo", true)
	label.set_meta("control_dock_role", "zoom_readout")
	label.set_meta("transient_readout", true)
	label.set_meta("thumb_following", true)
	label.set_meta("idle_hold_seconds", ZOOM_READOUT_HOLD_SECONDS)
	label.set_meta("fade_seconds", ZOOM_READOUT_FADE_SECONDS)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = true
	label.modulate.a = ZOOM_READOUT_IDLE_ALPHA
	return label


func _configure_zoom_ruler_accessibility() -> void:
	if not is_instance_valid(_zoom_ruler):
		return
	# The ruler already has a usable pointer/touch interaction. Describe that real
	# behavior without advertising a keyboard slider interaction it does not own.
	_zoom_ruler.accessibility_name = ZOOM_RULER_ACCESSIBILITY_NAME
	_zoom_ruler.accessibility_description = \
		ZOOM_RULER_ACCESSIBILITY_DESCRIPTION
	_zoom_ruler.tooltip_text = "ADJUST ZOOM"
	_zoom_ruler.focus_mode = Control.FOCUS_ALL
	_zoom_ruler.set_meta("semantic_control", "zoom_level")
	_zoom_ruler.set_meta("keyboard_adjustable", true)
	_zoom_ruler.set_meta("release_cleanup_precedes_block_guard", true)
	_zoom_ruler.focus_entered.connect(func() -> void:
		_zoom_ruler.queue_redraw()
		_set_zoom_hud_bright(true)
		_set_zoom_hud_bright(false))
	_zoom_ruler.focus_exited.connect(func() -> void:
		_zoom_ruler.queue_redraw())


func _draw_zoom_step_visual(visual: Control, button: Button,
		delta: float) -> void:
	var direction := 1 if delta > 0.0 else -1
	var feedback_active := direction == _active_zoom_direction
	var highlighted := button.is_hovered() or button.has_focus() \
		or button.is_pressed()
	var icon_opacity := _active_zoom_icon_alpha if feedback_active \
		else ZOOM_STEP_IDLE_ALPHA
	# A step that reaches an endpoint still gets its requested 100% direction cue;
	# after that cue fades, both glyphs return to the requested 70% idle state.
	if button.disabled and not feedback_active:
		icon_opacity = ZOOM_STEP_DISABLED_ALPHA
	var ink := Color("75DCC2", icon_opacity) if feedback_active or highlighted \
		else Color("B9D0CE", icon_opacity)
	var optical_shift := visual.get_meta(
		"optical_edge_shift", Vector2.ZERO) as Vector2
	visual.draw_set_transform(optical_shift, 0.0, Vector2.ONE)
	# Draw the approved lens-ended icons as vectors so desktop, phone, and the
	# dormant side-layout compatibility path keep the same crisp geometry.
	# There is deliberately no surrounding panel or keyline: the generous Button
	# remains the hit/focus target while the icon floats beside the micro-slider.
	var icon_side := minf(visual.size.x, visual.size.y) * (25.0 / 44.0)
	var icon_origin := (visual.size - Vector2.ONE * icon_side) * 0.5
	var icon_scale := icon_side / 28.0
	var lens_center := icon_origin + Vector2(11.5, 11.5) * icon_scale
	var stroke := maxf(1.5, 2.0 * icon_scale)
	if button.has_focus():
		visual.draw_arc(lens_center, 9.7 * icon_scale, 0.0, TAU, 32,
			Color("75DCC2", 0.48), maxf(1.0, stroke * 0.55), true)
	_draw_magnifier_glyph(visual, icon_origin, icon_scale, stroke * 1.9,
		Color("08171B", 0.72 * icon_opacity), delta > 0.0)
	_draw_magnifier_glyph(visual, icon_origin, icon_scale, stroke, ink,
		delta > 0.0)
	visual.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	visual.set_meta("surface_color", Color(0.0, 0.0, 0.0, 0.0))
	visual.set_meta("icon_color", ink)
	visual.set_meta("icon_opacity", icon_opacity)
	visual.set_meta("direction_feedback_active", feedback_active)
	visual.set_meta("focus_affordance", "lens_halo")
	visual.set_meta("visual_rect", Rect2(visual.global_position, visual.size))
	var optical_rect := _zoom_step_optical_ink_rect(visual.size)
	optical_rect.position += optical_shift
	visual.set_meta("optical_ink_rect", optical_rect)


func _zoom_step_optical_ink_rect(visual_size: Vector2) -> Rect2:
	# Mirror _draw_zoom_step_visual's widest shadow stroke. The handle owns the
	# trailing edge; the lens/focus halo owns the leading/top edge.
	var icon_side := minf(visual_size.x, visual_size.y) * (25.0 / 44.0)
	var icon_origin := (visual_size - Vector2.ONE * icon_side) * 0.5
	var icon_scale := icon_side / 28.0
	var lens_center := icon_origin + Vector2(11.5, 11.5) * icon_scale
	var stroke := maxf(1.5, 2.0 * icon_scale)
	var shadow_stroke := stroke * 1.9
	var lens_radius := maxf(7.25 * icon_scale + shadow_stroke * 0.5,
		9.7 * icon_scale + stroke * 0.55 * 0.5)
	var minimum := lens_center - Vector2.ONE * lens_radius
	var handle_end := icon_origin + Vector2(23.0, 23.0) * icon_scale
	var handle_half_width := shadow_stroke * 1.2 * 0.5
	var maximum := (lens_center + Vector2.ONE * lens_radius).max(
		handle_end + Vector2.ONE * handle_half_width)
	return Rect2(minimum, maximum - minimum)


func _draw_magnifier_glyph(visual: Control, icon_origin: Vector2,
		icon_scale: float, stroke: float, ink: Color, zoom_in: bool) -> void:
	var lens_center := icon_origin + Vector2(11.5, 11.5) * icon_scale
	visual.draw_arc(lens_center, 7.25 * icon_scale, 0.0, TAU, 32, ink,
		stroke, true)
	visual.draw_line(icon_origin + Vector2(16.8, 16.8) * icon_scale,
		icon_origin + Vector2(23.0, 23.0) * icon_scale, ink,
		stroke * 1.2, true)
	visual.draw_line(icon_origin + Vector2(8.0, 11.5) * icon_scale,
		icon_origin + Vector2(15.0, 11.5) * icon_scale, ink, stroke, true)
	if zoom_in:
		visual.draw_line(icon_origin + Vector2(11.5, 8.0) * icon_scale,
			icon_origin + Vector2(11.5, 15.0) * icon_scale, ink, stroke, true)


func _position_zoom_readout() -> void:
	if not is_instance_valid(_zoom_ruler) \
			or not is_instance_valid(_zoom_label) \
			or _zoom_ruler.size.x <= 0.0 or _zoom_ruler.size.y <= 0.0:
		return
	var bubble_size := ZOOM_READOUT_BUBBLE_SIZE_MOBILE \
		if Platform.is_mobile() else ZOOM_READOUT_BUBBLE_SIZE
	_zoom_label.size = bubble_size
	var horizontal := _ruler_horizontal()
	var trailing_extension := _horizontal_ruler_trailing_extension() \
		if horizontal else 0.0
	var thumb_center := ZoomRulerArt.thumb_center(_zoom_ruler.size,
		_board_zoom, ZOOM_MIN, ZOOM_MAX, horizontal, trailing_extension)
	var bubble_position: Vector2
	if horizontal:
		bubble_position.x = clampf(thumb_center.x - bubble_size.x * 0.5,
			0.0, maxf(0.0, _zoom_ruler.size.x - bubble_size.x))
		# Bottom opens upward into play; Top opens downward. A responsive side
		# microbar uses the upper half of its generous hit band.
		bubble_position.y = maxf(0.0, _zoom_ruler.size.y - bubble_size.y) \
			if _zoom_horizontal() and _zoom_pos() \
				== SaveData.ControlDockPosition.TOP else 0.0
	else:
		bubble_position.y = clampf(thumb_center.y - bubble_size.y * 0.5,
			0.0, maxf(0.0, _zoom_ruler.size.y - bubble_size.y))
		var gap := ZOOM_READOUT_SIDE_GAP_MOBILE if Platform.is_mobile() \
			else ZOOM_READOUT_SIDE_GAP
		if _zoom_pos() == SaveData.ControlDockPosition.LEFT:
			bubble_position.x = _zoom_ruler.size.x * 0.5 + gap
		else:
			bubble_position.x = _zoom_ruler.size.x * 0.5 - gap \
				- bubble_size.x
	_zoom_label.position = bubble_position
	_zoom_label.set_meta("thumb_center", thumb_center)
	_zoom_label.set_meta("bubble_rect", Rect2(bubble_position, bubble_size))


func _cancel_zoom_readout_tween() -> void:
	_zoom_readout_generation += 1
	if _zoom_readout_tween != null:
		_zoom_readout_tween.kill()
		_zoom_readout_tween = null


func _hide_zoom_readout_immediate() -> void:
	_cancel_zoom_readout_tween()
	if is_instance_valid(_zoom_label):
		_zoom_label.modulate.a = ZOOM_READOUT_IDLE_ALPHA


func _show_zoom_readout() -> void:
	if not is_instance_valid(_zoom_label) or not _zoom_label.visible:
		return
	_cancel_zoom_readout_tween()
	_zoom_label.modulate.a = 1.0


func _hold_then_fade_zoom_readout() -> void:
	if not is_instance_valid(_zoom_label) or not _zoom_label.visible \
			or _zoom_label.modulate.a <= ZOOM_READOUT_IDLE_ALPHA + 0.001:
		return
	_cancel_zoom_readout_tween()
	_zoom_label.modulate.a = 1.0
	var live_label := _zoom_label
	var generation := _zoom_readout_generation
	_zoom_readout_tween = create_tween()
	_zoom_readout_tween.tween_interval(ZOOM_READOUT_HOLD_SECONDS)
	_zoom_readout_tween.tween_property(live_label, "modulate:a",
		ZOOM_READOUT_IDLE_ALPHA, ZOOM_READOUT_FADE_SECONDS) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_zoom_readout_tween.tween_callback(
		Callable(self, "_finish_zoom_readout_fade").bind(live_label, generation))


func _finish_zoom_readout_fade(live_label: Label, generation: int) -> void:
	if generation != _zoom_readout_generation \
			or not is_instance_valid(live_label) or live_label != _zoom_label:
		return
	live_label.modulate.a = ZOOM_READOUT_IDLE_ALPHA
	_zoom_readout_tween = null


func _queue_zoom_step_visuals() -> void:
	for button in [_zoom_out_button, _zoom_in_button]:
		if not is_instance_valid(button):
			continue
		var visual := button.find_child("*Visual", true, false) as Control
		if visual != null:
			visual.queue_redraw()


func _cancel_zoom_direction_tween() -> void:
	_zoom_direction_generation += 1
	if _zoom_direction_tween != null:
		_zoom_direction_tween.kill()
		_zoom_direction_tween = null


func _publish_zoom_direction_state() -> void:
	var direction_name := "in" if _active_zoom_direction > 0 \
		else ("out" if _active_zoom_direction < 0 else "")
	set_meta("active_zoom_direction", direction_name)
	if is_instance_valid(_zoom_wrap):
		_zoom_wrap.set_meta("active_zoom_direction", direction_name)


func _cancel_zoom_direction_feedback() -> void:
	_cancel_zoom_direction_tween()
	_zoom_direction_feedback_engaged = false
	_zoom_direction_changed_during_engagement = false
	_active_zoom_direction = 0
	_active_zoom_icon_alpha = ZOOM_STEP_IDLE_ALPHA
	_publish_zoom_direction_state()
	_queue_zoom_step_visuals()


func _set_active_zoom_icon_alpha(value: float) -> void:
	_active_zoom_icon_alpha = clampf(value, ZOOM_STEP_IDLE_ALPHA,
		ZOOM_STEP_ACTIVE_ALPHA)
	_queue_zoom_step_visuals()


func _finish_zoom_direction_feedback(generation: int) -> void:
	if generation != _zoom_direction_generation:
		return
	_active_zoom_direction = 0
	_active_zoom_icon_alpha = ZOOM_STEP_IDLE_ALPHA
	_zoom_direction_tween = null
	_publish_zoom_direction_state()
	_queue_zoom_step_visuals()


func _schedule_zoom_direction_feedback_fade() -> void:
	if _active_zoom_direction == 0:
		return
	_cancel_zoom_direction_tween()
	_active_zoom_icon_alpha = ZOOM_STEP_ACTIVE_ALPHA
	var generation := _zoom_direction_generation
	_zoom_direction_tween = create_tween()
	_zoom_direction_tween.tween_interval(ZOOM_STEP_FEEDBACK_HOLD_SECONDS)
	_zoom_direction_tween.tween_method(_set_active_zoom_icon_alpha,
		ZOOM_STEP_ACTIVE_ALPHA, ZOOM_STEP_IDLE_ALPHA,
		ZOOM_STEP_FEEDBACK_FADE_SECONDS).set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	_zoom_direction_tween.tween_callback(
		Callable(self, "_finish_zoom_direction_feedback").bind(generation))


func _show_zoom_direction_feedback(delta: float) -> void:
	if absf(delta) <= 0.0001:
		return
	_cancel_zoom_direction_tween()
	_active_zoom_direction = 1 if delta > 0.0 else -1
	_active_zoom_icon_alpha = ZOOM_STEP_ACTIVE_ALPHA
	_publish_zoom_direction_state()
	_queue_zoom_step_visuals()
	if _zoom_direction_feedback_engaged:
		_zoom_direction_changed_during_engagement = true
	else:
		_schedule_zoom_direction_feedback_fade()


func refresh_badge() -> void:
	# Compatibility hook for hosts that used to refresh the removed echo badge.
	# The real selector owns all live state now.
	if hud != null and hud.has_method("set_tap_mode") and _get_tap_mode.is_valid():
		hud.call("set_tap_mode", int(_get_tap_mode.call()))

func _update_zoom_indicator() -> void:
	zoom_changed.emit(_board_zoom)
	if not _zoom_label:
		return
	_zoom_label.text = "%d%%" % roundi(_board_zoom * 100.0)
	if is_instance_valid(_zoom_ruler):
		_zoom_ruler.accessibility_description = "%s Current zoom %s" % [
			ZOOM_RULER_ACCESSIBILITY_DESCRIPTION, _zoom_label.text]
		_zoom_ruler.queue_redraw()
		_position_zoom_readout.call_deferred()
	if is_instance_valid(_zoom_out_button):
		_zoom_out_button.disabled = _board_zoom <= ZOOM_MIN + 0.001
		var out_visual := _zoom_out_button.get_node_or_null("ZoomOutButtonVisual") \
			as Control
		if out_visual != null:
			out_visual.queue_redraw()
	if is_instance_valid(_zoom_in_button):
		_zoom_in_button.disabled = _board_zoom >= ZOOM_MAX - 0.001
		var in_visual := _zoom_in_button.get_node_or_null("ZoomInButtonVisual") \
			as Control
		if in_visual != null:
			in_visual.queue_redraw()

# ── Fixed BOTTOM placement inside the safe play frame ──
func _placement_frame() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	if _get_play_frame.is_valid():
		var host_frame: Variant = _get_play_frame.call()
		if host_frame is Rect2 and (host_frame as Rect2).size.x > 0.0 \
				and (host_frame as Rect2).size.y > 0.0:
			return host_frame as Rect2
	if hud != null and hud.has_method("play_area_insets"):
		var bands: Vector2 = hud.call("play_area_insets") as Vector2
		return Rect2(Vector2(0.0, bands.x),
			Vector2(viewport_size.x, maxf(1.0,
				viewport_size.y - bands.x - bands.y)))
	return Rect2(Vector2.ZERO, viewport_size)

func position_column() -> void:
	# A resize can queue this after the match has left the scene tree.
	if not is_inside_tree() or not is_instance_valid(_zoom_wrap):
		return
	var frame := _placement_frame()
	if _zoom_horizontal():
		var authored_size := HORIZONTAL_DOCK_SIZE_MOBILE \
			if Platform.is_mobile() else HORIZONTAL_DOCK_SIZE_DESKTOP
		var live_width := maxf(authored_size.x,
			frame.size.x - HORIZONTAL_DOCK_EDGE_INSET * 2.0)
		var live_size := Vector2(live_width, authored_size.y)
		_zoom_wrap.custom_minimum_size = live_size
		_zoom_wrap.size = live_size
		_zoom_wrap.set_meta("horizontal_edge_inset",
			HORIZONTAL_DOCK_EDGE_INSET)
		_zoom_wrap.set_meta("live_horizontal_size", live_size)
	else:
		_apply_side_dock_size(frame)
	var sz := _zoom_wrap.get_combined_minimum_size()
	if _zoom_wrap.size.x > 0.0 and _zoom_wrap.size.y > 0.0:
		sz = _zoom_wrap.size
	var edge := ZOOM_HUD_X if Platform.is_mobile() else 20.0
	var centered_x := frame.position.x + (frame.size.x - sz.x) * 0.5
	var centered_y := frame.position.y + (frame.size.y - sz.y) * 0.5
	var desired := Vector2.ZERO
	match _zoom_pos():
		SaveData.ControlDockPosition.RIGHT:
			desired = Vector2(frame.end.x - sz.x - edge, centered_y)
		SaveData.ControlDockPosition.BOTTOM:
			desired = Vector2(centered_x,
				frame.end.y - sz.y - DOCK_EDGE_GAP)
		SaveData.ControlDockPosition.TOP:
			desired = Vector2(centered_x,
				frame.position.y + DOCK_EDGE_GAP)
		_:
			desired = Vector2(frame.position.x + edge, centered_y)
	# Container metrics can settle a frame after orientation/rebuild. Clamp both
	# axes against the host-provided play band every pass; the dormant side-layout
	# paths share this guard for compatibility.
	var min_pos := frame.position + Vector2.ONE * DOCK_EDGE_GAP
	var max_pos := frame.end - sz - Vector2.ONE * DOCK_EDGE_GAP
	if max_pos.x >= min_pos.x:
		desired.x = clampf(desired.x, min_pos.x, max_pos.x)
	else:
		desired.x = centered_x
	if max_pos.y >= min_pos.y:
		desired.y = clampf(desired.y, min_pos.y, max_pos.y)
	else:
		desired.y = centered_y
	_zoom_wrap.position = desired

func rebuild_if_needed() -> void:
	if _zoom_wrap != null and _zoom_pos() != _zoom_built_pos:
		_hide_zoom_readout_immediate()
		# The selector is owned by HUD and must leave the old dock before its queued
		# deletion or all three action buttons and their signals disappear with it.
		if hud != null and hud.has_method("release_tap_selector_from_dock"):
			hud.call("release_tap_selector_from_dock")
		if hud != null and hud.has_method("release_hint_button_from_dock"):
			hud.call("release_hint_button_from_dock")
		var retired := _zoom_wrap
		if retired.get_parent() != null:
			retired.get_parent().remove_child(retired)
		retired.queue_free()
		_zoom_wrap = null
		_dock_layout = null
		_horizontal_action_plate = null
		_hint_divider = null
		_zoom_section = null
		_zoom_label = null
		_zoom_ruler = null
		_zoom_out_button = null
		_zoom_in_button = null
		_side_action_lane = null
		_side_zoom_lane = null
		_side_hint_cap = null
		build_column()
		position_column.call_deferred()

# ── Resize / rotate: drop any zoom (tied to the old viewport), let the host
# re-lay-out the board band, then recapture the resting anchor. (Solo's logic.) ──
func on_resized() -> void:
	# A resize/rotation is layout work, not player zoom input. Never carry a stale
	# percentage flash or its tween across the rebuilt instrument geometry.
	_hide_zoom_readout_immediate()
	_cancel_zoom_direction_feedback()
	# A rotation changes the live play frame even though the rail stays BOTTOM.
	# Run the compatibility rebuild hook before the board work below, then measure
	# the fixed rail against the newly laid-out band.
	rebuild_if_needed()
	if _board_zoom != 1.0 or board.position != _board_base_pos:
		_board_zoom = 1.0
		board.scale = Vector2.ONE
		# Panning changes both Control axes. Clearing only left/right leaves a
		# vertical 100% pan behind, then the line below captures it as the new rest
		# position. Restore the complete pre-pan anchor before the host recalculates
		# its orientation-specific board band.
		board.position = _board_base_pos
		_update_zoom_indicator()
	if _relayout_board.is_valid():
		_relayout_board.call()
	_board_base_pos = board.position
	position_column.call_deferred()


# End an in-flight pointer gesture without changing the player's settled zoom.
# Used by short-lived full-screen transitions (such as device rotation) that can
# intercept a release after its corresponding press already reached the board.
func cancel_input_gesture() -> void:
	_touches.clear()
	_mouse_pan_armed = false
	_touch_gesture_consumed = true
	_touch_mouse_quiet_until = Time.get_ticks_msec() + TOUCH_MOUSE_QUIET_MSEC
	_pinching = false
	_panning = false
	_pinch_last_dist = 0.0
	_pinch_last_mid = Vector2.ZERO
	_set_zoom_hud_bright(false)
	_cancel_zoom_direction_feedback()


# ── Ruler slider: tap/drag sets the zoom, anchored on screen centre ──
func _on_zoom_ruler_input(event: InputEvent) -> void:
	# A modal can appear between a ruler press and its matching release. Cleanup is
	# gesture ownership, not a new zoom action, so it must run before the host's
	# blocked-input guard or the percentage/track can remain permanently bright.
	var ending_mouse_drag: bool = event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed
	var ending_touch_drag: bool = event is InputEventScreenTouch \
		and (not event.pressed or event.canceled)
	if ending_mouse_drag or ending_touch_drag:
		_set_zoom_hud_bright(false)
		return
	if _blocked():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var keyboard_zoom := _board_zoom
		match event.keycode:
			KEY_LEFT, KEY_DOWN:
				keyboard_zoom -= ZOOM_STEP
			KEY_RIGHT, KEY_UP:
				keyboard_zoom += ZOOM_STEP
			KEY_PAGEUP:
				keyboard_zoom += ZOOM_STEP * 5.0
			KEY_PAGEDOWN:
				keyboard_zoom -= ZOOM_STEP * 5.0
			KEY_HOME:
				keyboard_zoom = ZOOM_MIN
			KEY_END:
				keyboard_zoom = ZOOM_MAX
			_:
				return
		_set_zoom_hud_bright(true)
		_set_zoom_centered(keyboard_zoom)
		_set_zoom_hud_bright(false)
		_zoom_ruler.accept_event()
		return
	var dragging := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		dragging = true
	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
	elif event is InputEventScreenDrag:
		dragging = true
	if not dragging:
		return
	_set_zoom_hud_bright(true)
	var t := ZoomRulerArt.normalized_value_at(_zoom_ruler.size,
		event.position, _ruler_horizontal())
	_set_zoom_centered(ZOOM_MIN + t * (ZOOM_MAX - ZOOM_MIN))
	_zoom_ruler.accept_event()

func _set_zoom_centered(new_zoom: float) -> void:
	zoom_at_point(new_zoom, get_viewport().get_visible_rect().size * 0.5)

func zoom_at_point(new_zoom: float, anchor: Vector2) -> void:
	var previous_zoom := _board_zoom
	new_zoom = clampf(new_zoom, ZOOM_MIN, ZOOM_MAX)
	if _board_zoom <= 1.0 and not _rest_pan_enabled:
		_board_base_pos = board.position
	var ratio := new_zoom / _board_zoom
	board.position = anchor - (anchor - board.position) * ratio
	_board_zoom = new_zoom
	board.scale = Vector2(_board_zoom, _board_zoom)
	_clamp_board_pan()
	_show_zoom_direction_feedback(_board_zoom - previous_zoom)
	_update_zoom_indicator()

func _set_zoom_hud_bright(bright: bool) -> void:
	# Never fade the command dock or the zoom instrument itself. Only the live
	# percentage is transient; the track gets a subtle direct-manipulation response.
	if is_instance_valid(_zoom_ruler):
		_zoom_ruler.modulate.a = 1.0 if bright else 0.94
	if bright:
		if not _zoom_direction_feedback_engaged:
			_zoom_direction_changed_during_engagement = false
		_zoom_direction_feedback_engaged = true
		_show_zoom_readout()
	else:
		var changed_direction := _zoom_direction_changed_during_engagement
		_zoom_direction_feedback_engaged = false
		_zoom_direction_changed_during_engagement = false
		_hold_then_fade_zoom_readout()
		if changed_direction:
			_schedule_zoom_direction_feedback_fade()

# ── Input (host forwards _input here; returns true when consumed) ──
func handle_input(event: InputEvent) -> bool:
	# A Mac preview can intentionally use the mobile layout. The hardware still has
	# a mouse wheel, so handle it before branching into touch/pinch behavior.
	if event is InputEventMouseButton and event.pressed and not _blocked():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom_hud_bright(true)
			zoom_at_point(_board_zoom * 1.1, event.position)
			_set_zoom_hud_bright(false)
			get_viewport().set_input_as_handled()
			return true
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom_hud_bright(true)
			zoom_at_point(_board_zoom / 1.1, event.position)
			_set_zoom_hud_bright(false)
			get_viewport().set_input_as_handled()
			return true
	if Platform.is_mobile():
		return _handle_pinch_input(event)
	return false


# The dock root is intentionally transparent and can span a large part of the
# play field. Only real commands and genuinely painted side plates own a pan start;
# readout seats, detached gaps, side flanks, and other open instrument space stay
# part of the map. `global_point` is in viewport/global Control coordinates.
func dock_owns_pan_start(global_point: Vector2) -> bool:
	if not _dock_visible or not is_instance_valid(_zoom_wrap) \
			or not _zoom_wrap.is_visible_in_tree():
		return false
	var owned_regions: Array[Control] = []
	# Side command surfaces remain painted. The horizontal action host is now
	# invisible and therefore must not reserve its transparent margins or gaps.
	for painted in [_side_action_lane, _side_hint_cap]:
		if is_instance_valid(painted):
			owned_regions.append(painted)
	# Horizontal rows own only the actual action Buttons, not their transparent
	# selector container. Side rows are already covered by their painted cap.
	if _zoom_horizontal() and hud != null and hud.has_method("tap_mode_button"):
		for mode in [0, 1, 2]:
			var action := hud.call("tap_mode_button", mode) as Button
			if is_instance_valid(action):
				owned_regions.append(action)
	if hud != null and hud.has_method("hint_button"):
		var hint := hud.call("hint_button") as Control
		if is_instance_valid(hint):
			owned_regions.append(hint)
	for concrete in [_zoom_out_button, _zoom_ruler, _zoom_in_button]:
		if is_instance_valid(concrete):
			owned_regions.append(concrete)
	for region in owned_regions:
		if region.is_visible_in_tree() \
				and region.get_global_rect().has_point(global_point):
			return true
	return false


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		cancel_input_gesture()


func _handle_pinch_input(event: InputEvent) -> bool:
	var now := Time.get_ticks_msec()
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		# Touch compatibility mouse events can arrive AFTER the last touch-end.
		# Never let that late event recenter a completed pan/pinch or reveal a cell.
		if _touch_gesture_consumed and (not _touches.is_empty() or now < _touch_mouse_quiet_until):
			get_viewport().set_input_as_handled()
			return true
	if event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_pan_armed = event.pressed and _touches.is_empty() \
			and now >= _touch_mouse_quiet_until and not _blocked()
		if _mouse_pan_armed:
			_pan_start = event.position
		elif not event.pressed and _touches.is_empty():
			_panning = false
		return false
	if event is InputEventMouseMotion and event.device != InputEvent.DEVICE_ID_EMULATION \
			and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		if not _mouse_pan_armed or not _touches.is_empty():
			return false
		if can_pan() and not _blocked() and not dock_owns_pan_start(_pan_start):
			if not _panning and event.position.distance_to(_pan_start) > PAN_SLOP:
				_panning = true
				_cancel_holds.call()
			if _panning:
				board.position += event.relative
				_clamp_board_pan()
				return true
		return false
	if event is InputEventScreenTouch:
		_mouse_pan_armed = false
		_touch_mouse_quiet_until = now + TOUCH_MOUSE_QUIET_MSEC
		if event.pressed and not event.canceled:
			# A still finger remains valid until release/cancel, regardless of age.
			if _touches.is_empty():
				_touch_gesture_consumed = false
				_panning = false
				_pan_start = event.position
			_touches[event.index] = event.position
		else:
			if not _touches.has(event.index):
				return false
			_touches.erase(event.index)
			if _touches.size() == 1:
				# Rebase to the surviving finger. Its next motion is measured from
				# its own last position, never from the released finger or midpoint.
				_pan_start = _touches.values()[0]
				_panning = false
			elif _touches.is_empty():
				_panning = false
		_update_pinch_state(true)
		if _pinching:
			_touch_gesture_consumed = true
		if _touch_gesture_consumed:
			get_viewport().set_input_as_handled()
			return true
		return false
	if event is InputEventScreenDrag and _touches.has(event.index):
		var previous_position: Vector2 = _touches[event.index]
		_touches[event.index] = event.position
		_touch_mouse_quiet_until = now + TOUCH_MOUSE_QUIET_MSEC
		if _pinching:
			_apply_pinch()
			get_viewport().set_input_as_handled()
			return true
		if dock_owns_pan_start(_pan_start):
			return false
		if _touches.size() == 1 and can_pan() and not _blocked():
			if not _panning and event.position.distance_to(_pan_start) > PAN_SLOP:
				_panning = true
				_touch_gesture_consumed = true
				_cancel_holds.call()
			if _panning:
				board.position += event.position - previous_position
				_clamp_board_pan()
				get_viewport().set_input_as_handled()
				return true
	return false

func _update_pinch_state(rebase: bool = false) -> void:
	var was := _pinching
	_pinching = _touches.size() >= 2 and not _blocked()
	if _pinching != was:
		_set_zoom_hud_bright(_pinching)
	if _pinching and (not was or rebase):
		_cancel_holds.call()
		if _board_zoom <= 1.0 and not _rest_pan_enabled:
			_board_base_pos = board.position
		var pts := _touch_points()
		_pinch_last_dist = pts[0].distance_to(pts[1])
		_pinch_last_mid = (pts[0] + pts[1]) * 0.5

func _touch_points() -> Array:
	var pts: Array = []
	for k in _touches:
		pts.append(_touches[k])
		if pts.size() == 2:
			break
	return pts

func _apply_pinch() -> void:
	var pts := _touch_points()
	if pts.size() < 2:
		return
	var dist: float = (pts[0] as Vector2).distance_to(pts[1])
	var mid: Vector2 = ((pts[0] as Vector2) + (pts[1] as Vector2)) * 0.5
	var previous_zoom := _board_zoom
	if _pinch_last_dist > 1.0:
		var new_zoom: float = clampf(_board_zoom * dist / _pinch_last_dist, ZOOM_MIN, ZOOM_MAX)
		var ratio: float = new_zoom / _board_zoom
		board.position = mid - (_pinch_last_mid - board.position) * ratio
		_board_zoom = new_zoom
		board.scale = Vector2(_board_zoom, _board_zoom)
	else:
		board.position += mid - _pinch_last_mid
	_pinch_last_dist = dist
	_pinch_last_mid = mid
	_clamp_board_pan()
	_show_zoom_direction_feedback(_board_zoom - previous_zoom)
	_update_zoom_indicator()

func _clamp_board_pan() -> void:
	if _clamp_pan.is_valid():
		board.position = _clamp_pan.call(_board_zoom, board.position) as Vector2
		return
	if _board_zoom <= 1.0:
		board.position = _board_base_pos
		return
	var bs: Vector2 = board.size
	board.position = board.position.clamp(_board_base_pos + bs * (1.0 - _board_zoom), _board_base_pos)
