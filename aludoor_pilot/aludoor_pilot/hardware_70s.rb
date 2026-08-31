module AluDoorPilot
  module Hardware70S
    extend self

    # Creates a 3D Assembly Self-Tapping Screw (S.T. Screw)
    def draw_st_screw(entities, length_mm=38.0)
      group = entities.add_group
      group.name = "S.T. Assembly Screw 4.2x#{length_mm.round}mm"

      head_r = 4.0.mm
      shaft_r = 2.1.mm
      head_h = 3.0.mm
      shaft_len = length_mm.mm - head_h

      # Screw Head (Countersunk Cone)
      c_top = group.entities.add_circle([0, 0, shaft_len + head_h], [0, 0, 1], head_r, 12)
      f_top = group.entities.add_face(c_top)

      c_base = group.entities.add_circle([0, 0, shaft_len], [0, 0, 1], shaft_r, 12)
      f_base = group.entities.add_face(c_base)

      # Shaft Cylinder
      if f_base&.valid?
        f_base.pushpull(-shaft_len)
      end

      # Material (Bright Red Screws)
      screw_mat = Sketchup.active_model.materials['ALU Screw Metal Red'] || Sketchup.active_model.materials.add('ALU Screw Metal Red')
      screw_mat.color = Sketchup::Color.new(255, 0, 0)
      group.material = screw_mat

      group
    end

    # Helper to add a clean 3D solid box with guaranteed upward normal
    def add_box(entities, min_x, max_x, min_y, max_y, min_z, max_z)
      face = entities.add_face([
        [min_x, min_y, min_z],
        [max_x, min_y, min_z],
        [max_x, max_y, min_z],
        [min_x, max_y, min_z]
      ])
      if face&.valid?
        face.reverse! if face.normal.z < 0
        face.pushpull(max_z - min_z)
      end
      face
    end

    # Creates a 3D V-Groove Roller Wheel & Carriage Housing (70S-1914)
    # Correctly modeled PARALLEL to the door:
    # - Wheel bottom sits at Z = 0 to roll directly on track bead
    # - Inverted U-bracket extends UP inside the 70S-1501 bottom sash rail chamber
    def draw_v_groove_roller(entities)
      group = entities.add_group
      group.name = "70S-1914 Roller Carriage & V-Groove Wheel"

      b_w = 14.0.mm
      b_l = 38.0.mm
      b_bot = 4.0.mm
      b_top = 28.0.mm
      t   = 1.5.mm

      # 1. Left plate (extends UP from Z=4mm to Z=28mm)
      add_box(group.entities, -b_w/2.0, -b_w/2.0 + t, -b_l/2.0, b_l/2.0, b_bot, b_top)

      # 2. Right plate (extends UP from Z=4mm to Z=28mm)
      add_box(group.entities, b_w/2.0 - t, b_w/2.0, -b_l/2.0, b_l/2.0, b_bot, b_top)

      # 3. Top plate (ceiling of inverted U at Z=26.5mm to 28mm)
      add_box(group.entities, -b_w/2.0, b_w/2.0, -b_l/2.0, b_l/2.0, b_top - t, b_top)

      # 4. V-Groove Wheel (Radius 12mm, bottom at Z=0 resting on track bead)
      wheel_r = 12.0.mm
      wheel_w = 10.0.mm
      wheel_z = 12.0.mm

      c_wheel = group.entities.add_circle([-wheel_w/2.0, 0, wheel_z], [1, 0, 0], wheel_r, 24)
      f_wheel = group.entities.add_face(c_wheel)
      if f_wheel&.valid?
        f_wheel.reverse! if f_wheel.normal.x < 0
        f_wheel.pushpull(wheel_w)
      end

      # 5. Axle Pin (Diameter 4mm, along X-axis at wheel center)
      c_axle = group.entities.add_circle([-b_w/2.0 - 0.5.mm, 0, wheel_z], [1, 0, 0], 2.0.mm, 12)
      f_axle = group.entities.add_face(c_axle)
      if f_axle&.valid?
        f_axle.reverse! if f_axle.normal.x < 0
        f_axle.pushpull(b_w + 1.0.mm)
      end

      # Metal Material
      mat = Sketchup.active_model.materials['ALU Roller Hardware'] || Sketchup.active_model.materials.add('ALU Roller Hardware')
      mat.color = Sketchup::Color.new(200, 205, 215)
      group.material = mat

      group
    end
  end
end
