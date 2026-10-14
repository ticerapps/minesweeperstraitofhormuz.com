extends SceneTree

var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		quit(1)
		assert(condition, message)

func touch(z: Node, id: int, position: Vector2, pressed: bool, canceled: bool = false) -> bool:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	return z._handle_pinch_input(event)

func drag(z: Node, id: int, position: Vector2) -> bool:
	var event := InputEventScreenDrag.new()
	event.index = id
	event.position = position
	# Reproduce a browser delta referenced to the finger that just lifted.
	event.relative = Vector2(999, 999)
	return z._handle_pinch_input(event)

func controller() -> Node:
	var z := load('res://scripts/core/ZoomController.gd').new() as Node
	root.add_child(z)
	var board := Control.new()
	root.add_child(board)
	board.size = Vector2(600, 600)
	z.board = board
	z._cancel_holds = func(): pass
	z._clamp_pan = func(_zoom, position): return position
	return z

func _run() -> void:
	for released in [0, 1]:
		var z := controller()
		check(not touch(z, 0, Vector2(100, 100), true), 'Ordinary tap must reach cells')
		touch(z, 1, Vector2(200, 100), true)
		drag(z, 1, Vector2(250, 100))
		check(is_equal_approx(z._board_zoom, 1.5), 'Pinch scale')
		check(z.board.position.is_equal_approx(Vector2(-50, -50)), 'Previous midpoint anchors pinch')
		var settled: Vector2 = z.board.position
		var survivor: int = 1 - released
		touch(z, released, z._touches[released], false)
		check(z.board.position == settled, 'First release must not move board')
		var remaining: Vector2 = z._touches[survivor]
		drag(z, survivor, remaining + Vector2(20, 0))
		check(z.board.position.is_equal_approx(settled + Vector2(20, 0)), 'Remaining finger pans from its own last position')
		touch(z, survivor, remaining + Vector2(20, 0), false)
		settled = z.board.position
		var mouse := InputEventMouseMotion.new()
		mouse.device = InputEvent.DEVICE_ID_EMULATION
		mouse.button_mask = MOUSE_BUTTON_MASK_LEFT
		mouse.relative = Vector2(700, 700)
		check(z._handle_pinch_input(mouse), 'Post-pinch compatibility mouse motion consumed')
		check(z.board.position == settled, 'Late mouse motion cannot jump board')
		check(not touch(z, 0, Vector2(110, 100), true), 'A fresh tap remains usable immediately')
		check(not touch(z, 0, Vector2(110, 100), false), 'Fresh single release remains usable')
		z.board.free()
		z.free()
	var z := controller()
	touch(z, 0, Vector2(100, 100), true)
	await create_timer(1.35).timeout
	touch(z, 1, Vector2(200, 100), true)
	check(z._touches.size() == 2 and z._pinching, 'A held finger does not expire')
	touch(z, 2, Vector2(300, 100), true)
	touch(z, 0, Vector2(100, 100), false)
	var settled: Vector2 = z.board.position
	drag(z, 1, Vector2(200, 100))
	check(z.board.position == settled, 'Third-finger handoff rebases pinch')
	z._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(z._touches.is_empty() and not z._pinching, 'Focus loss clears touch state')
	touch(z, 0, Vector2(100, 100), true)
	touch(z, 0, Vector2(100, 100), false, true)
	check(z._touches.is_empty(), 'Touch cancel clears finger')
	z.board.free()
	z.free()
	print('PASS: %d touch gesture regression checks' % checks)
	quit(0)
