class_name SSDMResult
extends RefCounted


var message: String
var data: Variant
var error: Error
var severity: SSDMSeverity.Level
var details: Array[Dictionary] = []


static func success(msg: String = "", data: Variant = null) -> SSDMResult:
	return SSDMResult.new(msg, data, OK, SSDMSeverity.Level.SUCCESS)
	
	
static func print_success(msg: String = "", data: Variant = null) -> SSDMResult:
	printerr("SSDM Success: " + msg)
	print_stack()
	return SSDMResult.new(msg, data, OK, SSDMSeverity.Level.SUCCESS)


static func failure(msg: String = "", data: Variant = null, p_error: Error = FAILED) -> SSDMResult:
	return SSDMResult.new(msg, data, p_error, SSDMSeverity.Level.ERROR)
	
	
static func print_failure(msg: String = "", data: Variant = null, p_error: Error = FAILED) -> SSDMResult:
	printerr("SSDM Error: " + msg)
	print_stack()
	return SSDMResult.new(msg, data, p_error, SSDMSeverity.Level.ERROR)


static func warning(msg: String = "", data: Variant = null, p_error: Error = OK) -> SSDMResult:
	return SSDMResult.new(msg, data, p_error, SSDMSeverity.Level.WARNING)
	
	
static func print_warning(msg: String = "", data: Variant = null, p_error: Error = OK) -> SSDMResult:
	printerr("SSDM Warning: " + msg)
	print_stack()
	return SSDMResult.new(msg, data, p_error, SSDMSeverity.Level.WARNING)


static func info(msg: String = "", data: Variant = null, p_error: Error = OK) -> SSDMResult:
	return SSDMResult.new(msg, data, p_error, SSDMSeverity.Level.INFO)
	
	
static func print_info(msg: String = "", data: Variant = null, p_error: Error = OK) -> SSDMResult:
	printerr("SSDM Info: " + msg)
	print_stack()
	return SSDMResult.new(msg, data, p_error, SSDMSeverity.Level.INFO)


func with_detail(msg: String, sev: SSDMSeverity.Level) -> SSDMResult:
	details.append({"message": msg, "severity": sev})
	return self

	
func with_warning(msg: String) -> SSDMResult:
	return with_detail(msg, SSDMSeverity.Level.WARNING)


func with_info(msg: String) -> SSDMResult:
	return with_detail(msg, SSDMSeverity.Level.INFO)


func with_error(msg: String, err: Error = FAILED) -> SSDMResult:
	error = err
	return with_detail(msg, SSDMSeverity.Level.ERROR)
	
	
func to_failure(msg: String = "", err: Error = FAILED) -> SSDMResult:
	if !msg.is_empty():
		message = msg
	error = err
	severity = SSDMSeverity.Level.ERROR
	return self


func to_success(msg: String = "") -> SSDMResult:
	if !msg.is_empty():
		message = msg
	error = OK
	severity = SSDMSeverity.Level.SUCCESS
	return self


func to_warning(msg: String = "", err: Error = FAILED) -> SSDMResult:
	if !msg.is_empty():
		message = msg
	error = err
	severity = SSDMSeverity.Level.WARNING
	return self


func to_info(msg: String = "", err: Error = FAILED) -> SSDMResult:
	if !msg.is_empty():
		message = msg
	error = err
	severity = SSDMSeverity.Level.INFO
	return self


func merge_from(other: SSDMResult, takeover_message: bool = true) -> SSDMResult:
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


func has_details() -> bool:
	return details.size() > 0


func is_success() -> bool:
	return error == OK


func _init(p_message: String, p_data: Variant, p_error: Error, p_severity: SSDMSeverity.Level) -> void:
	message = p_message
	data = p_data
	error = p_error
	severity = p_severity
