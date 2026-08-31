module AluDoorPilot
  module Profiles70S
    extend self

    # Extrudes a given 2D profile loop along a length (in mm) and wraps in a named Group.
    def extrude_profile(entities, points, length_mm, name="70S Profile")
      # Filter out consecutive duplicate points
      clean_pts = []
      points.each do |p|
        p_pt = Geom::Point3d.new(p[0], p[1], p[2])
        if clean_pts.empty? || clean_pts.last.distance(p_pt) > 0.001.mm
          clean_pts << p_pt
        end
      end
      if clean_pts.length > 1 && clean_pts.first.distance(clean_pts.last) < 0.001.mm
        clean_pts.pop
      end

      group = entities.add_group
      group.name = name
      face = group.entities.add_face(clean_pts)
      if face&.valid?
        face.reverse! if face.normal.z < 0 
        face.pushpull(length_mm.mm)
      else
        puts "ERROR: Failed to generate face for #{name}"
      end
      group
    end

    # Helper: Imports w.jpg directly into SketchUp at 1:1 scale as a blueprint stencil
    def import_stencil(entities, width_mm=210.0)
      image_path = "C:/Users/asank/Documents/ALU DOOR/w.jpg"
      if File.exist?(image_path)
        img = entities.add_image(image_path, ORIGIN, width_mm.mm)
        img.name = "w.jpg Blueprint Stencil"
        puts "SUCCESS: Imported w.jpg blueprint stencil at 1:1 scale!"
        img
      else
        puts "ERROR: Could not find stencil image at #{image_path}"
        nil
      end
    end

    # Helper: Generate C-Channel screw port curves (facing UP)
    def draw_c_channel_up(cx, plate_top)
      ro = 3.0.mm
      ri = 1.7.mm
      cy = plate_top + 1.5.mm
      
      pts = [[cx - ro, plate_top, 0]]
      [150, 135].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + ro * Math.cos(a), cy + ro * Math.sin(a), 0]
      end
      [135, 180, 225, 270, 315, 0, 45].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + ri * Math.cos(a), cy + ri * Math.sin(a), 0]
      end
      [45, 30].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + ro * Math.cos(a), cy + ro * Math.sin(a), 0]
      end
      pts << [cx + ro, plate_top, 0]
      pts
    end

    # Helper: Generate C-Channel screw port curves (facing DOWN)
    def draw_c_channel_down(cx, plate_bot)
      pts = draw_c_channel_up(cx, plate_bot - 2.0.mm)
      pts.map! { |p| [p[0], plate_bot - (p[1] - plate_bot), p[2]] }
      pts.reverse
    end

    # Helper: Top Roller Stem & Bead (facing UP)
    def draw_roller_bead(cx, plate_top)
      t = 1.3.mm
      bead_r = 2.0.mm
      stem_h = 10.0.mm
      
      pts = [
        [cx - t/2, plate_top, 0],
        [cx - t/2, plate_top + stem_h, 0]
      ]
      [225, 180, 135, 90, 45, 0, 315].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + bead_r * Math.cos(a), plate_top + stem_h + bead_r + bead_r * Math.sin(a), 0]
      end
      pts.concat([
        [cx + t/2, plate_top + stem_h, 0],
        [cx + t/2, plate_top, 0]
      ])
      pts
    end

    # ==========================================
    # PROFILES DEFINITIONS (FALWLESS NON-INTERSECTING LOOPS)
    # ==========================================

    # 1. SECTION NO. 70S-1001-1 (Top Frame)
    def draw_70S_1001_1(entities, length_mm)
      w = 70.0.mm
      h = 32.0.mm
      t = 1.3.mm
      lip = 6.0.mm
      drop = 8.4.mm
      plate_top = h - drop
      plate_bot = plate_top - t
      c1 = 17.5.mm
      c2 = 52.5.mm

      pts = [
        [0, 0, 0], [0, h, 0], [lip, h, 0], [lip, h - t, 0], [t, h - t, 0], [t, plate_top, 0]
      ]
      pts.concat(draw_c_channel_up(c1, plate_top))
      pts.concat(draw_c_channel_up(c2, plate_top))
      pts.concat([
        [w - t, plate_top, 0], [w - t, h - t, 0], [w - lip, h - t, 0], [w - lip, h, 0], [w, h, 0], [w, 0, 0],
        [w - t, 0, 0], [w - t, plate_bot, 0],
        [35.0.mm + t/2, plate_bot, 0], [35.0.mm + t/2, 0, 0], [35.0.mm - t/2, 0, 0], [35.0.mm - t/2, plate_bot, 0],
        [t, plate_bot, 0], [t, 0, 0]
      ])
      extrude_profile(entities, pts, length_mm, "70S-1001-1 Top Frame")
    end

    # 2. SECTION NO. 70S-1101-1 (Bottom Frame / Tracks)
    def draw_70S_1101_1(entities, length_mm)
      w = 70.0.mm
      h_left = 10.0.mm
      h_right = 30.0.mm
      t = 1.3.mm
      p_left = 10.0.mm
      p_right = 13.0.mm
      c1 = 18.0.mm
      c2 = 53.0.mm

      py1 = p_left + (p_right - p_left)*(c1/w)
      py2 = p_left + (p_right - p_left)*(c2/w)

      pts = [
        [0, 0, 0], [10.mm, 0, 0], [10.mm, t, 0], [t, t, 0], [t, p_left - t, 0]
      ]
      # Bottom C-channels under plate (right to left)
      pts.concat(draw_c_channel_down(c1, py1 - t))
      pts.concat(draw_c_channel_down(c2, py2 - t))

      pts.concat([
        [w - t, p_right - t, 0], [w - t, t, 0], [w - 10.mm, t, 0], [w - 10.mm, 0, 0],
        [w, 0, 0], [w, h_right - t, 0], [w - 6.mm, h_right - t, 0], [w - 6.mm, h_right, 0],
        [w - t, h_right, 0], [w - t, p_right, 0]
      ])

      # Top Roller Stems (right to left)
      pts.concat(draw_roller_bead(c2, py2).reverse)
      pts.concat(draw_roller_bead(c1, py1).reverse)

      pts.concat([
        [t, p_left, 0], [t, h_left, 0], [0, h_left, 0]
      ])
      extrude_profile(entities, pts, length_mm, "70S-1101-1 Bottom Frame")
    end

    # 3. SECTION NO. 70S-1201-1 (Side Jamb)
    def draw_70S_1201_1(entities, length_mm)
      w = 73.0.mm
      d = 25.0.mm
      t = 1.3.mm
      step_x = 37.5.mm
      plate_y = d - 9.5.mm
      
      pts = [
        [0, 0, 0], [0, d, 0], [6.mm, d, 0], [6.mm, d - t, 0], [t, d - t, 0],
        [t, t, 0], [step_x - t, t, 0], [step_x - t, plate_y - t, 0],
        [w - t, plate_y - t, 0], [w - t, d - t, 0], [w - 6.mm, d - t, 0],
        [w - 6.mm, d, 0], [w, d, 0], [w, 0, 0],
        [step_x + t, 0, 0], [step_x + t, plate_y, 0], [step_x, plate_y, 0],
        [step_x, 0, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1201-1 Side Jamb")
    end

    # 4. SECTION NO. 70S-1401 (Top Sash)
    def draw_70S_1401(entities, length_mm)
      w_top = 28.0.mm
      h = 32.0.mm
      t = 1.3.mm
      drop_top = 10.0.mm
      plate_y = 14.0.mm
      step_w = 3.0.mm
      lip_bot = 6.0.mm

      pts = [
        [step_w, 0, 0], [step_w + lip_bot, 0, 0], [step_w + lip_bot, t, 0], [step_w + t, t, 0],
        [step_w + t, plate_y - t, 0], [w_top - step_w - t, plate_y - t, 0],
        [w_top - step_w - t, t, 0], [w_top - step_w - lip_bot, t, 0], [w_top - step_w - lip_bot, 0, 0],
        [w_top - step_w, 0, 0], [w_top - step_w, plate_y, 0], [w_top, plate_y, 0], [w_top, h, 0],
        [w_top - 4.3.mm, h, 0], [w_top - 4.3.mm, h - drop_top, 0], [w_top - t, h - drop_top, 0],
        [w_top - t, plate_y + t, 0]
      ]
      pts.concat(draw_c_channel_up(w_top / 2.0, plate_y + t))
      pts.concat([
        [t, plate_y + t, 0], [t, h - drop_top, 0], [4.3.mm, h - drop_top, 0], [4.3.mm, h, 0],
        [0, h, 0], [0, plate_y, 0], [step_w, plate_y, 0]
      ])
      extrude_profile(entities, pts, length_mm, "70S-1401 Top Sash")
    end

    # 5. SECTION NO. 70S-1501 (Bottom Sash)
    def draw_70S_1501(entities, length_mm)
      w = 22.0.mm
      h = 56.2.mm
      t = 1.3.mm
      gap = 10.0.mm
      lip_w = (w - gap) / 2.0
      plate_y = 45.2.mm
      bot_lip = 6.0.mm

      pts = [
        [0, 0, 0], [bot_lip, 0, 0], [bot_lip, t, 0], [t, t, 0], [t, plate_y - t, 0]
      ]
      pts.concat(draw_c_channel_down(w/2.0, plate_y - t))
      pts.concat([
        [w - t, plate_y - t, 0], [w - t, t, 0], [w - bot_lip, t, 0], [w - bot_lip, 0, 0], [w, 0, 0],
        [w, h, 0], [w - lip_w, h, 0], [w - lip_w, h - t, 0], [w - t, h - t, 0],
        [w - t, plate_y + t, 0], [t, plate_y + t, 0],
        [t, h - t, 0], [lip_w, h - t, 0], [lip_w, h, 0], [0, h, 0]
      ])
      extrude_profile(entities, pts, length_mm, "70S-1501 Bottom Sash")
    end

    # 6. SECTION NO. 70S-1701 (Side Sash)
    def draw_70S_1701(entities, length_mm)
      w = 30.0.mm
      h = 26.0.mm
      t = 1.3.mm
      gap = 10.0.mm
      lip_w = (h - gap) / 2.0
      mid_x = 12.0.mm

      pts = [
        [0, 0, 0], [w, 0, 0], [w, h, 0], [0, h, 0], 
        [0, h - lip_w, 0], [mid_x - t, h - lip_w, 0], [mid_x - t, lip_w, 0], [0, lip_w, 0],
        [0, t, 0], [mid_x, t, 0], 
        [mid_x, h - t, 0], [w - t, h - t, 0], [w - t, t, 0], [mid_x, t, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1701 Side Sash")
    end
  end
end
