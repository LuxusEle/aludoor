module AluDoorPilot
  module Profiles70mm
    extend self

    # Extrudes a given 2D profile loop along a length and groups it.
    def extrude_profile(entities, points, length_mm, name="Profile")
      group = entities.add_group
      group.name = name
      face = group.entities.add_face(points)
      if face&.valid?
        face.reverse! if face.normal.z < 0 
        face.pushpull(length_mm.mm)
      end
      group
    end

    # Helper to generate points for the curved screw spline / C-channels
    def draw_c_channel(cx, plate_top)
      ro = 3.0.mm
      ri = 1.7.mm
      cy = plate_top + 1.5.mm # Center adjusted so arc connects smoothly to plate
      
      pts = []
      # Ensure it starts exactly on the flat plate
      pts << [cx - ro, plate_top, 0]
      
      # Outer left wall going up
      [150, 135].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + ro * Math.cos(a), cy + ro * Math.sin(a), 0]
      end
      # Inner bowl going down and back up
      [135, 180, 225, 270, 315, 0, 45].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + ri * Math.cos(a), cy + ri * Math.sin(a), 0]
      end
      # Outer right wall going down
      [45, 30].each do |deg|
        a = deg * Math::PI / 180.0
        pts << [cx + ro * Math.cos(a), cy + ro * Math.sin(a), 0]
      end
      
      # Ensure it ends exactly on the flat plate
      pts << [cx + ro, plate_top, 0]
      
    # Helper to generate points for the roller track (top bead + bottom C-channel)
    def draw_roller_track(cx, plate_y)
      t = 1.3.mm
      bead_r = 2.0.mm
      stem_h = 10.0.mm
      
      pts = []
      # Bottom C-channel (facing down)
      c_pts = draw_c_channel(cx, plate_y - 2.0.mm)
      c_pts.map! { |p| [p[0], plate_y - (p[1] - plate_y), p[2]] }
      pts.concat(c_pts.reverse)
      
      pts
    end

    # 70S-1001-1 Top Frame (Exact from image)
    def draw_70S_1001_1(entities, length_mm)
      w = 70.0.mm
      h = 32.0.mm
      t = 1.3.mm
      lip = 6.0.mm
      
      top_y = h
      plate_top = h - 8.4.mm
      plate_bot = plate_top - t
      
      u_width = 6.0.mm
      u_height = 4.4.mm # approximate height of the C channel
      
      # Centers of the two C-channels
      c1 = 17.5.mm
      c2 = 52.5.mm
      
      track_points = [
        [0, 0, 0], 
        [0, top_y, 0], 
        [lip, top_y, 0], 
        [lip, top_y - t, 0],
        [t, top_y - t, 0], 
        [t, plate_top, 0]
      ]
      
      # Insert Left C-channel curves (starts at c1 - 3.0.mm on the plate)
      track_points.concat(draw_c_channel(c1, plate_top))
      
      # Insert Right C-channel curves (starts at c2 - 3.0.mm on the plate)
      track_points.concat(draw_c_channel(c2, plate_top))
      
      track_points.concat([
        [w - t, plate_top, 0], 
        [w - t, top_y - t, 0],
        [w - lip, top_y - t, 0], 
        [w - lip, top_y, 0],
        [w, top_y, 0], 
        [w, 0, 0],
        
        # Inner bottom path
        [w - t, 0, 0],
        [w - t, plate_bot, 0],
        [35.0.mm + t/2, plate_bot, 0],
        [35.0.mm + t/2, 0, 0],
        [35.0.mm - t/2, 0, 0],
        [35.0.mm - t/2, plate_bot, 0],
        [t, plate_bot, 0],
        [t, 0, 0]
      ])
      extrude_profile(entities, track_points, length_mm)
    end

    # 70S-1101-1 Bottom Frame (Tracks)
    def draw_70S_1101_1(entities, length_mm)
      w = 70.0.mm
      h_left = 10.0.mm
      h_right = 30.0.mm
      t = 1.3.mm
      
      # The plate slopes from h_left up to (h_right - 17) on the right
      plate_y_left = h_left
      plate_y_right = h_right - 17.0.mm
      
      c1 = 18.0.mm
      c2 = c1 + 35.0.mm # Assume identical spacing as top frame
      
      track_points = [
        [0, 0, 0], [10.mm, 0, 0], [10.mm, t, 0], [t, t, 0],
        [t, plate_y_left, 0]
      ]
      
      # For the tracks, we'll draw a simplified stem and bead
      track_points.concat([
        [c1 - t/2, plate_y_left + (plate_y_right - plate_y_left)*(c1/w), 0],
        [c1 - t/2, plate_y_left + 10.mm, 0],
        [c1 - 2.mm, plate_y_left + 12.mm, 0], [c1 + 2.mm, plate_y_left + 12.mm, 0],
        [c1 + t/2, plate_y_left + 10.mm, 0],
        [c1 + t/2, plate_y_left + (plate_y_right - plate_y_left)*(c1/w), 0]
      ])
      
      track_points.concat([
        [c2 - t/2, plate_y_left + (plate_y_right - plate_y_left)*(c2/w), 0],
        [c2 - t/2, plate_y_left + 10.mm, 0],
        [c2 - 2.mm, plate_y_left + 12.mm, 0], [c2 + 2.mm, plate_y_left + 12.mm, 0],
        [c2 + t/2, plate_y_left + 10.mm, 0],
        [c2 + t/2, plate_y_left + (plate_y_right - plate_y_left)*(c2/w), 0]
      ])
      
      track_points.concat([
        [w - t, plate_y_right, 0], [w - t, h_right, 0], [w - 6.mm, h_right, 0],
        [w - 6.mm, h_right - t, 0], [w, h_right - t, 0], [w, 0, 0],
        [w - 10.mm, 0, 0], [w - 10.mm, t, 0], [w - t, t, 0],
        [w - t, plate_y_right - t, 0],
        [t, plate_y_left - t, 0], [0, plate_y_left - t, 0]
      ])
      
      extrude_profile(entities, track_points, length_mm, "70S-1101-1 Bottom Frame")
    end

    # 70S-1401 Top Sash (Exact CAD)
    def draw_70S_1401(entities, length_mm)
      w_top = 28.0.mm
      h = 32.0.mm
      t = 1.3.mm
      
      drop_top = 10.0.mm
      plate_y = 14.0.mm
      
      # Bottom step is 3mm per instruction
      step_w = 3.0.mm
      
      # Clean, simple continuous loop:
      pts = [
        # Outer contour starting bottom-left step corner
        [step_w, 0, 0], [0, 0, 0], [0, plate_y, 0], [0, h, 0],
        [8.0.mm, h, 0], [8.0.mm, h - drop_top, 0], [t, h - drop_top, 0],
        [t, plate_y + t, 0]
      ]
      pts.concat(draw_c_channel(w_top / 2.0, plate_y + t))
      pts.concat([
        [w_top - t, plate_y + t, 0],
        [w_top - t, h - drop_top, 0], [w_top - 8.0.mm, h - drop_top, 0], [w_top - 8.0.mm, h, 0],
        [w_top, h, 0], [w_top, plate_y, 0], [w_top - step_w, plate_y, 0], [w_top - step_w, 0, 0],
        [w_top - 22.0.mm + step_w, 0, 0], [w_top - 22.0.mm + step_w, t, 0], [w_top - 22.0.mm + step_w + t, t, 0],
        [w_top - 22.0.mm + step_w + t, plate_y - t, 0],
        [step_w + t, plate_y - t, 0],
        [step_w + t, t, 0], [step_w + 3.0.mm, t, 0], [step_w + 3.0.mm, 0, 0]
      ])

      extrude_profile(entities, pts, length_mm, "70S-1401 Top Sash")
    end

    # 70S-1201-1 Side Jamb
    def draw_70S_1201_1(entities, length_mm)
      w = 73.0.mm
      d = 25.0.mm
      t = 1.3.mm
      step_x = 37.5.mm
      plate_y = d - 9.5.mm
      
      points = [
        [0, 0, 0], [0, d, 0], [6.mm, d, 0], [6.mm, d - t, 0], [t, d - t, 0],
        [t, t, 0], [step_x - t, t, 0], [step_x - t, plate_y - t, 0],
        [w - t, plate_y - t, 0], [w - t, d - t, 0], [w - 6.mm, d - t, 0],
        [w - 6.mm, d, 0], [w, d, 0], [w, 0, 0],
        [step_x, 0, 0], [step_x, plate_y, 0], [step_x + 3.mm, plate_y, 0],
        [step_x + 3.mm, plate_y - t, 0], [step_x + t, plate_y - t, 0], [step_x + t, 0, 0]
      ]
      extrude_profile(entities, points, length_mm, "70S-1201-1 Side Jamb")
    end

    # 70S-1701 Side Sash
    def draw_70S_1701(entities, length_mm)
      w = 30.0.mm
      h = 26.0.mm
      t = 1.3.mm
      gap = 10.0.mm
      lip_w = (h - gap) / 2.0
      mid_x = 12.0.mm
      
      # Using a slit to create the hollow rectangular section as a single continuous loop
      points = [
        [0, 0, 0], [w, 0, 0], [w, h, 0], [0, h, 0], 
        [0, h - lip_w, 0], [mid_x - t, h - lip_w, 0], [mid_x - t, lip_w, 0], [0, lip_w, 0],
        [0, t, 0], [mid_x, t, 0], 
        # Enter hollow box
        [mid_x, h - t, 0], [w - t, h - t, 0], [w - t, t, 0], [mid_x, t, 0]
      ]
      extrude_profile(entities, points, length_mm, "70S-1701 Side Sash")
    end
  end
end
