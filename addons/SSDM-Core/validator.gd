@tool
class_name SSDMValidator
extends RefCounted

const MIN_NAME_LENGTH: int = 3
const MAX_NAME_LENGTH: int = 30
const USE_STRICT_NAMES: bool = false


static func get_base_path(path: String) -> String:
	var extension: String = path.get_extension()
	if extension == "":
		return path
	return path.get_base_dir()
	
	
static func is_valid_node_path(path: String) -> SSDMResult:
	var clean_path: String = path.strip_edges()
	if clean_path.is_empty():
		return SSDMResult.failure("SSDMValidator: Node path can not be empty")
	if (clean_path.begins_with("res://") or clean_path.begins_with("user://") or clean_path.begins_with("uid://")):
		return SSDMResult.failure("SSDMValidator: Node path can not be a file path")
	if ":" in clean_path:
		return SSDMResult.failure("SSDMValidator: Node paths do not contain colons")
	var np = NodePath(clean_path)
	if np.is_empty():
		return SSDMResult.failure("SSDMValidator: Node path string could not be converted to NodePath")
	return SSDMResult.success()


static func is_valid_new_path(path: String) -> SSDMResult:
	var clean_path: String = path.strip_edges()
	if clean_path.is_empty():
		return SSDMResult.failure("SSDMValidator: Cleaned path is empty")
	if !clean_path.is_absolute_path():
		return SSDMResult.failure("SSDMValidator: New path is not an absolute path: " + clean_path)
	var extension: String = clean_path.get_extension()
	var base_dir: String = clean_path
	if !extension.is_empty():
		base_dir = clean_path.get_base_dir()
	var prefix_split := base_dir.split(":")
	var no_prefix: String = ""
	if prefix_split[0] == "res":
		no_prefix = clean_path.trim_prefix("res://")
	elif prefix_split[0] == "user":
		no_prefix = clean_path.trim_prefix("user://")
	else:
		return SSDMResult.failure("SSDMValidator: Invalid path: " + path)
	var base_split := no_prefix.split("/")
	for path_part in base_split:
		var valid_name_result: SSDMResult = is_valid_identifier(path_part)
		if !valid_name_result.is_success():
			return valid_name_result
	return SSDMResult.success()


static func path_exists(path: String) -> SSDMResult:
	if path.is_empty():
		return SSDMResult.failure("SSDMValidator: Path is empty")
	var clean_path: String = path.strip_edges()
	var valid_path_result: SSDMResult = is_valid_new_path(clean_path)
	if valid_path_result.error:
		return valid_path_result
	var base_path: String = get_base_path(clean_path)
	var dir_exists: bool = DirAccess.dir_exists_absolute(base_path)
	if !dir_exists:
		return SSDMResult.failure("SSDMValidator: Path does not exist: " + base_path)
	return SSDMResult.success()
	
	
static func is_valid_identifier(text: String) -> SSDMResult:
	var clean_text: String = text.strip_edges()
	if USE_STRICT_NAMES:
		if !clean_text.is_valid_ascii_identifier():
			return SSDMResult.failure("SSDMValidator: Name must be a valid identifier")
	else:
		if !clean_text.is_valid_filename():
			return SSDMResult.failure("SSDMValidator: Name must be a valid name")
	return SSDMResult.success()


static func is_valid_name(name: String) -> SSDMResult:
	var clean_name: String = name.strip_edges()
	var length = clean_name.length()
	if length < MIN_NAME_LENGTH:
		return SSDMResult.failure("SSDMValidator: Name must be at least " + str(MIN_NAME_LENGTH) + " characters long")
	if length > MAX_NAME_LENGTH:
		return SSDMResult.failure("SSDMValidator: Name must be no more than " + str(MAX_NAME_LENGTH) + " characters long")
	return is_valid_identifier(name)
	
