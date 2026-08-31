require 'sketchup.rb'
require 'extensions.rb'

module AluDoorPilot
  EXTENSION = SketchupExtension.new('ALU Door Pilot', 'aludoor_pilot/main')
  EXTENSION.description = 'Proof-of-concept generator for a simplified 100 mm aluminium swing door.'
  EXTENSION.version = '0.1.0'
  EXTENSION.creator = 'ALU Door'
  Sketchup.register_extension(EXTENSION, true)
end

