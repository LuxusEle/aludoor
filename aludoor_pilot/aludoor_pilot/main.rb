require 'sketchup.rb'
load File.join(__dir__, 'profiles_70s_clean_dxf.rb')
load File.join(__dir__, 'hardware_70s.rb')
load File.join(__dir__, 'system_70s_app.rb')
load File.join(__dir__, 'supabase_auth.rb')
load File.join(__dir__, 'alu_nesting_engine.rb')
load File.join(__dir__, 'alu_report_dialog.rb')

module AluDoorPilot
  module Generator
    extend self

    PLUGIN_NAME = 'ALU Door Pilot'.freeze
    MM = 1.0.mm

    def generate
      prompts = ['Overall width (mm)', 'Overall height (mm)', 'Frame clearance (mm)', 'Glass thickness (mm)']
      defaults = [1000.0, 2100.0, 55.0, 6.0]
      values = UI.inputbox(prompts, defaults, PLUGIN_NAME)
      return unless values

      width, height, inset, glass_thickness = values.map(&:to_f)
      unless width.between?(600, 2400) && height.between?(1000, 3200)
        UI.messagebox('Use a width from 600-2400 mm and a height from 1000-3200 mm.')
        return
      end

      model = Sketchup.active_model
      model.start_operation('Generate ALU door pilot', true)
      remove_previous(model)

      root = model.entities.add_group
      root.name = format('ALU Door Pilot %.0f x %.0f', width, height)
      root.set_attribute('ALU_DOOR', 'system', '100 mm swing door - pilot')
      root.set_attribute('ALU_DOOR', 'overall_width_mm', width)
      root.set_attribute('ALU_DOOR', 'overall_height_mm', height)

      frame_width = 100.0
      frame_depth = 45.0
      sash_width = 66.0
      sash_depth = 45.0

      add_member(root.entities, '100D-3105 Frame Head', width, frame_width, frame_depth,
                 Geom::Transformation.translation([0, 0, height.mm]))
      add_member(root.entities, '100D-3105 Frame Threshold', width, frame_width, frame_depth,
                 Geom::Transformation.translation([0, 0, 0]))
      vertical_rotation = Geom::Transformation.rotation(ORIGIN, Y_AXIS, -90.degrees)
      add_member(root.entities, '100D-3105 Frame Left', height, frame_width, frame_depth,
                 Geom::Transformation.translation([0, 0, 0]) * vertical_rotation)
      add_member(root.entities, '100D-3105 Frame Right', height, frame_width, frame_depth,
                 Geom::Transformation.translation([width.mm, 0, 0]) * vertical_rotation)

      sash_x = inset
      sash_z = inset
      sash_w = width - (2.0 * inset)
      sash_h = height - (2.0 * inset)
      add_member(root.entities, '100D-101 Sash Top', sash_w, sash_width, sash_depth,
                 Geom::Transformation.translation([sash_x.mm, -15.mm, (sash_z + sash_h).mm]))
      add_member(root.entities, '100D-101 Sash Bottom', sash_w, sash_width, sash_depth,
                 Geom::Transformation.translation([sash_x.mm, -15.mm, sash_z.mm]))
      add_member(root.entities, '100D-101 Sash Left', sash_h, sash_width, sash_depth,
                 Geom::Transformation.translation([sash_x.mm, -15.mm, sash_z.mm]) * vertical_rotation)
      add_member(root.entities, '100D-101 Sash Right', sash_h, sash_width, sash_depth,
                 Geom::Transformation.translation([(sash_x + sash_w).mm, -15.mm, sash_z.mm]) * vertical_rotation)

      glass_gap = 62.0
      add_glass(root.entities, sash_x + glass_gap, sash_z + glass_gap,
                sash_w - (2.0 * glass_gap), sash_h - (2.0 * glass_gap), glass_thickness)

      cutlist = build_cutlist(width, height, sash_w, sash_h)
      root.set_attribute('ALU_DOOR', 'cutlist_csv', cutlist)
      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      UI.messagebox("Pilot door generated.\n\n#{cutlist.gsub(',', '  |  ')}")
    rescue StandardError => error
      model.abort_operation if model
      UI.messagebox("Generation failed: #{error.message}")
      raise error
    end

    def generate_sliding74
      prompts = ['Overall width (mm)', 'Overall height (mm)', 'Panel overlap (mm)', 'Glass thickness (mm)']
      defaults = [1800.0, 2100.0, 50.0, 6.0]
      values = UI.inputbox(prompts, defaults, '74 mm C-Groove Sliding Pilot')
      return unless values

      width, height, overlap, glass_thickness = values.map(&:to_f)
      unless width.between?(1000, 4200) && height.between?(1000, 3000)
        UI.messagebox('Use a width from 1000-4200 mm and a height from 1000-3000 mm.')
        return
      end

      model = Sketchup.active_model
      model.start_operation('Generate 74 mm sliding pilot', true)
      remove_previous(model)
      root = model.entities.add_group
      root.name = format('74 mm C-Groove Sliding %.0f x %.0f', width, height)
      root.set_attribute('ALU_DOOR', 'system', '74 mm C-Groove sliding - pilot')
      root.set_attribute('ALU_DOOR', 'overall_width_mm', width)
      root.set_attribute('ALU_DOOR', 'overall_height_mm', height)

      frame_width = 74.0
      frame_depth = 46.2
      vertical_rotation = Geom::Transformation.rotation(ORIGIN, Y_AXIS, -90.degrees)
      add_member(root.entities, 'ESD-1001 Frame Head', width, frame_width, frame_depth,
                 Geom::Transformation.translation([0, 0, height.mm]))
      add_member(root.entities, 'ESD-1001 Frame Sill', width, frame_width, frame_depth,
                 Geom::Transformation.translation([0, 0, 0]))
      add_member(root.entities, 'ESD-1001 Jamb Left', height, frame_width, frame_depth,
                 Geom::Transformation.translation([0, 0, 0]) * vertical_rotation)
      add_member(root.entities, 'ESD-1001 Jamb Right', height, frame_width, frame_depth,
                 Geom::Transformation.translation([width.mm, 0, 0]) * vertical_rotation)

      frame_clearance = 62.0
      sash_height = height - (2.0 * frame_clearance)
      clear_width = width - (2.0 * frame_clearance)
      sash_width = (clear_width + overlap) / 2.0
      add_sliding_panel(root.entities, 'Left Sliding Panel', frame_clearance, -21.0,
                        frame_clearance, sash_width, sash_height, glass_thickness, false)
      add_sliding_panel(root.entities, 'Right Sliding Panel', width - frame_clearance - sash_width, 21.0,
                        frame_clearance, sash_width, sash_height, glass_thickness, true)

      cutlist = build_sliding_cutlist(width, height, sash_width, sash_height)
      root.set_attribute('ALU_DOOR', 'cutlist_csv', cutlist)
      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      UI.messagebox("74 mm sliding pilot generated.\n\n#{cutlist.gsub(',', '  |  ')}")
    rescue StandardError => error
      model.abort_operation if model
      UI.messagebox("Generation failed: #{error.message}")
      raise error
    end

    # 100% Solid Tool Subtraction for top track head (70S-1001-1)
    def notch_top_track_solid_tool(track_group, length_mm, notch_len_mm = 25.0)
      parent = track_group.parent.entities

      # 1. Left Cutter Box (Cuts X = 30mm..75mm at Z = -5mm..25mm)
      cutter1 = parent.add_group
      p1 = [
        [30.0.mm, -5.0.mm, -5.0.mm],
        [75.0.mm, -5.0.mm, -5.0.mm],
        [75.0.mm, 35.0.mm, -5.0.mm],
        [30.0.mm, 35.0.mm, -5.0.mm]
      ]
      f1 = cutter1.entities.add_face(p1)
      f1.pushpull((notch_len_mm + 5.0).mm) if f1

      if cutter1.respond_to?(:subtract) && cutter1.manifold? && track_group.manifold?
        res = cutter1.subtract(track_group)
        track_group = res if res&.valid?
      else
        track_group.entities.intersect_with(true, IDENTITY, track_group.entities, IDENTITY, false, cutter1.entities.to_a)
        cutter1.erase!
      end

      # 2. Right Cutter Box (Cuts X = -5mm..40mm at Z = (length_mm - 25mm)..length_mm + 5mm)
      cutter2 = parent.add_group
      p2 = [
        [-5.0.mm, -5.0.mm, (length_mm - notch_len_mm).mm],
        [40.0.mm, -5.0.mm, (length_mm - notch_len_mm).mm],
        [40.0.mm, 35.0.mm, (length_mm - notch_len_mm).mm],
        [-5.0.mm, 35.0.mm, (length_mm - notch_len_mm).mm]
      ]
      f2 = cutter2.entities.add_face(p2)
      f2.pushpull((notch_len_mm + 5.0).mm) if f2

      if cutter2.respond_to?(:subtract) && cutter2.manifold? && track_group.manifold?
        res2 = cutter2.subtract(track_group)
        track_group = res2 if res2&.valid?
      else
        track_group.entities.intersect_with(true, IDENTITY, track_group.entities, IDENTITY, false, cutter2.entities.to_a)
        cutter2.erase!
      end

      track_group
    end

    def generate_sliding70
      prompts = ['Overall width (mm)', 'Overall height (mm)', 'Glass thickness (mm)']
      defaults = [1800.0, 2100.0, 6.0]
      values = UI.inputbox(prompts, defaults, '70 mm Sliding Door App (Alumex Pages 13-16)')
      return unless values

      width, height, glass_thickness = values.map(&:to_f)
      
      model = Sketchup.active_model
      model.start_operation('Generate 70 mm sliding door app', true)
      remove_previous(model)
      root = model.entities.add_group
      root.name = format('70 mm Sliding Door %.0f x %.0f', width, height)
      root.set_attribute('ALU_DOOR', 'system', '70 mm sliding')
      root.set_attribute('ALU_DOOR', 'overall_width_mm', width)
      root.set_attribute('ALU_DOOR', 'overall_height_mm', height)

      # Matrix mapping: 2D profile width (X_2d) -> Door Y (Depth), 2D height (Y_2d) -> Door Z (Height), 3D Length (Z_3d) -> Door X (Width)
      def horiz_transform(tx, ty, tz, flip_z = false)
        z_factor = flip_z ? -1.0 : 1.0
        z_offset = flip_z ? 32.0.mm : 0.0
        Geom::Transformation.new([
          0, 1, 0, 0,
          0, 0, z_factor, 0,
          1, 0, 0, 0,
          tx.mm, ty.mm, (tz + z_offset).mm, 1
        ])
      end

      # Color Materials for Visual Inspection
      mat_red = model.materials['ALU Vertical Red'] || model.materials.add('ALU Vertical Red')
      mat_red.color = Sketchup::Color.new(220, 40, 40)

      mat_green = model.materials['ALU Horizontal Green'] || model.materials.add('ALU Horizontal Green')
      mat_green.color = Sketchup::Color.new(40, 180, 60)

      # 1. Outer Frame (Alumex Pages 13-16 - Clean 3D Coordinate Management System)
      jamb_h = height
      track_w = width

      # Top Track Head (70S-1001-1): GREEN - Solid Tool Subtraction notch
      top_track = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1001_1(root.entities, track_w)
      top_track = notch_top_track_solid_tool(top_track, track_w, 25.0)
      top_track.transform!(horiz_transform(0.0, 0.0, height - 32.0, false))
      top_track.material = mat_green

      # Bottom Track Sill (70S-1101-1): GREEN - Track beads face UP (+Z)
      bot_track = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1101_1(root.entities, track_w)
      bot_track.transform!(horiz_transform(0.0, 0.0, 0.0, false))
      bot_track.material = mat_green

      # Left Side Jamb (70S-1201-1): RED - Swapped from Right to Left (X=0) without rotation
      left_jamb = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1201_1(root.entities, jamb_h)
      left_jamb.transform!(Geom::Transformation.new([
        -1,  0, 0, 0,
         0, -1, 0, 0,
         0,  0, 1, 0,
         0.0, 70.0.mm, 0, 1
      ]))
      left_jamb.material = mat_red

      # Right Side Jamb (70S-1201-1): RED - Swapped from Left to Right (X=width) without rotation
      right_jamb = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1201_1(root.entities, jamb_h)
      right_jamb.transform!(Geom::Transformation.new([
        0, 1, 0, 0,
        1, 0, 0, 0,
        0, 0, 1, 0,
        width.mm, 0, 0, 1
      ]))
      right_jamb.material = mat_red

      # 2. Assembly Screws (BRIGHT RED SCREWS aligned 100% DEAD CENTER into CAD C-Rings)
      rot_screw_left = Geom::Transformation.rotation(ORIGIN, Y_AXIS, 90.degrees)  # Drives +X into C-loop
      rot_screw_right = Geom::Transformation.rotation(ORIGIN, Y_AXIS, -90.degrees) # Drives -X into C-loop

      # Top Left Corner Screws (70S-1001-1 C-rings at Y=17.94mm & Y=51.73mm, Z=height-4.75mm)
      s1 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s1.transform!(Geom::Transformation.translation([0.0.mm, 17.94.mm, (height - 7.0).mm]) * rot_screw_left)
      s2 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s2.transform!(Geom::Transformation.translation([0.0.mm, 51.73.mm, (height - 7.0).mm]) * rot_screw_left)

      # Top Right Corner Screws (70S-1001-1 C-rings at Y=17.94mm & Y=51.73mm, Z=height-7.0mm)
      s3 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s3.transform!(Geom::Transformation.translation([width.mm, 17.94.mm, (height - 7.0).mm]) * rot_screw_right)
      s4 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s4.transform!(Geom::Transformation.translation([width.mm, 51.73.mm, (height - 7.0).mm]) * rot_screw_right)

      # Bottom Left Corner Screws (70S-1101-1 C-rings at Y=18.0mm & Y=51.5mm, Z=7.0mm inside circular socket)
      s5 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s5.transform!(Geom::Transformation.translation([0.0.mm, 18.0.mm, 7.0.mm]) * rot_screw_left)
      s6 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s6.transform!(Geom::Transformation.translation([0.0.mm, 51.5.mm, 7.0.mm]) * rot_screw_left)

      # Bottom Right Corner Screws (70S-1101-1 C-rings at Y=18.0mm & Y=51.5mm, Z=7.0mm inside circular socket)
      s7 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s7.transform!(Geom::Transformation.translation([width.mm, 18.0.mm, 7.0.mm]) * rot_screw_right)
      s8 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s8.transform!(Geom::Transformation.translation([width.mm, 51.5.mm, 7.0.mm]) * rot_screw_right)

      # 3. Sliding Sashes (Alumex Page 13 & 16)
      sash_h = height - 62.0 + 20.0 # 10mm top & bottom overlap into tracks
      sash_w = (width - 50.0 + 30.0) / 2.0 # (Width - 2*jambs + interlock overlap) / 2
      
      # Left Sash Panel (Outer Track, Y = 7.0mm)
      left_sash = root.entities.add_group
      left_sash.name = "Left Sash Panel"
      
      # Top Rail 70S-1401 (Facing DOWN)
      st = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1401(left_sash.entities, sash_w)
      st.transform!(horiz_transform(0, 0, sash_h - 32.0, false))
      st.material = mat_green
      
      # Bottom Rail 70S-1501
      sb = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1501(left_sash.entities, sash_w)
      sb.transform!(horiz_transform(0, 0, 0))
      sb.material = mat_green
      
      # Left Stile 70S-1701 (Rotated 180 deg so glass channel points INWARD)
      sl = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1701(left_sash.entities, sash_h)
      sl.transform!(Geom::Transformation.translation([26.0.mm, 26.0.mm, 0]) * Geom::Transformation.rotation(ORIGIN, Z_AXIS, 180.degrees))
      sl.material = mat_red
      
      # Right Interlock Stile 70S-1701
      sr = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1701(left_sash.entities, sash_h)
      sr.transform!(Geom::Transformation.translation([sash_w.mm, 0, 0]))
      sr.material = mat_red

      # Insert V-Groove Roller Wheel Carriages in Left Sash
      roller1_l = AluDoorPilot::Hardware70S.draw_v_groove_roller(left_sash.entities)
      roller1_l.transform!(Geom::Transformation.translation([100.0.mm, 11.0.mm, 10.0.mm]))
      roller2_l = AluDoorPilot::Hardware70S.draw_v_groove_roller(left_sash.entities)
      roller2_l.transform!(Geom::Transformation.translation([(sash_w - 100.0).mm, 11.0.mm, 10.0.mm]))

      # Glass Panel Left
      add_glass(left_sash.entities, 26.0, 45.0, sash_w - 52.0, sash_h - 90.0, glass_thickness, 11.0)
      left_sash.transform!(Geom::Transformation.translation([25.0.mm, 7.0.mm, 20.0.mm]))

      # Right Sash Panel (Inner Track, Y = 40.5mm)
      right_sash = root.entities.add_group
      right_sash.name = "Right Sash Panel"
      
      # Top Rail 70S-1401 (Facing DOWN)
      rst = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1401(right_sash.entities, sash_w)
      rst.transform!(horiz_transform(0, 0, sash_h - 32.0, false))
      rst.material = mat_green
      
      # Bottom Rail 70S-1501
      rsb = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1501(right_sash.entities, sash_w)
      rsb.transform!(horiz_transform(0, 0, 0))
      rsb.material = mat_green
      
      # Left Interlock Stile 70S-1701
      rsl = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1701(right_sash.entities, sash_h)
      rsl.transform!(Geom::Transformation.translation([0, 0, 0]))
      rsl.material = mat_red
      
      # Right Side Stile 70S-1701 (Rotated 180 deg so glass channel points INWARD)
      rsr = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1701(right_sash.entities, sash_h)
      rsr.transform!(Geom::Transformation.translation([(sash_w + 26.0).mm, 26.0.mm, 0]) * Geom::Transformation.rotation(ORIGIN, Z_AXIS, 180.degrees))
      rsr.material = mat_red

      # Insert V-Groove Roller Wheel Carriages in Right Sash
      roller1_r = AluDoorPilot::Hardware70S.draw_v_groove_roller(right_sash.entities)
      roller1_r.transform!(Geom::Transformation.translation([100.0.mm, 11.0.mm, 10.0.mm]))
      roller2_r = AluDoorPilot::Hardware70S.draw_v_groove_roller(right_sash.entities)
      roller2_r.transform!(Geom::Transformation.translation([(sash_w - 100.0).mm, 11.0.mm, 10.0.mm]))

      # Glass Panel Right
      add_glass(right_sash.entities, 26.0, 45.0, sash_w - 52.0, sash_h - 90.0, glass_thickness, 11.0)
      right_sash.transform!(Geom::Transformation.translation([(width - 25.0 - sash_w).mm, 40.5.mm, 20.0.mm]))

      # 4. Production Cut List CSV
      cutlist = [
        'Profile,Description,Qty,Cut length mm',
        "70S-1001-1,Top Frame Head,1,#{track_w.round(1)}",
        "70S-1101-1,Bottom Frame Sill,1,#{track_w.round(1)}",
        "70S-1201-1,Full-Height Side Jambs,2,#{jamb_h.round(1)}",
        "70S-1401,Top Sash Rails,2,#{sash_w.round(1)}",
        "70S-1501,Bottom Sash Rails,2,#{sash_w.round(1)}",
        "70S-1701,Side Sash Stiles,2,#{sash_h.round(1)}",
        "70S-1601,Meeting Interlocks,2,#{sash_h.round(1)}",
        "70S-1914,V-Groove Roller Carriages,4,Hardware",
        "S.T. SCREWS,Assembly Screws 4.2x45mm,8,Hardware",
        "GLASS,Sash Glass Panels,2,#{((sash_w - 52.0)).round(1)} x #{((sash_h - 90.0)).round(1)}"
      ].join("\n")
      root.set_attribute('ALU_DOOR', 'cutlist_csv', cutlist)

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      UI.messagebox("70 mm Sliding Door App Generated!\n\nIncludes 100% w_clean.dxf vector profiles & V-Groove Roller Carriages.\n\n#{cutlist.gsub(',', '  |  ')}")
    rescue StandardError => error
      model.abort_operation if model
      UI.messagebox("Generation failed: #{error.message}")
      raise error
    end

    def add_sliding_panel(entities, name, x_mm, y_mm, z_mm, width_mm, height_mm, glass_thickness, reverse)
      panel = entities.add_group
      panel.name = name
      panel.set_attribute('ALU_DOOR', 'panel_role', reverse ? 'right' : 'left')
      sash_width = 65.0
      sash_depth = 32.4
      vertical_rotation = Geom::Transformation.rotation(ORIGIN, Y_AXIS, -90.degrees)
      add_member(panel.entities, 'ESD-1501 Sash Top', width_mm, sash_width, sash_depth,
                 Geom::Transformation.translation([x_mm.mm, y_mm.mm, (z_mm + height_mm).mm]))
      add_member(panel.entities, 'ESD-1501 Sash Bottom', width_mm, sash_width, sash_depth,
                 Geom::Transformation.translation([x_mm.mm, y_mm.mm, z_mm.mm]))
      outer_x = reverse ? x_mm + width_mm : x_mm
      meeting_x = reverse ? x_mm : x_mm + width_mm
      add_member(panel.entities, 'ESD-1501 Outer Stile', height_mm, sash_width, sash_depth,
                 Geom::Transformation.translation([outer_x.mm, y_mm.mm, z_mm.mm]) * vertical_rotation)
      add_member(panel.entities, 'ESD-1502 Meeting Interlock', height_mm, 38.5, 35.6,
                 Geom::Transformation.translation([meeting_x.mm, y_mm.mm, z_mm.mm]) * vertical_rotation)
      glass_rebate = 58.0
      add_glass(panel.entities, x_mm + glass_rebate, z_mm + glass_rebate,
                width_mm - (2.0 * glass_rebate), height_mm - (2.0 * glass_rebate),
                glass_thickness, y_mm)
    end

    def add_member(entities, name, length_mm, width_mm, depth_mm, transform)
      group = entities.add_group
      group.name = name
      group.set_attribute('ALU_DOOR', 'profile_code', name.split.first)
      group.set_attribute('ALU_DOOR', 'cut_length_mm', length_mm)
      create_hollow_prism(group.entities, length_mm, width_mm, depth_mm, 1.6)
      group.transform!(transform)
      group
    end

    def create_hollow_prism(entities, length_mm, width_mm, depth_mm, wall_mm)
      half_w = width_mm.mm / 2.0
      half_d = depth_mm.mm / 2.0
      wall = wall_mm.mm
      outer = [
        [0, -half_w, -half_d], [0, half_w, -half_d],
        [0, half_w, half_d], [0, -half_w, half_d]
      ]
      inner = [
        [0, -half_w + wall, -half_d + wall], [0, -half_w + wall, half_d - wall],
        [0, half_w - wall, half_d - wall], [0, half_w - wall, -half_d + wall]
      ]
      face = entities.add_face(outer)
      hole = entities.add_face(inner)
      hole.erase! if hole&.valid?
      face.pushpull(length_mm.mm)
    end

    def add_glass(entities, x_mm, z_mm, width_mm, height_mm, thickness_mm, y_mm = -15.0)
      return if width_mm <= 0 || height_mm <= 0
      group = entities.add_group
      group.name = 'Glass'
      y = y_mm.mm
      points = [
        [x_mm.mm, y, z_mm.mm], [(x_mm + width_mm).mm, y, z_mm.mm],
        [(x_mm + width_mm).mm, y, (z_mm + height_mm).mm], [x_mm.mm, y, (z_mm + height_mm).mm]
      ]
      face = group.entities.add_face(points)
      face.material = glass_material
      face.back_material = glass_material
      face.pushpull(thickness_mm.mm)
      group.set_attribute('ALU_DOOR', 'glass_width_mm', width_mm)
      group.set_attribute('ALU_DOOR', 'glass_height_mm', height_mm)
    end

    def glass_material
      model = Sketchup.active_model
      material = model.materials['ALU Pilot Glass'] || model.materials.add('ALU Pilot Glass')
      material.color = Sketchup::Color.new(120, 190, 220)
      material.alpha = 0.45
      material
    end

    def build_cutlist(width, height, sash_w, sash_h)
      [
        'Profile,Description,Qty,Cut length mm',
        "100D-3105,Frame horizontal,2,#{width.round(1)}",
        "100D-3105,Frame vertical,2,#{height.round(1)}",
        "100D-101,Sash horizontal,2,#{sash_w.round(1)}",
        "100D-101,Sash vertical,2,#{sash_h.round(1)}"
      ].join("\n")
    end

    def build_sliding_cutlist(width, height, sash_w, sash_h)
      [
        'Profile,Description,Qty,Cut length mm',
        "ESD-1001,Frame head and sill,2,#{width.round(1)}",
        "ESD-1001,Frame jamb,2,#{height.round(1)}",
        "ESD-1501,Sash horizontal,4,#{sash_w.round(1)}",
        "ESD-1501,Outer stile,2,#{sash_h.round(1)}",
        "ESD-1502,Meeting interlock,2,#{sash_h.round(1)}"
      ].join("\n")
    end

    def show_cutlist
      group = Sketchup.active_model.selection.find { |entity| entity.is_a?(Sketchup::Group) }
      text = group&.get_attribute('ALU_DOOR', 'cutlist_csv')
      UI.messagebox(text || 'Select a generated ALU Door Pilot group first.')
    end

    def remove_previous(model)
      previous = model.entities.grep(Sketchup::Group).select { |group| group.get_attribute('ALU_DOOR', 'system') }
      model.entities.erase_entities(previous) unless previous.empty?
    end

    def generate_sliding70_frame_only
      prompts = ['Overall width (mm)', 'Overall height (mm)']
      defaults = [1800.0, 2100.0]
      values = UI.inputbox(prompts, defaults, '70 mm Frame ONLY Inspector')
      return unless values

      width, height = values.map(&:to_f)
      
      model = Sketchup.active_model
      model.start_operation('Generate 70 mm Frame Only', true)
      remove_previous(model)
      root = model.entities.add_group
      root.name = format('70 mm Outer Frame %.0f x %.0f', width, height)
      root.set_attribute('ALU_DOOR', 'system', '70 mm sliding frame only')

      def horiz_transform(tx, ty, tz, flip_z = false)
        z_factor = flip_z ? -1.0 : 1.0
        z_offset = flip_z ? 32.0.mm : 0.0
        Geom::Transformation.new([
          0, 1, 0, 0,
          0, 0, z_factor, 0,
          1, 0, 0, 0,
          tx.mm, ty.mm, (tz + z_offset).mm, 1
        ])
      end

      jamb_h = height
      track_w = width

      # Top Track Head (1001-1) - Solid Tool Subtraction notch
      top_track = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1001_1(root.entities, track_w)
      top_track = notch_top_track_solid_tool(top_track, track_w, 25.0)
      top_track.transform!(horiz_transform(0.0, 0.0, height - 32.0, false))

      # Bottom Track Sill (1101-1)
      bot_track = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1101_1(root.entities, track_w)
      bot_track.transform!(horiz_transform(0.0, 0.0, 0.0, false))

      # Left Side Jamb (1201-1) - Swapped from Right to Left (X=0) without rotation
      left_jamb = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1201_1(root.entities, jamb_h)
      left_jamb.transform!(Geom::Transformation.new([
        -1,  0, 0, 0,
         0, -1, 0, 0,
         0,  0, 1, 0,
         0.0, 70.0.mm, 0, 1
      ]))

      # Right Side Jamb (1201-1) - Swapped from Left to Right (X=width) without rotation
      right_jamb = AluDoorPilot::Profiles70SCleanDXF.draw_70S_1201_1(root.entities, jamb_h)
      right_jamb.transform!(Geom::Transformation.new([
        0, 1, 0, 0,
        1, 0, 0, 0,
        0, 0, 1, 0,
        width.mm, 0, 0, 1
      ]))

      # Screws (Passing HORIZONTALLY into C-channel loops)
      rot_screw_left = Geom::Transformation.rotation(ORIGIN, Y_AXIS, 90.degrees)
      rot_screw_right = Geom::Transformation.rotation(ORIGIN, Y_AXIS, -90.degrees)

      s1 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s1.transform!(Geom::Transformation.translation([0.0.mm, 17.94.mm, (height - 7.0).mm]) * rot_screw_left)
      s2 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s2.transform!(Geom::Transformation.translation([0.0.mm, 51.73.mm, (height - 7.0).mm]) * rot_screw_left)

      s3 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s3.transform!(Geom::Transformation.translation([width.mm, 17.94.mm, (height - 7.0).mm]) * rot_screw_right)
      s4 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s4.transform!(Geom::Transformation.translation([width.mm, 51.73.mm, (height - 7.0).mm]) * rot_screw_right)

      s5 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s5.transform!(Geom::Transformation.translation([0.0.mm, 18.0.mm, 7.0.mm]) * rot_screw_left)
      s6 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s6.transform!(Geom::Transformation.translation([0.0.mm, 51.5.mm, 7.0.mm]) * rot_screw_left)

      s7 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s7.transform!(Geom::Transformation.translation([width.mm, 18.0.mm, 7.0.mm]) * rot_screw_right)
      s8 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
      s8.transform!(Geom::Transformation.translation([width.mm, 51.5.mm, 7.0.mm]) * rot_screw_right)

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      UI.messagebox("70 mm Outer Frame ONLY Generated!\n\nVerify Top Head, Bottom Sill, Left/Right Jambs & Assembly Screws.")
    rescue StandardError => error
      model.abort_operation if model
      UI.messagebox("Generation failed: #{error.message}")
      raise error
    end

    unless file_loaded?(__FILE__)
      menu = UI.menu('Extensions').add_submenu(PLUGIN_NAME)
      menu.add_item('⚡ Launch 70S Workshop & PO Engine (Auth Activated)') { AluDoorPilot::ReportDialog.show_report(1500.0, 2100.0, false) }
      menu.add_item('🔑 Switch Fabricator Account (Sign Out)') { AluDoorPilot::ReportDialog.logout }
      menu.add_separator
      menu.add_item('📑 70S Workshop Report & 1D Bar Nesting Plan') { AluDoorPilot::ReportDialog.show_interactive }
      menu.add_item('🌟 70S Sliding Door Full System App') { AluDoorPilot::System70S.run_app_interactive }
      menu.add_item('📊 Export 70S BOM (Bill of Materials)') { AluDoorPilot::System70S.export_bom_csv(1500.0, 2100.0) }
      menu.add_item('📐 Export 70S 1D Bar Nesting Cutlist') { AluDoorPilot::System70S.export_nesting_csv(1500.0, 2100.0) }
      menu.add_separator
      menu.add_item('Complete 70S Sliding Door (Frame + Sashes + Glass)') { AluDoorPilot::Profiles70SCleanDXF.build_70s_sliding_door_interactive }
      menu.add_item('70S Door Sliders ONLY (Sashes + Glass + Rollers)') { AluDoorPilot::Profiles70SCleanDXF.sliders_70mm_interactive }
      menu.add_item('70mm Outer Wall Frame ONLY') { AluDoorPilot::Profiles70SCleanDXF.frame_70mm_interactive }
      menu.add_item('Draw 70S-1601 Bar (Interlock Stile)') { AluDoorPilot::Profiles70SCleanDXF.bar_70S_1601_interactive }
      menu.add_item('SIDE 70S-1201-1 (Uprights Only)') { AluDoorPilot::Profiles70SCleanDXF.side_70S_1201_1_interactive }
      menu.add_item('Preview All 70S Profiles') { AluDoorPilot::Profiles70SCleanDXF.preview_all_profiles }
      menu.add_item('Clear Workspace') { AluDoorPilot::Profiles70SCleanDXF.clear_scene }
      file_loaded(__FILE__)
    end
  end
end
