# Single launcher for the ALU DOOR 70S colour-coded builder.
#   load 'C:/Users/asank/Documents/ALU DOOR/deepseekdoor/door.rb'
#
# Auto-builds a 300 x 300 mm test door and shows the ALU Door 70S toolbar.

load File.expand_path('door_builder.rb', __dir__)

AluDoorPilot::DoorBuilder.build(300.0, 300.0)
