## Demo script for Buttered Sausage addon.[br]
## Demonstrates SSDMResult integration, message display, and various usage patterns.[br][br]
##
## This script powers the interactive demo scene at:[br]
## res://addons/ButteredSausage/demo/buttered_sausage_demo.tscn
extends Control

@export var main_message: LineEdit
@export var warning_1: LineEdit
@export var warning_2: LineEdit
@export var warning_3: LineEdit
@export var info_1: LineEdit
@export var info_2: LineEdit
@export var max_panels_spinbox: SpinBox
@export var buttered_sausage_display: ButteredSausageDisplay


## Adds warning and info details from the input fields to the result.[br][br]
##
## @param result - The SSDMResult to add details to
func _add_details(result: SSDMResult) -> void:
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
		
		
## Creates and displays a success result with the main message and any details.
func _on_show_success_pressed() -> void:
	var result = SSDMResult.success(main_message.text)
	_add_details(result)
	buttered_sausage_display.populate_from_result(result)


## Creates and displays an error/failure result with the main message and any details.
func _on_show_error_pressed() -> void:
	var result = SSDMResult.failure(main_message.text)
	_add_details(result)
	buttered_sausage_display.populate_from_result(result)


## Creates and displays a warning result with the main message and any details.
func _on_show_warning_pressed() -> void:
	var result = SSDMResult.warning(main_message.text)
	_add_details(result)
	buttered_sausage_display.populate_from_result(result)


## Creates and displays an info result with the main message and any details.
func _on_show_info_pressed() -> void:
	var result = SSDMResult.info(main_message.text)
	_add_details(result)
	buttered_sausage_display.populate_from_result(result)


## Clears all panels from the display.
func _on_clear_display_pressed() -> void:
	buttered_sausage_display.clear_all_panels()


## Updates the max visible panels setting from the spinbox value.
func _on_max_panels_value_changed(value: float) -> void:
	buttered_sausage_display.max_visible_panels = int(value)


## Runs through several demo scenarios showing different SSDMResult patterns.[br]
## Demonstrates: accumulator pattern, state conversion, merge pattern, and validation errors.
func _on_demo_scenarios_pressed() -> void:
	await get_tree().create_timer(0.3).timeout
	var result1 = SSDMResult.success("Deleting user avatar directory...")
	result1.with_warning("Could not delete avatar_old.png (file in use)")
	result1.with_warning("Skipped script file: avatar_controller.gd")
	result1.with_info("Processed 47 files in 2.3 seconds. This could be faster but several optimizations will be required. Please review your code and optimize accordingly.")
	buttered_sausage_display.populate_from_result(result1)
	await get_tree().create_timer(1.5).timeout
	var result2 = SSDMResult.success("Saving resources...")
	result2.with_info("Found 3 duplicate entries. This will not do. Duplicate entries in this application spell disaster. Please remove the duplicate entries before I have a stroke.")
	result2.with_info("Saved enemy.tres. You can view the properties of the class in the inspector by double clicking on enemy.tres in the FileSystem dock in the lower left corner of the editor.")
	result2.with_warning("Could not save config.tres (disk full)")
	result2.to_failure("Save operation failed - disk full")
	buttered_sausage_display.populate_from_result(result2)
	await get_tree().create_timer(1.5).timeout
	var parent_result = SSDMResult.success("Processing batch operation...")
	var child_result1 = SSDMResult.success("Renamed resource_1 to character_1")
	parent_result.merge_from(child_result1)
	var child_result2 = SSDMResult.success("Deleted directory: old_assets/")
	child_result2.with_warning("Skipped 2 locked files")
	parent_result.merge_from(child_result2)
	parent_result.with_info("Batch operation completed successfully. It is a good thing this is done now. I'd hate for this to wait until Monday because the boss can be a real dingus.")
	buttered_sausage_display.populate_from_result(parent_result)
	await get_tree().create_timer(1.5).timeout
	var result3 = SSDMResult.failure("Cannot create resource - validation failed")
	result3.with_detail("Resource name 'invalid*name' contains illegal characters", SSDMSeverity.Level.ERROR)
	result3.with_detail("Resource name already exists in library", SSDMSeverity.Level.ERROR)
	result3.with_info("Suggested name: 'invalid_name_2'. What a terrible suggestion. Why are we even trying to name something invalid_name? That's crazy. How about hickamadoo for a name?")
	buttered_sausage_display.populate_from_result(result3)


## Initializes the demo with default message values.
func _ready() -> void:
	main_message.text = "File processing completed"
	warning_1.text = "Skipped locked file: document.txt"
	warning_2.text = "Failed to delete temporary cache"
	info_1.text = "Processed 47 files in 2.3 seconds. This could be faster but several optimizations will be required. Please review your code and optimize accordingly."
	info_2.text = "Found 3 duplicate entries. This will not do. Duplicate entries in this application spell disaster. Please remove the duplicate entries before I have a stroke."
