extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.stop_timer()
	
	text = "[pulse]Completed In: %ds[/pulse]" % GlobalVariables.get_time()
