# Loads the ALU Door Pilot builder and builds ONLY the 70 mm outer frame.
#   load 'C:/Users/asank/Documents/ALU DOOR/deepseekdoor/frame_builder.rb'
#
# Uses `load` (not require_relative) so edits to door_builder.rb always reload.

load File.expand_path('door_builder.rb', __dir__) if defined?(File)

AluDoorPilot::DoorBuilder.frame_interactive
