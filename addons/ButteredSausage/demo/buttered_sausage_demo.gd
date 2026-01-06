extends Control

@onready var main_message: LineEdit = %MainMessage
@onready var warning_1: LineEdit = %Warning1
@onready var warning_2: LineEdit = %Warning2
@onready var warning_3: LineEdit = %Warning3
@onready var info_1: LineEdit = %Info1
@onready var info_2: LineEdit = %Info2
@onready var enable_stacking: CheckBox = %EnableStacking
@onready var error_display: ButteredSausageDisplay = %ErrorDisplay


func _ready() -> void:
	main_message.text = "File processing completed"
	warning_1.text = "Skipped locked file: document.txt"
	warning_2.text = "Failed to delete temporary cache"
	info_1.text = "Processed 47 files in 2.3 seconds"
	info_2.text = "Found 3 duplicate entries"
	enable_stacking.button_pressed = true
	error_display.set_stacking_enabled(true)


func _on_show_success_pressed() -> void:
	var result = ButteredSausage.success(main_message.text)
	_add_details(result)
	error_display.populate_from_result(result)


func _on_show_error_pressed() -> void:
	var result = ButteredSausage.failure(main_message.text)
	_add_details(result)
	error_display.populate_from_result(result)


func _on_show_warning_pressed() -> void:
	var result = ButteredSausage.warning(main_message.text)
	_add_details(result)
	error_display.populate_from_result(result)


func _on_show_info_pressed() -> void:
	var result = ButteredSausage.info(main_message.text)
	_add_details(result)
	error_display.populate_from_result(result)


func _on_clear_display_pressed() -> void:
	error_display.clear_all_panels()


func _on_enable_stacking_toggled(toggled_on: bool) -> void:
	error_display.set_stacking_enabled(toggled_on)


func _on_demo_scenarios_pressed() -> void:
	await get_tree().create_timer(0.3).timeout
	var result1 = ButteredSausage.success("Deleting user avatar directory...")
	result1.with_warning("Could not delete avatar_old.png (file in use)")
	result1.with_warning("Skipped script file: avatar_controller.gd")
	result1.with_info("Successfully deleted 8 of 10 files")
	error_display.populate_from_result(result1)
	await get_tree().create_timer(1.5).timeout
	var result2 = ButteredSausage.success("Saving resources...")
	result2.with_info("Saved player.tres")
	result2.with_info("Saved enemy.tres")
	result2.with_warning("Could not save config.tres (disk full)")
	result2.to_failure("Save operation failed - disk full")
	error_display.populate_from_result(result2)
	await get_tree().create_timer(1.5).timeout
	var parent_result = ButteredSausage.success("Processing batch operation...")
	var child_result1 = ButteredSausage.success("Renamed resource_1 to character_1")
	parent_result.merge_from(child_result1)
	var child_result2 = ButteredSausage.success("Deleted directory: old_assets/")
	child_result2.with_warning("Skipped 2 locked files")
	parent_result.merge_from(child_result2)
	parent_result.with_info("Batch operation completed successfully")
	error_display.populate_from_result(parent_result)
	await get_tree().create_timer(1.5).timeout
	var result3 = ButteredSausage.failure("Cannot create resource - validation failed")
	result3.with_detail("Resource name 'invalid*name' contains illegal characters", ButteredSausageDisplay.Severity.ERROR)
	result3.with_detail("Resource name already exists in library", ButteredSausageDisplay.Severity.ERROR)
	result3.with_info("Suggested name: 'invalid_name_2'")
	error_display.populate_from_result(result3)


func _add_details(result: ButteredSausage) -> void:
	if not warning_1.text.is_empty():
		result.with_warning(warning_1.text)
	if not warning_2.text.is_empty():
		result.with_warning(warning_2.text)
	if not warning_3.text.is_empty():
		result.with_warning(warning_3.text)
	if not info_1.text.is_empty():
		result.with_info(info_1.text)
	if not info_2.text.is_empty():
		result.with_info(info_2.text)
