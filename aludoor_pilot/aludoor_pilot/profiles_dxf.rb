# 70S profile cross-sections -> SketchUp, laid out on the floor.
#
# Loading this file (load '.../profiles_dxf.rb') immediately builds all six
# 70S cross-sections from w_clean.dxf, places them on the Z=0 floor plane,
# spaced 1 inch apart, and extrudes each one upward so they stand as tall
# profile bars. No menu required.
#
# Adjust EXTRUDE_HEIGHT_MM to change how tall they stand.

require 'sketchup.rb'

module AluDoorPilot
  module DxfProfiles
    extend self

    DXF_PATH   = 'C:/Users/asank/Documents/ALU DOOR/w_clean.dxf'.freeze
    HEIGHT_MM  = 1000.0     # how tall each profile bar is extruded (mm)

    # --- Minimal DXF (R12) group-code parser --------------------------------
    # Reads POLYLINE / VERTEX / SEQEND and returns [{ :layer, :pts }] where
    # pts is a list of [x, y] in millimetres.
    def parse_polylines(path)
      data = File.read(path)
      data = data.sub("\xEF\xBB\xBF", '').delete("\r")
      lines = data.split("\n")

      polylines = []
      poly = nil
      vertex = nil

      commit_vertex = -> {
        poly[:pts] << [vertex[0], vertex[1]] if poly && vertex && vertex[0] && vertex[1]
        vertex = nil
      }

      i = 0
      while i + 1 < lines.length
        code = lines[i].strip
        val = lines[i + 1]
        i += 2

        case code
        when '0'
          case val.strip
          when 'POLYLINE'
            poly = { layer: nil, pts: [] }
            vertex = nil
          when 'VERTEX'
            commit_vertex.call
            vertex = [nil, nil]
          when 'SEQEND'
            commit_vertex.call
            polylines << poly if poly && !poly[:pts].empty?
            poly = nil
          end
        when '8'   # layer (profile section name)
          poly[:layer] = val.strip if poly && poly[:layer].nil?
        when '10'
          vertex = [nil, nil] if vertex.nil?
          vertex[0] = val.to_f
        when '20'
          vertex[1] = val.to_f if vertex
        end
      end

      polylines
    end

    # Erase any previously generated 70S-* groups so reloading is idempotent.
    def clear_previous(model)
      leftovers = model.entities.grep(Sketchup::Group)
                     .select { |g| g.name =~ /\A70S-/ }
      model.entities.erase_entities(leftovers) unless leftovers.empty?
    end

    # Builds each profile on the floor, extruded vertically to height_mm.
    def build(model, path, height_mm)
      polylines = parse_polylines(path)
      raise "No profile outlines found in #{path}" if polylines.empty?

      model.start_operation('70S profiles on floor', true)
      begin
        clear_previous(model)
        created = 0
        polylines.each do |poly|
          pts = poly[:pts]
          next if pts.size < 3

          name = (poly[:layer].to_s.empty? ? '70S Profile' : poly[:layer].to_s)

          group = model.entities.add_group
          group.name = name
          group.set_attribute('ALU_DOOR', 'profile_code', poly[:layer].to_s)

          # Cross-section sits on the Z=0 floor (XY plane), in millimetres.
          points = pts.map { |x, y| Geom::Point3d.new(x.mm, y.mm, 0.0) }
          begin
            face = group.entities.add_face(points)
          rescue StandardError => e
            UI.messagebox("Could not build #{name}: #{e.message}")
            next
          end
          next unless face && face.valid?

          face.reverse! if face.normal.z < 0
          face.pushpull(height_mm.mm)   # extrude straight up so it stands tall
          face.material = aluminium_material(model)
          created += 1
        end
        model.commit_operation
      rescue StandardError
        model.abort_operation
        raise
      end

      model.active_view.zoom_extents
      model.selection.clear
      model.selection.add(model.entities.grep(Sketchup::Group).select { |g| g.name =~ /\A70S-/ })
      created
    end

    def aluminium_material(model)
      mat = model.materials['ALU 70S Profile'] || model.materials.add('ALU 70S Profile')
      mat.color = Sketchup::Color.new(170, 175, 180)
      mat.alpha = 1.0
      mat
    end
  end
end

# Build immediately when the file is loaded (no menu).
AluDoorPilot::DxfProfiles.build(Sketchup.active_model,
                                AluDoorPilot::DxfProfiles::DXF_PATH,
                                AluDoorPilot::DxfProfiles::HEIGHT_MM)
