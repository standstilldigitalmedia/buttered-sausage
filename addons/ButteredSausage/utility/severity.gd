@tool
## Severity levels for messages and results.[br]
## This enum is standalone with no dependencies and can be used without the display system.[br][br]
##
## Use these levels to categorize operation results and messages by importance.
class_name ButteredSausageSeverity
extends RefCounted

enum Level {
	SUCCESS,  ## Operation completed successfully
	INFO,     ## Informational message
	WARNING,  ## Warning message - operation succeeded with caveats
	ERROR     ## Error message - operation failed
}
