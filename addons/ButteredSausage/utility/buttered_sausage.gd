## A result object that encapsulates the outcome of an operation with message, data, error code, and severity.[br]
## Supports builder pattern for accumulating warnings and info messages, state conversion between success/failure,[br]
## and merging results from nested operations. Can be displayed using AWOCErrorDisplay.populate_from_result().
class_name ButteredSausage
extends RefCounted


var message: String
var data: Variant
var error: Error
var severity: ButteredSausageSeverity.Level
var details: Array[Dictionary] = []


## Creates a success result with optional message and data.[br][br]
##
## @param msg - The success message to display[br]
## @param data - Optional data payload to include with the result[br]
## @return A new AWOCResult with SUCCESS severity and OK error code[br]
static func success(msg: String = "", data: Variant = null) -> ButteredSausage:
	return ButteredSausage.new(msg, data, OK, ButteredSausageSeverity.Level.SUCCESS)


## Creates a failure result with optional message, data, and error code.[br][br]
##
## @param msg - The error message to display[br]
## @param data - Optional data payload to include with the result[br]
## @param p_error - The error code (defaults to FAILED)[br]
## @return A new AWOCResult with ERROR severity and specified error code
static func failure(msg: String = "", data: Variant = null, p_error: Error = FAILED) -> ButteredSausage:
	return ButteredSausage.new(msg, data, p_error, ButteredSausageSeverity.Level.ERROR)


## Creates a warning result with optional message, data, and error code.[br][br]
##
## @param msg - The warning message to display[br]
## @param data - Optional data payload to include with the result[br]
## @param p_error - The error code (defaults to FAILED)[br]
## @return A new AWOCResult with WARNING severity
static func warning(msg: String = "", data: Variant = null, p_error: Error = FAILED) -> ButteredSausage:
	return ButteredSausage.new(msg, data, p_error, ButteredSausageSeverity.Level.WARNING)


## Creates an info result with optional message, data, and error code.[br][br]
##
## @param msg - The info message to display[br]
## @param data - Optional data payload to include with the result[br]
## @param p_error - The error code (defaults to FAILED)[br]
## @return A new AWOCResult with INFO severity
static func info(msg: String = "", data: Variant = null, p_error: Error = FAILED) -> ButteredSausage:
	return ButteredSausage.new(msg, data, p_error, ButteredSausageSeverity.Level.INFO)
	

## Adds a detail message with specified severity to this result. Supports builder pattern chaining.[br][br]
##
## @param msg - The detail message to add[br]
## @param sev - The severity level of the detail message[br]
## @return This AWOCResult instance for method chaining
func with_detail(msg: String, sev: ButteredSausageSeverity.Level) -> ButteredSausage:
	details.append({"message": msg, "severity": sev})
	return self


## Adds a warning detail message to this result. Supports builder pattern chaining.[br][br]
##
## @param msg - The warning message to add as a detail[br]
## @return This AWOCResult instance for method chaining
func with_warning(msg: String) -> ButteredSausage:
	return with_detail(msg, ButteredSausageSeverity.Level.WARNING)


## Adds an info detail message to this result. Supports builder pattern chaining.[br][br]
##
## @param msg - The info message to add as a detail[br]
## @return This AWOCResult instance for method chaining
func with_info(msg: String) -> ButteredSausage:
	return with_detail(msg, ButteredSausageSeverity.Level.INFO)
	
	
## Adds an error detail message to this result and updates the error code. Supports builder pattern chaining.[br][br]
##
## @param msg - The error message to add as a detail[br]
## @param err - The error code to set (defaults to FAILED)[br]
## @return This AWOCResult instance for method chaining
func with_error(msg: String, err: Error = FAILED) -> ButteredSausage:
	error = err
	return with_detail(msg, ButteredSausageSeverity.Level.ERROR)
	
	

## Converts this result to a failure while preserving accumulated details. Updates message if provided.[br][br]
##
## @param msg - Optional new message (keeps existing if empty)[br]
## @param err - The error code to set (defaults to FAILED)[br]
## @return This AWOCResult instance for method chaining
func to_failure(msg: String = "", err: Error = FAILED) -> ButteredSausage:
	if !msg.is_empty():
		message = msg
	error = err
	severity = ButteredSausageSeverity.Level.ERROR
	return self


## Converts this result to a success while preserving accumulated details. Updates message if provided.[br][br]
##
## @param msg - Optional new message (keeps existing if empty)[br]
## @return This AWOCResult instance for method chaining
func to_success(msg: String = "") -> ButteredSausage:
	if !msg.is_empty():
		message = msg
	error = OK
	severity = ButteredSausageSeverity.Level.SUCCESS
	return self


## Converts this result to a warning while preserving accumulated details. Updates message if provided.[br][br]
##
## @param msg - Optional new message (keeps existing if empty)[br]
## @param err - The error code to set (defaults to FAILED)[br]
## @return This AWOCResult instance for method chaining
func to_warning(msg: String = "", err: Error = FAILED) -> ButteredSausage:
	if !msg.is_empty():
		message = msg
	error = err
	severity = ButteredSausageSeverity.Level.WARNING
	return self


## Converts this result to an info while preserving accumulated details. Updates message if provided.[br][br]
##
## @param msg - Optional new message (keeps existing if empty)[br]
## @param err - The error code to set (defaults to FAILED)[br]
## @return This AWOCResult instance for method chaining
func to_info(msg: String = "", err: Error = FAILED) -> ButteredSausage:
	if !msg.is_empty():
		message = msg
	error = err
	severity = ButteredSausageSeverity.Level.INFO
	return self


## Merges another result's details and optionally its main message/severity into this result.[br]
## If takeover_message is true, replaces this result's main properties with the other result's values.[br]
## If false, adds the other result's message as a detail and merges all details.[br][br]
##
## @param other - The AWOCResult to merge from[br]
## @param takeover_message - If true, replaces main message/severity/error/data with other's values[br]
## @return This AWOCResult instance for method chaining
func merge_from(other: ButteredSausage, takeover_message: bool = true) -> ButteredSausage:
	if takeover_message:
		message = other.message
		severity = other.severity
		error = other.error
		data = other.data
	elif not other.message.is_empty():
		details.append({"message": other.message, "severity": other.severity})
	for detail in other.details:
		details.append(detail)
	return self


## Checks if this result has any detail messages.[br][br]
##
## @return True if details array is not empty
func has_details() -> bool:
	return details.size() > 0


## Checks if this result represents a successful operation.[br][br]
##
## @return True if error code is OK
func is_success() -> bool:
	return error == OK
	
	
func _init(p_message: String, p_data: Variant, p_error: Error, p_severity: ButteredSausageSeverity.Level) -> void:
	message = p_message
	data = p_data
	error = p_error
	severity = p_severity
	
