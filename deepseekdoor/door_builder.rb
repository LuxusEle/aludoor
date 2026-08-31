# 70mm Sliding door builder (Alumex 70S profiles).
#
# Reads the real profile outlines from door_profiles.rb and assembles a
# two-panel sliding door using the joinery in the book:
#   Section A-A (vertical):   1001-1 top frame -> 1401 top sash -> glass
#                             -> 1501 bottom sash -> 1101-1 bottom frame
#   Section B-B (horizontal): 1201-1 jamb -> 1701 sash -> 1601 interlock
#                             -> 1701 sash -> 1201-1 jamb
#
# Loading this file builds a door immediately (default 1800 x 2100 mm).
# Axes: X = door width, Y = depth, Z = door height.

require 'sketchup.rb'
require_relative 'door_profiles'

module AluDoorPilot
  module DoorBuilder
    extend self

    PROFILES = AluDoorPilot::DoorProfiles::PROFILES
    VERSION  = '2026-08-30c'   # bump before each change

    # Distinct colour per profile so members are identifiable at a glance.
    COLOURS = {
      '70S-1001-1' => [214,  40,  40],   # head / top frame   - red
      '70S-1101-1' => [ 40, 170,  70],   # sill / bottom frame - green
      '70S-1201-1' => [ 40,  90, 200],   # jamb / side upright - blue
      '70S-1401'   => [235, 140,  20],   # top sash rail      - orange
      '70S-1501'   => [  0, 175, 200],   # bottom sash rail   - cyan
      '70S-1701'   => [180,  60, 200],   # sash stile         - magenta
      '70S-1601'   => [120,  70, 210]    # interlock          - purple
    }.freeze


    # Build one member from a profile outline and place it.
    # axis : :horizontal (runs along X) or :vertical (runs along Z).
    # flip : rotate the cross-section 180 deg about its length axis.
    # origin : [x, y, z] mm placement of the member's 0,0,0.
    # mirror_depth : reflect only the depth (u) direction - swaps the inner /
    #                outer faces without turning the section upside down.
    def member(entities, section, length_mm, name, axis, flip, origin, mirror_depth = false)
      pts = PROFILES[section]
      raise "missing profile #{section}" unless pts
      xs = pts.map { |p| p[0] }; ys = pts.map { |p| p[1] }
      xmax = xs.max; xmin = xs.min; ymax = ys.max; ymin = ys.min
      if flip
        pts = pts.map { |u, v| [xmax - (u - xmin), ymax - (v - ymin)] }
      elsif mirror_depth
        pts = pts.map { |u, v| [xmax - (u - xmin), v] }
      end

      points = pts.map do |u, v|
        if axis == :horizontal
          Geom::Point3d.new(0.0, u.mm, v.mm)   # u -> depth (Y), v -> height (Z)
        else
          Geom::Point3d.new(v.mm, u.mm, 0.0)   # u -> depth (Y), v -> width (X)
        end
      end

      group = entities.add_group
      group.name = name
      group.set_attribute('ALU_DOOR', 'profile_code', section)
      group.set_attribute('ALU_DOOR', 'cut_length_mm', length_mm)

      face = group.entities.add_face(points)
      if face && face.valid?
        if axis == :horizontal
          face.reverse! if face.normal.x < 0
        else
          face.reverse! if face.normal.z < 0
        end
        face.pushpull(length_mm.mm)
        face.material = profile_material(section)
      end
      group.transform!(Geom::Transformation.translation([origin[0].mm, origin[1].mm, origin[2].mm]))
      group
    end

    def aluminium_material
      model = Sketchup.active_model
      m = model.materials['ALU 70S Profile'] || model.materials.add('ALU 70S Profile')
      m.color = Sketchup::Color.new(175, 178, 182)
      m.alpha = 1.0
      m
    end

    def profile_material(section)
      model = Sketchup.active_model
      rgb = COLOURS[section] || [175, 178, 182]
      key = "ALU #{section}"
      m = model.materials[key] || model.materials.add(key)
      m.color = Sketchup::Color.new(rgb[0], rgb[1], rgb[2])
      m.alpha = 1.0
      m
    end

    def glass_material
      model = Sketchup.active_model
      m = model.materials['ALU 70S Glass'] || model.materials.add('ALU 70S Glass')
      m.color = Sketchup::Color.new(120, 190, 220)
      m.alpha = 0.45
      m
    end

    def add_glass(entities, x0, y0, z0, x1, y1, z1)
      g = entities.add_group
      g.name = 'Glass'
      pts = [
        Geom::Point3d.new(x0.mm, y0.mm, z0.mm),
        Geom::Point3d.new(x1.mm, y0.mm, z0.mm),
        Geom::Point3d.new(x1.mm, y0.mm, z1.mm),
        Geom::Point3d.new(x0.mm, y0.mm, z1.mm)
      ]
      f = g.entities.add_face(pts)
      f.material = glass_material
      f.back_material = glass_material
      f.pushpull((y1 - y0).mm)
      g
    end

    def clear_previous(model)
      leftovers = model.entities.grep(Sketchup::Group)
                     .select { |g| g.name =~ /\A70S Sliding Door/ }
      model.entities.erase_entities(leftovers) unless leftovers.empty?
    end

    def build(width_mm, height_mm)
      model = Sketchup.active_model
      model.start_operation('70S Sliding Door', true)
      begin
        clear_previous(model)
        root = model.entities.add_group
        root.name = "70S Sliding Door #{width_mm.round(0)} x #{height_mm.round(0)}"
        root.set_attribute('ALU_DOOR', 'system', '70 mm sliding door')

        jamb_w = 25.0      # 70S-1201-1 width along X
        top_h  = 32.0      # 70S-1001-1 height
        bot_h  = 30.0      # 70S-1101-1 height

        # --- Frame -----------------------------------------------------
        member(root.entities, '70S-1001-1', width_mm, '70S-1001-1 Top Frame', :horizontal, false, [0, 0, height_mm - top_h])
        member(root.entities, '70S-1101-1', width_mm, '70S-1101-1 Bottom Frame', :horizontal, false, [0, 0, 0], true)
        member(root.entities, '70S-1201-1', height_mm, '70S-1201-1 Left Jamb', :vertical, true, [0, 0, 0])
        member(root.entities, '70S-1201-1', height_mm, '70S-1201-1 Right Jamb', :vertical, false, [width_mm - jamb_w, 0, 0])

        # --- Panels ----------------------------------------------------
        open_w   = width_mm - 2.0 * jamb_w
        overlap = 30.0
        panel_w = (open_w + overlap) / 2.0
        panel_bot = 10.0
        panel_top = height_mm - 10.0
        panel_h   = panel_top - panel_bot
        dy_left   = 30.0
        dy_right  = 60.0
        # split the opening between the two panels with a 1601 interlock at the meeting line
        left_x  = jamb_w
        right_x = width_mm - jamb_w - panel_w
        meet_x  = (left_x + panel_w + right_x) / 2.0

        build_panel(root.entities, 'Left Sliding Panel', left_x, dy_left, panel_w, panel_bot, panel_top)
        build_panel(root.entities, 'Right Sliding Panel', right_x, dy_right, panel_w, panel_bot, panel_top)
        member(root.entities, '70S-1601', panel_h, '70S-1601 Interlock', :vertical, false, [meet_x, (dy_left + dy_right) / 2.0, panel_bot])

        cutlist = [
          'Profile,Description,Qty,Cut length mm',
          "70S-1001-1,Top Frame,1,#{width_mm.round(1)}",
          "70S-1101-1,Bottom Frame,1,#{width_mm.round(1)}",
          "70S-1201-1,Left Jamb,1,#{height_mm.round(1)}",
          "70S-1201-1,Right Jamb,1,#{height_mm.round(1)}",
          "70S-1401,Sash Top,2,#{panel_w.round(1)}",
          "70S-1501,Sash Bottom,2,#{panel_w.round(1)}",
          "70S-1701,Sash Side,4,#{panel_h.round(1)}",
          "70S-1601,Interlock,1,#{panel_h.round(1)}"
        ].join("\n")
        root.set_attribute('ALU_DOOR', 'cutlist_csv', cutlist)

        model.commit_operation
        model.selection.clear
        model.active_view.zoom_extents
        UI.messagebox("70 mm sliding door built.\n\nVERSION #{VERSION}\n\n#{cutlist.gsub(',', '  |  ')}")
      rescue StandardError
        model.abort_operation
        raise
      end
    end

    def build_panel(entities, name, x, y, panel_w, panel_bot, panel_top)
      panel = entities.add_group
      panel.name = name
      top_rail_h = 32.0
      bot_rail_h = 56.2
      clear = 2.0            # slide-in fit: rail ends inset from the stiles

      rail_w = panel_w - 2.0 * clear
      member(panel.entities, '70S-1401', rail_w, '70S-1401 Sash Top', :horizontal, false, [x + clear, y, panel_top - top_rail_h])
      member(panel.entities, '70S-1501', rail_w, '70S-1501 Sash Bottom', :horizontal, false, [x + clear, y, panel_bot], true)
      member(panel.entities, '70S-1701', panel_top - panel_bot, '70S-1701 Sash Left', :vertical, false, [x, y, panel_bot])
      member(panel.entities, '70S-1701', panel_top - panel_bot, '70S-1701 Sash Right', :vertical, true, [x + panel_w, y, panel_bot])

      gz0 = panel_bot + bot_rail_h
      gz1 = panel_top - top_rail_h
      gy  = y + 15.0
      add_glass(panel.entities, x + 3.0, gy, gz0 + 3.0, x + panel_w - 3.0, gy + 6.0, gz1 - 3.0)

      # Drill / screw points at the rail<->stile joints (through the stile, in X)
      # + fit adjustments: 2 screws per corner joint.
      [panel_bot + 25.0, panel_top - 25.0].each do |z|
        add_drill(panel.entities, [x, y, z], [1, 0, 0])
        add_drill(panel.entities, [x + panel_w, y, z], [1, 0, 0])
      end
      panel
    end

    # A screw hole marker: a short cylinder along `normal` (mm units).
    def add_drill(entities, centre, normal, dia_mm = 4.0, depth_mm = 12.0)
      n = Geom::Vector3d.new(normal[0].to_f, normal[1].to_f, normal[2].to_f)
      r = (dia_mm / 2.0).mm
      c = Geom::Point3d.new(centre[0].mm, centre[1].mm, centre[2].mm)
      edges = entities.add_circle(c, n, r)
      face = entities.add_face(edges)
      return unless face && face.valid?
      face.reverse! if face.normal.dot(n) < 0
      face.pushpull(depth_mm.mm)
      face.material = drill_material
      face
    end

    def drill_material
      model = Sketchup.active_model
      m = model.materials['Screw hole'] || model.materials.add('Screw hole')
      m.color = Sketchup::Color.new(40, 40, 40)
      m
    end

    # Flip selected member(s) 180 deg about their own centre axis.
    # axis : :y = in/out swap (front/back), :z = turn up/down, :x = left/right.
    def flip_selected(axis = :y)
      model = Sketchup.active_model
      vec = case axis
            when :z then Z_AXIS
            when :x then X_AXIS
            else Y_AXIS
            end
      model.start_operation('Flip selected member', true)
      flipped = 0
      model.selection.grep(Sketchup::Group).each do |g|
        if g.respond_to?(:bounds) && g.bounds
          c = g.bounds.center
          g.transform!(Geom::Transformation.rotation(c, vec, 180.degrees))
          flipped += 1
        end
      end
      model.commit_operation
      UI.messagebox("Flipped #{flipped} member(s) about #{axis == :z ? 'Z (up/down)' : axis == :x ? 'X (left/right)' : 'Y (in/out)'}.")
    rescue StandardError => e
      model.abort_operation if model
      UI.messagebox("Flip failed: #{e.message}")
    end

    def interactive
      prompts = ['Overall width (mm)', 'Overall height (mm)']
      defaults = [300.0, 300.0]
      values = UI.inputbox(prompts, defaults, '70 mm Sliding Door')
      return unless values
      w, h = values.map(&:to_f)
      build(w, h)
    rescue StandardError => e
      UI.messagebox("Build failed: #{e.message}")
    end

    # --- Outer frame only ---------------------------------------------
    # Members: 1001-1 head (top), 1101-1 sill (bottom), 1201-1 x2 jambs.
    # butt  : head & sill run full width; jambs cut between them (fixed frame).
    # miter : same members but each end bevel-cut at 45 deg so corners read as
    #         picture-frame mitres.
    def build_frame(width_mm, height_mm, joint = :butt, cut = true)
      model = Sketchup.active_model
      model.start_operation('70S Frame', true)
      begin
        clear_previous_frame(model)
        root = model.entities.add_group
        root.name = "70S Outer Frame #{width_mm.round(0)} x #{height_mm.round(0)} (#{joint})"
        root.set_attribute('ALU_DOOR', 'system', '70 mm outer frame')

        top_h = 32.0      # 1001-1 height
        bot_h = 30.0      # 1101-1 height
        jamb_w = 25.0     # 1201-1 width along X
        notch = 12.0      # H-cut depth (how far head/sill tuck into the jamb)

        # Fixed frame: jambs run full height; head & sill run between them and
        # sit into a notch (rabbet) cut into the jamb's inner face.
        head_len = width_mm - 2.0 * jamb_w + 2.0 * notch
        head_g = member(root.entities, '70S-1001-1', head_len, '70S-1001-1 Head',
                        :horizontal, false, [jamb_w - notch, 0, height_mm - top_h])
        sill_g = member(root.entities, '70S-1101-1', head_len, '70S-1101-1 Sill',
                        :horizontal, false, [jamb_w - notch, 0, 0], true)
        jamb_l = member(root.entities, '70S-1201-1', height_mm, '70S-1201-1 Left Jamb',
                        :vertical, true, [0, 0, 0])
        jamb_r = member(root.entities, '70S-1201-1', height_mm, '70S-1201-1 Right Jamb',
                        :vertical, false, [width_mm - jamb_w, 0, 0])

        if cut
          begin
            if joint == :miter
              miter_frame(model, top_h, bot_h, jamb_w, width_mm, height_mm,
                          head_g, sill_g, jamb_l, jamb_r)
            else
              cut_box(jamb_l, jamb_w, -1, notch, top_h, bot_h, height_mm)
              cut_box(jamb_r, width_mm - jamb_w, +1, notch, top_h, bot_h, height_mm)
            end
          rescue StandardError => e
            puts "CUT failed (#{e.message}) - rebuilding plain frame"
            model.abort_operation
            return build_frame(width_mm, height_mm, joint, false)
          end
        end

        model.commit_operation
        model.selection.clear
        model.active_view.zoom_extents
        UI.messagebox(frame_cutlist(width_mm, height_mm, joint))
      rescue StandardError
        model.abort_operation
        raise
      end
    end

    # Cut an H-notch (rabbet) into a jamb's inner face so the head/sill recess in.
    # face_x : world X of the jamb inner face.
    # dir    : +1 notch extends in +X (right jamb), -1 extends in -X (left jamb).
    def cut_box(group, face_x, dir, notch, top_h, bot_h, height_mm)
      model = Sketchup.active_model
      depth = 400.0
      bands = [[height_mm - top_h, height_mm], [0, bot_h]]
      bands.each do |z0, z1|
        x0 = dir > 0 ? face_x : face_x - notch
        x1 = dir > 0 ? face_x + notch : face_x
        b = model.entities.add_group
        f = b.entities.add_face([[x0.mm, -200.0.mm, z0.mm], [x1.mm, -200.0.mm, z0.mm],
                                 [x1.mm, -200.0.mm, z1.mm], [x0.mm, -200.0.mm, z1.mm]])
        f.reverse! if f.normal.y < 0
        f.pushpull(depth.mm)
        f.material = nil
        res = group.subtract(b)
        b.erase! if b.valid?
        group = res if res
      end
      group
    end

    # Cut a 45 deg bevel off one end of a member using a boolean subtract.
    def bevel_cut(group, point, normal2d)
      model = Sketchup.active_model
      size = 1200.0
      half = size / 2.0
      nx, nz = normal2d[0], normal2d[1]
      theta = Math.atan2(-nz, nx)
      cutter = model.entities.add_group
      f = cutter.entities.add_face([[-half, -half, -half], [half, -half, -half],
                                    [half, half, -half], [-half, half, -half]])
      f.pushpull(size)
      f.reverse! if f.normal.z < 0
      cutter.transform!(Geom::Transformation.translation([point[0] + half * nx, point[1], point[2] + half * nz]) *
                        Geom::Transformation.rotation(ORIGIN, Y_AXIS, theta))
      res = group.subtract(cutter)
      cutter.erase! if cutter.valid?
      res || group
    end

    def miter_frame(model, top_h, bot_h, jamb_w, width_mm, height_mm,
                    head, sill, jamb_l, jamb_r)
      head = bevel_cut(head, [width_mm, 0, height_mm - top_h], [1.0, 1.0])
      head = bevel_cut(head, [0, 0, height_mm], [-1.0, 1.0])
      sill = bevel_cut(sill, [width_mm, 0, 0], [1.0, -1.0])
      sill = bevel_cut(sill, [0, 0, bot_h], [-1.0, -1.0])
      jamb_l = bevel_cut(jamb_l, [0, 0, height_mm - top_h], [-1.0, 1.0])
      jamb_l = bevel_cut(jamb_l, [jamb_w, 0, bot_h], [-1.0, -1.0])
      jamb_r = bevel_cut(jamb_r, [width_mm, 0, height_mm - top_h], [1.0, 1.0])
      jamb_r = bevel_cut(jamb_r, [width_mm - jamb_w, 0, bot_h], [1.0, -1.0])
    end

    def clear_previous_frame(model)
      leftovers = model.entities.grep(Sketchup::Group)
                     .select { |g| g.name =~ /\A70S Outer Frame/ }
      model.entities.erase_entities(leftovers) unless leftovers.empty?
    end

    def frame_cutlist(width_mm, height_mm, joint)
      top_h = 32.0; bot_h = 30.0; jamb_w = 25.0; notch = 12.0
      horiz = width_mm - 2.0 * jamb_w + 2.0 * notch
      if joint == :miter
        ['Profile,Piece,50 deg miter length mm',
         "70S-1001-1,Head,1,#{(width_mm - 2.0).round(1)}",
         "70S-1101-1,Sill,1,#{(width_mm - 2.0).round(1)}",
         "70S-1201-1,Jamb,2,#{(height_mm - 2.0).round(1)}"].join("\n")
      else
        ['Profile,Piece,Cut length mm  (H-notch at ends)',
         "70S-1001-1,Head,1,#{horiz.round(1)}",
         "70S-1101-1,Sill,1,#{horiz.round(1)}",
         "70S-1201-1,Jamb,2,#{height_mm.round(1)}"].join("\n")
      end
    end

    def frame_interactive
      prompts = ['Overall width (mm)', 'Overall height (mm)', 'Joint: 1 = H-notch butt, 2 = 45 mitre']
      defaults = [1000.0, 2100.0, 1]
      values = UI.inputbox(prompts, defaults, '70 mm Outer Frame')
      return unless values
      w, h = values.map(&:to_f)
      joint = values[2].to_i == 2 ? :miter : :butt
      build_frame(w, h, joint)
    rescue StandardError => e
      puts "FRAME ERROR:\n#{e.full_message}"   # also prints to Ruby console
      UI.messagebox("Frame build failed: #{e.message}")
    end
  end
end

# --- Toolbar (so no Ruby typing is needed) ------------------------------
if defined?(UI) && UI.respond_to?(:Toolbar)
  unless file_loaded?(__FILE__)
    tb = UI::Toolbar.new('ALU Door 70S')
    add_item = lambda do |title, &blk|
      cmd = UI::Command.new(title) { blk.call }
      cmd.tooltip = title
      cmd.status_bar_text = title
      tb = tb.add_item(cmd)
    end

    add_item.call('70S Door (prompt)') { AluDoorPilot::DoorBuilder.interactive }
    add_item.call('70S Door 300x300')  { AluDoorPilot::DoorBuilder.build(300.0, 300.0) }
    add_item.call('70S Frame')         { AluDoorPilot::DoorBuilder.frame_interactive }
    add_item.call('Flip In/Out')       { AluDoorPilot::DoorBuilder.flip_selected(:y) }
    add_item.call('Flip Up/Down')      { AluDoorPilot::DoorBuilder.flip_selected(:z) }
    add_item.call('Flip Left/Right')   { AluDoorPilot::DoorBuilder.flip_selected(:x) }
    tb.show
    file_loaded(__FILE__)
  end
end
