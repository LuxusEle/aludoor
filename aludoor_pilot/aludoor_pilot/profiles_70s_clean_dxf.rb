module AluDoorPilot
  module Profiles70SCleanDXF
    extend self

    def extrude_profile(entities, points, length_mm, name="Clean DXF Profile")
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
        puts "ERROR: Could not generate face for #{name}"
      end
      group
    end

    # 100% Exact Vector CAD from w_clean.dxf: 70S-1001-1 Top Frame (69.72mm x 32.00mm)
    def draw_70S_1001_1(entities, length_mm)
      pts = [
        [1.3.mm, 0.0.mm, 0],
        [0.0.mm, 0.0.mm, 0],
        [0.0.mm, 31.581.mm, 0],
        [0.339.mm, 31.959.mm, 0],
        [5.979.mm, 32.0.mm, 0],
        [5.979.mm, 30.686.mm, 0],
        [2.077.mm, 30.686.mm, 0],
        [1.373.mm, 30.069.mm, 0],
        [1.314.mm, 25.685.mm, 0],
        [2.077.mm, 24.923.mm, 0],
        [14.417.mm, 24.923.mm, 0],
        [14.756.mm, 25.431.mm, 0],
        [14.629.mm, 28.059.mm, 0],
        [15.987.mm, 29.584.mm, 0],
        [16.713.mm, 28.941.mm, 0],
        [16.044.mm, 27.524.mm, 0],
        [16.166.mm, 25.967.mm, 0],
        [17.64.mm, 24.923.mm, 0],
        [19.082.mm, 25.271.mm, 0],
        [19.706.mm, 25.984.mm, 0],
        [19.828.mm, 27.524.mm, 0],
        [19.167.mm, 29.035.mm, 0],
        [19.929.mm, 29.584.mm, 0],
        [21.244.mm, 27.973.mm, 0],
        [21.117.mm, 25.431.mm, 0],
        [21.455.mm, 24.923.mm, 0],
        [48.255.mm, 24.923.mm, 0],
        [48.594.mm, 25.262.mm, 0],
        [48.467.mm, 27.973.mm, 0],
        [49.824.mm, 29.584.mm, 0],
        [50.586.mm, 28.822.mm, 0],
        [49.911.mm, 27.51.mm, 0],
        [50.024.mm, 25.998.mm, 0],
        [51.478.mm, 24.923.mm, 0],
        [52.962.mm, 25.269.mm, 0],
        [53.554.mm, 25.981.mm, 0],
        [53.719.mm, 27.375.mm, 0],
        [53.003.mm, 28.822.mm, 0],
        [53.765.mm, 29.584.mm, 0],
        [54.996.mm, 28.355.mm, 0],
        [54.996.mm, 25.262.mm, 0],
        [55.335.mm, 24.923.mm, 0],
        [67.676.mm, 24.923.mm, 0],
        [68.438.mm, 25.897.mm, 0],
        [68.363.mm, 30.04.mm, 0],
        [67.676.mm, 30.686.mm, 0],
        [63.733.mm, 30.686.mm, 0],
        [63.733.mm, 32.0.mm, 0],
        [69.329.mm, 32.0.mm, 0],
        [69.709.mm, 31.662.mm, 0],
        [69.719.mm, 0.0.mm, 0],
        [68.419.mm, 0.0.mm, 0],
        [68.419.mm, 23.36.mm, 0],
        [36.51.mm, 23.608.mm, 0],
        [35.65.mm, 23.236.mm, 0],
        [35.65.mm, 0.0.mm, 0],
        [34.35.mm, 0.0.mm, 0],
        [34.35.mm, 23.351.mm, 0],
        [2.292.mm, 23.608.mm, 0],
        [1.3.mm, 23.253.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1001-1 Top Frame")
    end

    # 100% Exact Vector CAD from w_clean.dxf: 70S-1401 Top Sash (27.90mm x 31.66mm)
    def draw_70S_1401(entities, length_mm)
      pts = [
        [3.008.mm, 0.299.mm, 0],
        [3.008.mm, 21.277.mm, 0],
        [0.0.mm, 22.251.mm, 0],
        [0.0.mm, 24.244.mm, 0],
        [0.524.mm, 24.762.mm, 0],
        [1.228.mm, 22.844.mm, 0],
        [2.923.mm, 22.971.mm, 0],
        [3.008.mm, 30.26.mm, 0],
        [2.5.mm, 30.77.mm, 0],
        [1.228.mm, 30.686.mm, 0],
        [0.93.mm, 28.969.mm, 0],
        [0.094.mm, 28.969.mm, 0],
        [0.211.mm, 31.659.mm, 0],
        [4.28.mm, 31.406.mm, 0],
        [4.619.mm, 15.088.mm, 0],
        [10.684.mm, 15.088.mm, 0],
        [10.598.mm, 18.012.mm, 0],
        [12.077.mm, 19.735.mm, 0],
        [12.718.mm, 19.2.mm, 0],
        [12.112.mm, 16.357.mm, 0],
        [13.296.mm, 15.193.mm, 0],
        [14.583.mm, 15.172.mm, 0],
        [15.751.mm, 16.233.mm, 0],
        [15.939.mm, 17.247.mm, 0],
        [15.179.mm, 19.2.mm, 0],
        [15.835.mm, 19.735.mm, 0],
        [17.34.mm, 18.012.mm, 0],
        [17.213.mm, 15.088.mm, 0],
        [23.532.mm, 15.258.mm, 0],
        [23.658.mm, 31.406.mm, 0],
        [27.689.mm, 31.659.mm, 0],
        [27.693.mm, 28.837.mm, 0],
        [26.943.mm, 29.008.mm, 0],
        [26.712.mm, 30.686.mm, 0],
        [24.931.mm, 30.39.mm, 0],
        [24.931.mm, 23.097.mm, 0],
        [26.712.mm, 22.844.mm, 0],
        [27.412.mm, 24.762.mm, 0],
        [27.9.mm, 24.412.mm, 0],
        [27.9.mm, 22.124.mm, 0],
        [24.931.mm, 21.404.mm, 0],
        [24.846.mm, 0.0.mm, 0],
        [18.952.mm, 0.041.mm, 0],
        [19.036.mm, 2.799.mm, 0],
        [19.928.mm, 2.799.mm, 0],
        [19.928.mm, 1.018.mm, 0],
        [23.574.mm, 1.315.mm, 0],
        [23.617.mm, 13.265.mm, 0],
        [23.108.mm, 13.774.mm, 0],
        [4.492.mm, 13.689.mm, 0],
        [4.323.mm, 1.315.mm, 0],
        [7.969.mm, 1.018.mm, 0],
        [7.969.mm, 2.799.mm, 0],
        [8.861.mm, 2.799.mm, 0],
        [8.988.mm, 0.13.mm, 0],
        [3.008.mm, 0.13.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1401 Top Sash")
    end

    # 100% Exact Vector CAD from w_clean.dxf: 70S-1101-1 Bottom Frame (69.71mm x 29.96mm)
    def draw_70S_1101_1(entities, length_mm)
      pts = [
        [0.0.mm, 2.076.mm, 0],
        [0.215.mm, 9.916.mm, 0],
        [17.015.mm, 11.02.mm, 0],
        [17.301.mm, 19.07.mm, 0],
        [16.156.mm, 20.089.mm, 0],
        [15.944.mm, 21.316.mm, 0],
        [17.344.mm, 22.886.mm, 0],
        [18.828.mm, 22.759.mm, 0],
        [19.846.mm, 21.57.mm, 0],
        [19.72.mm, 20.089.mm, 0],
        [18.575.mm, 19.07.mm, 0],
        [18.575.mm, 11.823.mm, 0],
        [19.378.mm, 10.85.mm, 0],
        [50.42.mm, 12.162.mm, 0],
        [51.139.mm, 12.927.mm, 0],
        [51.139.mm, 19.07.mm, 0],
        [49.994.mm, 20.089.mm, 0],
        [49.824.mm, 21.316.mm, 0],
        [50.409.mm, 22.414.mm, 0],
        [51.817.mm, 22.97.mm, 0],
        [53.216.mm, 22.378.mm, 0],
        [53.811.mm, 20.978.mm, 0],
        [53.439.mm, 19.826.mm, 0],
        [52.454.mm, 19.07.mm, 0],
        [52.744.mm, 12.544.mm, 0],
        [67.888.mm, 12.97.mm, 0],
        [68.44.mm, 13.859.mm, 0],
        [68.44.mm, 28.648.mm, 0],
        [67.083.mm, 28.733.mm, 0],
        [66.744.mm, 29.498.mm, 0],
        [67.379.mm, 29.964.mm, 0],
        [69.711.mm, 29.625.mm, 0],
        [69.372.mm, 0.0.mm, 0],
        [63.776.mm, 0.0.mm, 0],
        [63.776.mm, 1.23.mm, 0],
        [67.675.mm, 1.272.mm, 0],
        [68.397.mm, 2.034.mm, 0],
        [68.44.mm, 10.554.mm, 0],
        [67.633.mm, 11.57.mm, 0],
        [54.955.mm, 11.02.mm, 0],
        [55.124.mm, 7.797.mm, 0],
        [53.667.mm, 6.26.mm, 0],
        [53.005.mm, 6.992.mm, 0],
        [53.715.mm, 8.307.mm, 0],
        [53.571.mm, 9.817.mm, 0],
        [52.116.mm, 10.892.mm, 0],
        [50.736.mm, 10.594.mm, 0],
        [50.03.mm, 9.831.mm, 0],
        [49.883.mm, 8.36.mm, 0],
        [50.589.mm, 6.865.mm, 0],
        [49.947.mm, 6.255.mm, 0],
        [48.594.mm, 7.5.mm, 0],
        [48.424.mm, 10.765.mm, 0],
        [21.117.mm, 9.577.mm, 0],
        [21.289.mm, 6.442.mm, 0],
        [19.769.mm, 4.806.mm, 0],
        [19.153.mm, 5.447.mm, 0],
        [19.83.mm, 6.849.mm, 0],
        [19.72.mm, 8.392.mm, 0],
        [18.236.mm, 9.451.mm, 0],
        [16.166.mm, 8.359.mm, 0],
        [16.034.mm, 6.86.mm, 0],
        [16.709.mm, 5.297.mm, 0],
        [16.097.mm, 4.813.mm, 0],
        [15.182.mm, 5.297.mm, 0],
        [14.545.mm, 6.569.mm, 0],
        [14.46.mm, 9.324.mm, 0],
        [2.038.mm, 8.772.mm, 0],
        [1.316.mm, 8.009.mm, 0],
        [1.4.mm, 1.864.mm, 0],
        [2.079.mm, 1.314.mm, 0],
        [5.979.mm, 1.314.mm, 0],
        [5.979.mm, 0.0.mm, 0],
        [0.342.mm, 0.0.mm, 0],
        [0.0.mm, 2.034.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1101-1 Bottom Frame")
    end

    # 100% Exact Vector CAD: 70S-1501 Bottom Sash (21.92mm x 56.11mm)
    # Bottom legs trimmed by 3.0mm from bottom to avoid hitting the bottom track center guide ridge
    def draw_70S_1501(entities, length_mm)
      pts = [
        [0.0.mm, 5.001.mm, 0],
        [0.0.mm, 56.114.mm, 0],
        [5.979.mm, 56.114.mm, 0],
        [5.979.mm, 53.105.mm, 0],
        [5.004.mm, 53.105.mm, 0],
        [4.495.mm, 54.84.mm, 0],
        [1.357.mm, 54.587.mm, 0],
        [1.273.mm, 46.917.mm, 0],
        [1.78.mm, 46.408.mm, 0],
        [20.27.mm, 46.451.mm, 0],
        [20.608.mm, 54.46.mm, 0],
        [17.258.mm, 54.799.mm, 0],
        [16.919.mm, 53.105.mm, 0],
        [15.944.mm, 53.105.mm, 0],
        [15.944.mm, 56.114.mm, 0],
        [21.923.mm, 56.114.mm, 0],
        [21.923.mm, 3.000.mm, 0],
        [20.608.mm, 3.000.mm, 0],
        [20.608.mm, 5.001.mm, 0],
        [18.659.mm, 5.001.mm, 0],
        [18.659.mm, 5.975.mm, 0],
        [20.608.mm, 5.975.mm, 0],
        [20.608.mm, 44.797.mm, 0],
        [20.1.mm, 45.136.mm, 0],
        [14.205.mm, 45.093.mm, 0],
        [14.417.mm, 42.551.mm, 0],
        [13.198.mm, 40.527.mm, 0],
        [12.255.mm, 40.855.mm, 0],
        [12.93.mm, 43.17.mm, 0],
        [11.576.mm, 45.01.mm, 0],
        [10.253.mm, 44.978.mm, 0],
        [9.166.mm, 43.981.mm, 0],
        [9.05.mm, 42.577.mm, 0],
        [9.752.mm, 41.194.mm, 0],
        [9.091.mm, 40.496.mm, 0],
        [7.59.mm, 42.169.mm, 0],
        [7.675.mm, 45.093.mm, 0],
        [1.357.mm, 44.924.mm, 0],
        [1.273.mm, 5.975.mm, 0],
        [3.307.mm, 5.975.mm, 0],
        [3.307.mm, 5.001.mm, 0],
        [1.273.mm, 5.001.mm, 0],
        [1.273.mm, 3.000.mm, 0],
        [0.0.mm, 3.000.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1501 Bottom Sash")
    end

    # 100% Exact Vector CAD from w_clean.dxf: 70S-1201-1 Side Jamb (72.68mm x 24.96mm)
    def draw_70S_1201_1(entities, length_mm)
      pts = [
        [0.0.mm, 3.307.mm, 0],
        [0.299.mm, 24.963.mm, 0],
        [5.938.mm, 24.963.mm, 0],
        [5.938.mm, 23.693.mm, 0],
        [2.249.mm, 23.693.mm, 0],
        [1.274.mm, 22.928.mm, 0],
        [1.274.mm, 5.595.mm, 0],
        [2.249.mm, 4.791.mm, 0],
        [32.27.mm, 4.834.mm, 0],
        [33.035.mm, 5.595.mm, 0],
        [33.076.mm, 13.054.mm, 0],
        [36.046.mm, 13.393.mm, 0],
        [36.383.mm, 16.784.mm, 0],
        [70.603.mm, 16.827.mm, 0],
        [71.409.mm, 17.8.mm, 0],
        [71.282.mm, 23.14.mm, 0],
        [70.391.mm, 23.693.mm, 0],
        [66.703.mm, 23.693.mm, 0],
        [66.703.mm, 24.963.mm, 0],
        [72.679.mm, 24.667.mm, 0],
        [72.679.mm, 0.0.mm, 0],
        [71.409.mm, 0.0.mm, 0],
        [71.409.mm, 14.496.mm, 0],
        [70.391.mm, 15.513.mm, 0],
        [37.868.mm, 15.385.mm, 0],
        [37.318.mm, 14.496.mm, 0],
        [37.318.mm, 10.469.mm, 0],
        [36.342.mm, 10.469.mm, 0],
        [36.342.mm, 12.123.mm, 0],
        [34.349.mm, 12.123.mm, 0],
        [34.349.mm, 4.791.mm, 0],
        [36.342.mm, 4.791.mm, 0],
        [36.342.mm, 6.485.mm, 0],
        [37.318.mm, 6.485.mm, 0],
        [37.318.mm, 3.857.mm, 0],
        [36.808.mm, 3.518.mm, 0],
        [2.038.mm, 3.518.mm, 0],
        [1.274.mm, 2.756.mm, 0],
        [1.274.mm, 0.0.mm, 0],
        [0.0.mm, 0.0.mm, 0],
        [0.0.mm, 3.138.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S-1201-1 Side Jamb")
    end

    def extrude_hollow_profile(entities, outer_points, inner_loops = [], length_mm = 1000.0, name = "Hollow Profile")
      clean_outer = outer_points.map { |p| Geom::Point3d.new(p[0], p[1], p[2] || 0) }
      if clean_outer.length > 1 && clean_outer.first.distance(clean_outer.last) < 0.001.mm
        clean_outer.pop
      end

      group = entities.add_group
      group.name = name

      # 1. Add outer face
      outer_face = group.entities.add_face(clean_outer)
      return group unless outer_face&.valid?

      # 2. Add inner void faces
      inner_faces_to_erase = []
      inner_loops.each do |loop_pts|
        clean_inner = loop_pts.map { |p| Geom::Point3d.new(p[0], p[1], p[2] || 0) }
        if clean_inner.length > 1 && clean_inner.first.distance(clean_inner.last) < 0.001.mm
          clean_inner.pop
        end
        in_face = group.entities.add_face(clean_inner)
        inner_faces_to_erase << in_face if in_face&.valid?
      end

      # Erase inner faces to leave hollow chamber
      inner_faces_to_erase.each { |f| f.erase! if f&.valid? }

      # 3. Pushpull remaining face(s)
      faces = group.entities.grep(Sketchup::Face)
      faces.each do |f|
        if f&.valid?
          f.reverse! if f.normal.z < 0
          f.pushpull(length_mm.mm)
        end
      end

      group
    end

    # Exact Vector CAD from w_clean.dxf: 70S-1701 Side / Handle Sash Stile (29.90mm x 25.98mm with 10mm Glazing Mouth)
    def draw_70S_1701(entities, length_mm)
      outer_pts = [
        [1.020.mm,  2.077.mm, 0],
        [1.020.mm,  7.884.mm, 0],
        [3.519.mm,  8.011.mm, 0],
        [3.988.mm,  7.884.mm, 0],
        [3.988.mm,  6.696.mm, 0],
        [2.292.mm,  6.696.mm, 0],
        [2.673.mm,  1.527.mm, 0],
        [9.922.mm,  1.315.mm, 0],
        [10.590.mm, 1.939.mm, 0],
        [10.687.mm, 23.693.mm, 0],
        [9.922.mm, 24.667.mm, 0],
        [2.841.mm, 24.582.mm, 0],
        [2.292.mm, 23.693.mm, 0],
        [2.292.mm, 19.286.mm, 0],
        [3.988.mm, 19.286.mm, 0],
        [3.988.mm, 18.096.mm, 0],
        [1.230.mm, 18.012.mm, 0],
        [1.020.mm, 25.006.mm, 0],
        [0.000.mm, 25.006.mm, 0],
        [0.000.mm, 25.982.mm, 0],
        [29.895.mm, 25.982.mm, 0],
        [29.895.mm,  0.000.mm, 0],
        [0.000.mm,  0.000.mm, 0],
        [0.000.mm,  1.019.mm, 0],
        [1.020.mm,  1.019.mm, 0],
        [1.020.mm,  1.864.mm, 0]
      ]
      inner_void = [
        [12.0.mm,  1.3.mm, 0],
        [28.6.mm,  1.3.mm, 0],
        [28.6.mm, 24.7.mm, 0],
        [12.0.mm, 24.7.mm, 0]
      ]
      extrude_hollow_profile(entities, outer_pts, [inner_void], length_mm, "70S-1701 Side Sash Stile")
    end

    # Exact Vector CAD from Catalog: 70S-1601 Interlock Stile (30.0mm x 32.0mm with 10mm Glazing Mouth & 6mm Interlock Hook)
    def draw_70S_1601(entities, length_mm)
      outer_pts = [
        [1.020.mm,  2.077.mm, 0],
        [1.020.mm,  7.884.mm, 0],
        [3.519.mm,  8.011.mm, 0],
        [3.988.mm,  7.884.mm, 0],
        [3.988.mm,  6.696.mm, 0],
        [2.292.mm,  6.696.mm, 0],
        [2.673.mm,  1.527.mm, 0],
        [9.922.mm,  1.315.mm, 0],
        [10.590.mm, 1.939.mm, 0],
        [10.687.mm, 23.693.mm, 0],
        [9.922.mm, 24.667.mm, 0],
        [2.841.mm, 24.582.mm, 0],
        [2.292.mm, 23.693.mm, 0],
        [2.292.mm, 19.286.mm, 0],
        [3.988.mm, 19.286.mm, 0],
        [3.988.mm, 18.096.mm, 0],
        [1.230.mm, 18.012.mm, 0],
        [1.020.mm, 25.006.mm, 0],
        [0.000.mm, 25.006.mm, 0],
        [0.000.mm, 25.982.mm, 0],
        # Inward Interlock Hook: Stem at X=12.0..13.3mm, Lip extending along +X to 20.0mm at Y=32.0mm:
        [12.000.mm, 25.982.mm, 0],
        [12.000.mm, 32.000.mm, 0],
        [20.000.mm, 32.000.mm, 0],
        [20.000.mm, 30.700.mm, 0],
        [13.300.mm, 30.700.mm, 0],
        [13.300.mm, 25.982.mm, 0],
        [29.895.mm, 25.982.mm, 0],
        [29.895.mm,  0.000.mm, 0],
        [0.000.mm,  0.000.mm, 0],
        [0.000.mm,  1.019.mm, 0],
        [1.020.mm,  1.019.mm, 0],
        [1.020.mm,  1.864.mm, 0]
      ]
      inner_void = [
        [12.0.mm,  1.3.mm, 0],
        [28.6.mm,  1.3.mm, 0],
        [28.6.mm, 24.7.mm, 0],
        [12.0.mm, 24.7.mm, 0]
      ]
      extrude_hollow_profile(entities, outer_pts, [inner_void], length_mm, "70S-1601 Interlock Stile")
    end

    # Dedicated Single Bar Function: 70S-1601
    def bar_70S_1601(entities = nil, length_mm = 1000.0)
      model = Sketchup.active_model
      ents = entities || model.active_entities
      model.start_operation('Draw 70S-1601 Bar', true)

      prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70S-1601/i }
      model.active_entities.erase_entities(prev) unless prev.empty?

      bar = draw_70S_1601(ents, length_mm)
      bar.name = format('70S-1601 Interlock Bar (%.0fmm)', length_mm)

      model.selection.clear
      model.selection.add(bar)
      model.commit_operation
      model.active_view.zoom(bar)
      puts "=> [70S-1601] Bar generated successfully! (Length: #{length_mm}mm)"
      bar
    end

    def bar_70S_1601_interactive
      prompts = ['Bar Length (mm)']
      defaults = [1000.0]
      values = UI.inputbox(prompts, defaults, '70S-1601 Interlock Bar Generator')
      return unless values

      l = values[0].to_f
      bar_70S_1601(nil, l)
    end

    # Preview all 8 profiles and roller side-by-side in 3D
    def preview_all_profiles(entities = nil, length_mm = 500.0)
      model = Sketchup.active_model
      ents = entities || model.active_entities
      model.start_operation('Preview All 70S Profiles', true)

      root = ents.add_group
      root.name = "All 70S Aluminium Bar Profiles"

      # 1. 70S-1001-1 Top Track Head (69.7mm x 32mm)
      g1 = draw_70S_1001_1(root.entities, length_mm)
      g1.transform!(Geom::Transformation.translation([0.mm, 0, 0]))

      # 2. 70S-1101-1 Bottom Track Sill (69.7mm x 30mm)
      g2 = draw_70S_1101_1(root.entities, length_mm)
      g2.transform!(Geom::Transformation.translation([100.mm, 0, 0]))

      # 3. 70S-1201-1 Side Jamb (72.7mm x 25mm)
      g3 = draw_70S_1201_1(root.entities, length_mm)
      g3.transform!(Geom::Transformation.translation([200.mm, 0, 0]))

      # 4. 70S-1401 Top Sash Rail (27.9mm x 31.7mm)
      g4 = draw_70S_1401(root.entities, length_mm)
      g4.transform!(Geom::Transformation.translation([300.mm, 0, 0]))

      # 5. 70S-1501 Bottom Sash Rail (21.9mm x 56.1mm)
      g5 = draw_70S_1501(root.entities, length_mm)
      g5.transform!(Geom::Transformation.translation([380.mm, 0, 0]))

      # 6. 70S-1601 Interlock Sash Stile (30mm x 32mm with 10mm mouth & hook)
      g6 = draw_70S_1601(root.entities, length_mm)
      g6.transform!(Geom::Transformation.translation([460.mm, 0, 0]))

      # 7. 70S-1701 Handle / Side Sash Stile (30mm x 26mm with 10mm mouth)
      g7 = draw_70S_1701(root.entities, length_mm)
      g7.transform!(Geom::Transformation.translation([540.mm, 0, 0]))

      # 8. 70S-1801 Glazing Bead
      g8 = draw_glazing_bead(root.entities, length_mm)
      g8.transform!(Geom::Transformation.translation([600.mm, 0, 0]))

      # 9. 70S-1914 Roller Carriage & V-Groove Wheel
      if defined?(AluDoorPilot::Hardware70S)
        g9 = AluDoorPilot::Hardware70S.draw_v_groove_roller(root.entities)
        g9.transform!(Geom::Transformation.translation([660.mm, 200.mm, 0]))
      end

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      puts "=> Drawn all 8 Aluminium Bar Profiles + Roller side-by-side (500mm extrusions)."
      root
    end
    alias_method :draw_all_profiles, :preview_all_profiles

    # =========================================================================
    # FROZEN FUNCTION: SIDE 70S-1201-1 (Left and Right Side Upright Columns)
    # Permanent Reference:
    # - Left Upright:  Position 1 (Y=0), flat back at bottom, flanges face DOWNWARD
    # - Right Upright: Position 2 (Y=width_mm), flat back at top, flanges face UPWARD
    # =========================================================================
    def side_70S_1201_1(entities = nil, length_mm = 2100.0, width_mm = 1000.0)
      model = Sketchup.active_model
      ents = entities || model.active_entities
      model.start_operation('SIDE 70S-1201-1', true)

      root = ents.add_group
      root.name = "SIDE 70S-1201-1"

      # Left Side Upright (Position 1, Y = 0)
      left_upright = draw_70S_1201_1(root.entities, length_mm)
      left_upright.name = "70S-1201-1 Left Upright"
      left_upright.transform!(
        Geom::Transformation.translation([0, 0, 0]) *
        Geom::Transformation.scaling(1.0, -1.0, 1.0)
      )

      # Right Side Upright (Position 2, Y = width_mm)
      right_upright = draw_70S_1201_1(root.entities, length_mm)
      right_upright.name = "70S-1201-1 Right Upright"
      right_upright.transform!(Geom::Transformation.translation([0, width_mm.mm, 0]))

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      puts "=> [SIDE 70S-1201-1] Rendered Left and Right Uprights (Length: #{length_mm}mm, Width: #{width_mm}mm)"
      root
    end

    def side_70S_1201_1_interactive
      prompts = ['Upright Height (mm)', 'Opening Width (mm)']
      defaults = [2100.0, 1000.0]
      values = UI.inputbox(prompts, defaults, 'SIDE 70S-1201-1 Generator')
      return unless values

      h, w = values.map(&:to_f)
      model = Sketchup.active_model

      # Clean up any previous test uprights
      prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /SIDE 70S-1201-1/i }
      model.active_entities.erase_entities(prev) unless prev.empty?

      side_70S_1201_1(nil, h, w)
    end

    # Exact Notch Cut from User Specification (Bridges all gaps 100% flush):
    # - Extruded track length = width_mm + 24mm (starts at Y = -12mm, ends at Y = width_mm + 12mm)
    # - Left Notch: Cuts X = -5mm..37mm from Y = -20mm to Y = 0.0mm
    # - Right Notch: Cuts X = -5mm..37mm from Y = width_mm to Y = width_mm + 20mm
    # =========================================================================
    # EXACT PARAMETRIC FORMULA FOR 70S OUTER WALL FRAME COPING
    # Formula Constants:
    # - TONGUE_DEPTH = 15.5 mm  (enters deep upright pocket)
    # - SHELF_DEPTH  =  3.5 mm  (enters shallow upright shelf)
    # - STEP_NOTCH   = 12.0 mm  (TONGUE_DEPTH - SHELF_DEPTH)
    # - X_SHIFT      =  2.0 mm  (aligns track flush with outer upright flange)
    # =========================================================================
    def notch_horizontal_track(track_group, width_mm)
      parent = track_group.parent.entities
      bb = track_group.bounds
      z_bot = bb.min.z - 5.0.mm
      z_height = (bb.max.z - bb.min.z) + 10.0.mm

      # 1. Left End Cutter Box: Spans full profile Z-height at its actual elevation
      cutter1 = parent.add_group
      p1 = [
        [-5.0.mm, -30.0.mm, z_bot],
        [39.0.mm, -30.0.mm, z_bot],
        [39.0.mm, -3.5.mm, z_bot],
        [-5.0.mm, -3.5.mm, z_bot]
      ]
      f1 = cutter1.entities.add_face(p1)
      f1.pushpull(z_height) if f1

      if cutter1.respond_to?(:subtract) && cutter1.manifold? && track_group.manifold?
        res1 = cutter1.subtract(track_group)
        track_group = res1 if res1&.valid?
      else
        track_group.entities.intersect_with(true, IDENTITY, track_group.entities, IDENTITY, false, cutter1.entities.to_a)
        cutter1.erase! if cutter1.valid?
      end

      # 2. Right End Cutter Box: Spans full profile Z-height at its actual elevation
      cutter2 = parent.add_group
      p2 = [
        [-5.0.mm, (width_mm + 3.5).mm, z_bot],
        [39.0.mm, (width_mm + 3.5).mm, z_bot],
        [39.0.mm, (width_mm + 30.0).mm, z_bot],
        [-5.0.mm, (width_mm + 30.0).mm, z_bot]
      ]
      f2 = cutter2.entities.add_face(p2)
      f2.pushpull(z_height) if f2

      if cutter2.respond_to?(:subtract) && cutter2.manifold? && track_group.manifold?
        res2 = cutter2.subtract(track_group)
        track_group = res2 if res2&.valid?
      else
        track_group.entities.intersect_with(true, IDENTITY, track_group.entities, IDENTITY, false, cutter2.entities.to_a)
        cutter2.erase! if cutter2.valid?
      end

      track_group
    end

    # Drill a cylindrical screw pass-through hole through the upright jamb
    def drill_screw_hole(group, x_mm, y_start_mm, z_mm, depth_mm = 35.0, dir_y = 1, radius_mm = 2.4)
      parent = group.parent.entities
      cutter = parent.add_group
      normal = Geom::Vector3d.new(0, dir_y, 0)
      start_pt = Geom::Point3d.new(x_mm.mm, y_start_mm.mm, z_mm.mm)
      edges = cutter.entities.add_circle(start_pt, normal, radius_mm.mm, 16)
      face = cutter.entities.add_face(edges)
      face.pushpull(depth_mm.mm) if face&.valid?

      if cutter.respond_to?(:subtract) && cutter.manifold? && group.manifold?
        res = cutter.subtract(group)
        group = res if res&.valid?
      else
        group.entities.intersect_with(true, IDENTITY, group.entities, IDENTITY, false, cutter.entities.to_a)
        cutter.erase! if cutter.valid?
      end
      group
    end

    # =========================================================================
    # 4-SIDED OUTER WALL FRAME BUILDER
    # Uses:
    # 1. Left & Right frozen upright jambs (SIDE 70S-1201-1) with drilled screw holes
    # 2. Top Track Head (70S-1001-1) with Parametric Coping Formula
    # 3. Bottom Track Sill (70S-1101-1) with Parametric Coping Formula
    # 4. ST Assembly Fastener Screws passing through side jambs into C-grooves
    # =========================================================================
    def build_outer_wall_frame(entities = nil, height_mm = 2100.0, width_mm = 1000.0)

      model = Sketchup.active_model
      ents = entities || model.active_entities
      model.start_operation('Build 70S Outer Wall Frame', true)

      root = ents.add_group
      root.name = format('70 mm Outer Wall Frame %.0f x %.0f', width_mm, height_mm)

      # 1. Left & Right Side Uprights (Frozen exact transformations)
      left_upright = draw_70S_1201_1(root.entities, height_mm)
      left_upright.name = "70S-1201-1 Left Upright"
      left_upright.transform!(
        Geom::Transformation.translation([0, 0, 0]) *
        Geom::Transformation.scaling(1.0, -1.0, 1.0)
      )

      right_upright = draw_70S_1201_1(root.entities, height_mm)
      right_upright.name = "70S-1201-1 Right Upright"
      right_upright.transform!(Geom::Transformation.translation([0, width_mm.mm, 0]))

      # Drill 4 screw pass-through holes on Left Upright (from Y = -30mm to Y = +5mm)
      left_upright = drill_screw_hole(left_upright, 19.94, -30.0, height_mm - 5.0, 35.0, 1)
      left_upright = drill_screw_hole(left_upright, 53.73, -30.0, height_mm - 5.0, 35.0, 1)
      left_upright = drill_screw_hole(left_upright, 20.00, -30.0, 7.0, 35.0, 1)
      left_upright = drill_screw_hole(left_upright, 53.50, -30.0, 9.0, 35.0, 1)

      # Drill 4 screw pass-through holes on Right Upright (from Y = width_mm + 30mm to Y = width_mm - 5mm)
      right_upright = drill_screw_hole(right_upright, 19.94, width_mm + 30.0, height_mm - 5.0, 35.0, -1)
      right_upright = drill_screw_hole(right_upright, 53.73, width_mm + 30.0, height_mm - 5.0, 35.0, -1)
      right_upright = drill_screw_hole(right_upright, 20.00, width_mm + 30.0, 7.0, 35.0, -1)
      right_upright = drill_screw_hole(right_upright, 53.50, width_mm + 30.0, 9.0, 35.0, -1)

      # Full track length: Tongue extension of 15.5mm on each side (width + 31.0mm)
      track_w_full = width_mm + 31.0

      # 2. Bottom Track Sill (70S-1101-1) shifted +2.0mm in X, bridging into pockets at Z = 0
      bot_sill = draw_70S_1101_1(root.entities, track_w_full)
      bot_sill.transform!(Geom::Transformation.new([
        1, 0, 0, 0,
        0, 0, 1, 0,
        0, 1, 0, 0,
        2.0.mm, -15.5.mm, 0, 1
      ]))
      bot_sill = notch_horizontal_track(bot_sill, width_mm)
      bot_sill.name = "70S-1101-1 Bottom Track Sill (Parametric Coping)"

      # 3. Top Track Head (70S-1001-1) shifted +2.0mm in X, bridging into pockets at Z = height_mm - 32mm
      top_head = draw_70S_1001_1(root.entities, track_w_full)
      top_head.transform!(Geom::Transformation.new([
        1, 0, 0, 0,
        0, 0, 1, 0,
        0, 1, 0, 0,
        2.0.mm, -15.5.mm, (height_mm - 32.0).mm, 1
      ]))
      top_head = notch_horizontal_track(top_head, width_mm)
      top_head.name = "70S-1001-1 Top Track Head (Parametric Coping)"

      # 4. Corner Fastener Screws (Positioned on outer jamb face and driving through into C-grooves)
      if defined?(AluDoorPilot::Hardware70S)
        rot_left_screws = Geom::Transformation.rotation(ORIGIN, X_AXIS, -90.degrees) # drives +Y into track
        rot_right_screws = Geom::Transformation.rotation(ORIGIN, X_AXIS, 90.degrees)  # drives -Y into track
        outer_jamb_thick = 24.96.mm

        # Top Left Screws (Lifted +2mm to height_mm - 5mm)
        s1 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s1.transform!(Geom::Transformation.translation([19.94.mm, -outer_jamb_thick, (height_mm - 5.0).mm]) * rot_left_screws)
        s2 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s2.transform!(Geom::Transformation.translation([53.73.mm, -outer_jamb_thick, (height_mm - 5.0).mm]) * rot_left_screws)

        # Top Right Screws (Lifted +2mm to height_mm - 5mm)
        s3 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s3.transform!(Geom::Transformation.translation([19.94.mm, width_mm.mm + outer_jamb_thick, (height_mm - 5.0).mm]) * rot_right_screws)
        s4 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s4.transform!(Geom::Transformation.translation([53.73.mm, width_mm.mm + outer_jamb_thick, (height_mm - 5.0).mm]) * rot_right_screws)

        # Bottom Left Screws (Flat side at 7mm, Slanted side lifted +2mm to 9mm)
        s5 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s5.transform!(Geom::Transformation.translation([20.0.mm, -outer_jamb_thick, 7.0.mm]) * rot_left_screws)
        s6 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s6.transform!(Geom::Transformation.translation([53.5.mm, -outer_jamb_thick, 9.0.mm]) * rot_left_screws)

        # Bottom Right Screws (Flat side at 7mm, Slanted side lifted +2mm to 9mm)
        s7 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s7.transform!(Geom::Transformation.translation([20.0.mm, width_mm.mm + outer_jamb_thick, 7.0.mm]) * rot_right_screws)
        s8 = AluDoorPilot::Hardware70S.draw_st_screw(root.entities, 38.0)
        s8.transform!(Geom::Transformation.translation([53.5.mm, width_mm.mm + outer_jamb_thick, 9.0.mm]) * rot_right_screws)
      end

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      puts "=> [Outer Wall Frame] Generated successfully! (#{width_mm}mm W x #{height_mm}mm H)"
      root
    end

    def build_outer_wall_frame_interactive
      prompts = ['Overall Frame Height (mm)', 'Overall Frame Width (mm)']
      defaults = [2100.0, 1500.0]
      values = UI.inputbox(prompts, defaults, '70S Outer Wall Frame')
      return unless values

      h, w = values.map(&:to_f)
      model = Sketchup.active_model
      prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70\s*mm|70S|Aluminium|Profile|Door|Frame|Slider/i }
      model.active_entities.erase_entities(prev) unless prev.empty?

      build_outer_wall_frame(nil, h, w)
    end

    # =========================================================================
    # FROZEN FUNCTION: frame_70mm (70mm Outer Wall Frame)
    # Never change. Assembles:
    # 1. Left & Right frozen upright jambs (side_70S_1201_1)
    # 2. Top Track Head (70S-1001-1) with Parametric Coping
    # 3. Bottom Track Sill (70S-1101-1) with Parametric Coping
    # 4. Corner Fastener Screws
    # =========================================================================
    def frame_70mm(entities = nil, height_mm = 2100.0, width_mm = 1000.0)
      build_outer_wall_frame(entities, height_mm, width_mm)
    end

    def frame_70mm_interactive
      build_outer_wall_frame_interactive
    end

    # =========================================================================
    # 3D GLASS PANEL & GLAZING BEAD BUILDERS
    # =========================================================================
    def draw_glass_panel(entities, width_mm, height_mm, thickness_mm = 6.0)
      group = entities.add_group
      group.name = format('Safety Glass %.0fx%.0fx%.1fmm', width_mm, height_mm, thickness_mm)
      t_half = thickness_mm / 2.0
      pts = [
        [-t_half.mm, 0, 0],
        [t_half.mm, 0, 0],
        [t_half.mm, width_mm.mm, 0],
        [-t_half.mm, width_mm.mm, 0]
      ]
      face = group.entities.add_face(pts)
      if face&.valid?
        face.reverse! if face.normal.z < 0 # Guarantees upward (+Z) pushpull into the door frame!
        face.pushpull(height_mm.mm)
      end

      mat = Sketchup.active_model.materials['ALU Clear Glass'] || Sketchup.active_model.materials.add('ALU Clear Glass')
      mat.color = Sketchup::Color.new(205, 235, 250)
      mat.alpha = 0.45
      group.material = mat
      group
    end

    def draw_glazing_bead(entities, length_mm)
      group = entities.add_group
      group.name = "70S-1801 Glazing Bead"
      pts = [
        [0, 0, 0],
        [5.0.mm, 0, 0],
        [5.0.mm, 10.0.mm, 0],
        [2.0.mm, 10.0.mm, 0],
        [0, 6.0.mm, 0]
      ]
      face = group.entities.add_face(pts)
      face.pushpull(length_mm.mm) if face&.valid?
      group
    end

    # =========================================================================
    # SLIDING DOOR SASH LEAF BUILDER (70S Series) - 100% CAD Vector Accurate
    # Structure:
    # 1. Bottom Sash Rail (70S-1501): 10mm mouth facing UP (+Z), bottom chamber facing DOWN (-Z)
    # 2. Top Sash Rail (70S-1401): 10mm mouth facing DOWN (-Z), top guide facing UP (+Z)
    # 3. Left & Right Stiles (70S-1701 / 70S-1601): 10mm mouth facing INWARD towards glass
    # 4. ALL 4 BARS Co-planar centered at track_x_mm
    # 5. Rollers (70S-1914): Facing DOWN, wheel riding track bead, bracket hidden inside rail
    # 6. Safety Glass: Centered at track_x_mm, seated 10mm into all 4 perimeter grooves
    # 7. Fastener Assembly Screws & Drilled Stile Holes
    # =========================================================================
    def build_sliding_sash_leaf(entities, leaf_w_mm, leaf_h_mm, track_x_mm, start_y_mm, is_outer_leaf = true)
      group = entities.add_group
      group.name = is_outer_leaf ? "Outer Sliding Door Leaf (Track 1)" : "Inner Sliding Door Leaf (Track 2)"

      rail_len = leaf_w_mm - 60.0 # Rail cut length between 30mm left & right stiles

      # 1. Bottom Sash Rail (70S-1501)
      # Y=56.11 (10mm glass mouth) faces UP (+Z), Y=0 (roller pocket) faces DOWN (-Z)
      # Centered at track_x_mm (X center = 10.96mm)
      bot_rail = draw_70S_1501(group.entities, rail_len)
      bot_rail.name = "70S-1501 Bottom Sash Rail"
      bot_rail.transform!(Geom::Transformation.new([
        1, 0, 0, 0,
        0, 0, 1, 0,
        0, 1, 0, 0,
        (track_x_mm - 10.96).mm, (start_y_mm + 30.0).mm, 12.0.mm, 1
      ]))

      # 2. Top Sash Rail (70S-1401)
      # Y=0 (10mm glass mouth) faces DOWN (-Z), Y=31.66 (top guide) faces UP (+Z)
      # Centered at track_x_mm (X center = 13.95mm)
      top_rail = draw_70S_1401(group.entities, rail_len)
      top_rail.name = "70S-1401 Top Sash Rail"
      top_rail.transform!(Geom::Transformation.new([
        1, 0, 0, 0,
        0, 0, 1, 0,
        0, 1, 0, 0,
        (track_x_mm - 13.95).mm, (start_y_mm + 30.0).mm, (12.0 + leaf_h_mm - 31.66).mm, 1
      ]))

      # Exact Screw Z-Elevations (Aligned with C-Channels):
      screw_bot_z = 55.0.mm                 # Lowered by 2mm (57mm -> 55mm) to match 70S-1501 C-channel
      screw_top_z = (12.0 + leaf_h_mm - 13.0).mm # Raised by 12mm (-25mm -> -13mm) to match 70S-1401 C-channel

      # 3. Left Stile (Full Height, Z = 12.0mm to 12.0 + leaf_h_mm)
      # 10mm glass mouth (X=0) points INWARD (+Y) towards the glass!
      if is_outer_leaf
        # Track 1 Left: 70S-1701 Handle Stile (flat back faces -Y to wall jamb)
        left_stile = draw_70S_1701(group.entities, leaf_h_mm)
        left_stile.name = "70S-1701 Left Handle Stile"
        left_stile.transform!(Geom::Transformation.new([
          0, -1, 0, 0,
          1,  0, 0, 0,
          0,  0, 1, 0,
          (track_x_mm - 12.99).mm, (start_y_mm + 30.0).mm, 12.0.mm, 1
        ]))
      else
        # Track 2 Left: 70S-1601 Interlock Stile (hook faces -X INWARD into gap towards Track 1)
        left_stile = draw_70S_1601(group.entities, leaf_h_mm)
        left_stile.name = "70S-1601 Left Interlock Stile"
        left_stile.transform!(Geom::Transformation.new([
          0, -1, 0, 0,
         -1,  0, 0, 0,
          0,  0, 1, 0,
          (track_x_mm + 12.99).mm, (start_y_mm + 30.0).mm, 12.0.mm, 1
        ]))
      end
      # Drill screw pass-through holes through left stile
      left_stile = drill_screw_hole(left_stile, track_x_mm, start_y_mm - 10.0, 55.0, 45.0, 1, 2.4)
      left_stile = drill_screw_hole(left_stile, track_x_mm, start_y_mm - 10.0, 12.0 + leaf_h_mm - 13.0, 45.0, 1, 2.4)

      # 4. Right Stile (Full Height, Z = 12.0mm to 12.0 + leaf_h_mm)
      # 10mm glass mouth (X=0) points INWARD (-Y) towards the glass!
      if is_outer_leaf
        # Track 1 Right: 70S-1601 Interlock Stile (hook faces +X INWARD into gap towards Track 2)
        right_stile = draw_70S_1601(group.entities, leaf_h_mm)
        right_stile.name = "70S-1601 Right Interlock Stile"
        right_stile.transform!(Geom::Transformation.new([
          0, 1, 0, 0,
          1, 0, 0, 0,
          0, 0, 1, 0,
          (track_x_mm - 12.99).mm, (start_y_mm + leaf_w_mm - 30.0).mm, 12.0.mm, 1
        ]))
      else
        # Track 2 Right: 70S-1701 Handle Stile (flat back faces +Y to wall jamb)
        right_stile = draw_70S_1701(group.entities, leaf_h_mm)
        right_stile.name = "70S-1701 Right Handle Stile"
        right_stile.transform!(Geom::Transformation.new([
          0,  1, 0, 0,
         -1,  0, 0, 0,
          0,  0, 1, 0,
          (track_x_mm + 12.99).mm, (start_y_mm + leaf_w_mm - 30.0).mm, 12.0.mm, 1
        ]))
      end
      # Drill screw pass-through holes through right stile
      right_stile = drill_screw_hole(right_stile, track_x_mm, start_y_mm + leaf_w_mm + 10.0, 55.0, 45.0, -1, 2.4)
      right_stile = drill_screw_hole(right_stile, track_x_mm, start_y_mm + leaf_w_mm + 10.0, 12.0 + leaf_h_mm - 13.0, 45.0, -1, 2.4)

      # 5. 2x V-Groove Rollers (70S-1914): Facing DOWN, wheel resting on bead, housing concealed inside rail
      if defined?(AluDoorPilot::Hardware70S)
        bead_top_z = 22.8.mm # Track bead height on 70S-1101-1

        r1 = AluDoorPilot::Hardware70S.draw_v_groove_roller(group.entities)
        r1.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm + 80.0).mm, bead_top_z]))

        r2 = AluDoorPilot::Hardware70S.draw_v_groove_roller(group.entities)
        r2.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm + leaf_w_mm - 80.0).mm, bead_top_z]))
      end

      # 6. Safety Glass Panel (Enters 10mm into all 4 perimeter grooves in the exact mid-plane)
      glass_w = leaf_w_mm - 40.0
      glass_h = leaf_h_mm - 68.0
      glass = draw_glass_panel(group.entities, glass_w, glass_h, 6.0)
      glass.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm + 20.0).mm, 58.0.mm]))

      # 7. Sash Corner Assembly ST Fastener Screws
      if defined?(AluDoorPilot::Hardware70S)
        rot_s_left = Geom::Transformation.rotation(ORIGIN, X_AXIS, -90.degrees) # drives +Y
        rot_s_right = Geom::Transformation.rotation(ORIGIN, X_AXIS, 90.degrees)  # drives -Y

        # Bottom Left Screw (into 70S-1501 bottom screw port at Z = 55mm)
        sc1 = AluDoorPilot::Hardware70S.draw_st_screw(group.entities, 38.0)
        sc1.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm - 2.0).mm, screw_bot_z]) * rot_s_left)

        # Bottom Right Screw (into 70S-1501 bottom screw port at Z = 55mm)
        sc2 = AluDoorPilot::Hardware70S.draw_st_screw(group.entities, 38.0)
        sc2.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm + leaf_w_mm + 2.0).mm, screw_bot_z]) * rot_s_right)

        # Top Left Screw (into 70S-1401 top screw port at Z = leaf_h - 1mm)
        sc3 = AluDoorPilot::Hardware70S.draw_st_screw(group.entities, 38.0)
        sc3.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm - 2.0).mm, screw_top_z]) * rot_s_left)

        # Top Right Screw (into 70S-1401 top screw port at Z = leaf_h - 1mm)
        sc4 = AluDoorPilot::Hardware70S.draw_st_screw(group.entities, 38.0)
        sc4.transform!(Geom::Transformation.translation([track_x_mm.mm, (start_y_mm + leaf_w_mm + 2.0).mm, screw_top_z]) * rot_s_right)
      end

      group
    end

    # =========================================================================
    # COMPLETE 70S 2-TRACK SLIDING DOOR SYSTEM BUILDER
    # Generates:
    # 1. 4-Sided Outer Wall Frame (frame_70mm) with exact coping & screw holes
    # 2. Outer Sliding Leaf with V-Groove Rollers riding on Popsicle Rail 1
    # 3. Inner Sliding Leaf with V-Groove Rollers riding on Popsicle Rail 2
    # 4. Glass Units, Beading, Gaskets, and all Assembly Screws
    # =========================================================================
    def build_70s_sliding_door(entities = nil, height_mm = 2100.0, width_mm = 1500.0)
      model = Sketchup.active_model
      ents = entities || model.active_entities
      model.start_operation('Build Complete 70S Sliding Door', true)

      root = ents.add_group
      root.name = format('70 mm Complete 2-Track Sliding Door %.0fx%.0f', width_mm, height_mm)

      # 1. Outer Wall Frame
      build_outer_wall_frame(root.entities, height_mm, width_mm)

      # Door Leaf Sizing
      overlap_mm = 28.0
      leaf_w = (width_mm + overlap_mm) / 2.0
      leaf_h = height_mm - 28.0 # Enters top track 16mm, clears bottom track 12mm

      # 2. Leaf 1 (Outer Sliding Door on Track 1: X = 20.0mm)
      build_sliding_sash_leaf(root.entities, leaf_w, leaf_h, 20.0, 0.0, true)

      # 3. Leaf 2 (Inner Sliding Door on Track 2: X = 53.5mm)
      build_sliding_sash_leaf(root.entities, leaf_w, leaf_h, 53.5, width_mm - leaf_w, false)

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      puts "=> [Complete 70S Sliding Door] Generated successfully! (#{width_mm}mm W x #{height_mm}mm H with 2 Sashes, Glass, Beading & V-Rollers)"
      root
    end

    # Clear all entities in the workspace
    def clear_scene
      model = Sketchup.active_model
      model.start_operation('Clear Workspace', true)
      model.active_entities.clear!
      model.commit_operation
      puts "=> [Workspace Cleared] All entities removed."
    end

    def build_outer_wall_frame_interactive
      prompts = ['Overall Frame Height (mm)', 'Overall Frame Width (mm)']
      defaults = [2100.0, 1500.0]
      values = UI.inputbox(prompts, defaults, '70S Outer Wall Frame')
      return unless values

      h, w = values.map(&:to_f)
      model = Sketchup.active_model
      prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70\s*mm|70S|Aluminium|Profile|Door|Frame|Slider/i }
      model.active_entities.erase_entities(prev) unless prev.empty?

      build_outer_wall_frame(nil, h, w)
    end

    def build_70s_sliding_door_interactive
      prompts = ['Overall Frame Height (mm)', 'Overall Frame Width (mm)']
      defaults = [2100.0, 1500.0]
      values = UI.inputbox(prompts, defaults, '70S Complete Sliding Door System')
      return unless values

      h, w = values.map(&:to_f)
      model = Sketchup.active_model
      prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70\s*mm|70S|Aluminium|Profile|Door|Frame|Slider/i }
      model.active_entities.erase_entities(prev) unless prev.empty?

      build_70s_sliding_door(nil, h, w)
    end

    # =========================================================================
    # FUNCTION: sliders_70mm (Door Sliders ONLY without outer frame)
    # Generates:
    # 1. Outer Sliding Leaf with V-Groove Rollers (Track 1)
    # 2. Inner Sliding Leaf with V-Groove Rollers (Track 2)
    # 3. Glass Units, Beading, Gaskets, and Sash Corner Fastener Screws
    # =========================================================================
    def sliders_70mm(entities = nil, height_mm = 2100.0, width_mm = 1500.0)
      model = Sketchup.active_model
      ents = entities || model.active_entities
      model.start_operation('70S Door Sliders Only', true)

      root = ents.add_group
      root.name = format('70 mm Door Sliders Only %.0fx%.0f', width_mm, height_mm)

      overlap_mm = 28.0
      leaf_w = (width_mm + overlap_mm) / 2.0
      leaf_h = height_mm - 28.0 # Height of sash leaf (enters top track 16mm)

      # 1. Leaf 1 (Outer Sliding Door on Track 1: X = 20.0mm)
      build_sliding_sash_leaf(root.entities, leaf_w, leaf_h, 20.0, 0.0, true)

      # 2. Leaf 2 (Inner Sliding Door on Track 2: X = 53.5mm)
      build_sliding_sash_leaf(root.entities, leaf_w, leaf_h, 53.5, width_mm - leaf_w, false)

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)
      puts "=> [70S Door Sliders ONLY] Generated successfully! (#{width_mm}mm W x #{height_mm}mm H with 2 Sashes, Glass, Beading & V-Rollers)"
      root
    end

    def sliders_70mm_interactive
      prompts = ['Opening Height (mm)', 'Opening Width (mm)']
      defaults = [2100.0, 1500.0]
      values = UI.inputbox(prompts, defaults, '70S Door Sliders ONLY (Sashes + Glass + Rollers)')
      return unless values

      h, w = values.map(&:to_f)
      model = Sketchup.active_model
      prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70\s*mm|70S|Aluminium|Profile|Door|Frame|Slider/i }
      model.active_entities.erase_entities(prev) unless prev.empty?

      sliders_70mm(nil, h, w)
    end

    alias_method :side70S_1201_1, :side_70S_1201_1
    alias_method :side_70s_1201_1, :side_70S_1201_1
    alias_method :draw_side_70S_1201_1, :side_70S_1201_1
    alias_method :draw_opposite_facing_columns, :side_70S_1201_1
    alias_method :draw_two_jamb_bars, :side_70S_1201_1
    alias_method :draw_two_bars, :side_70S_1201_1
    alias_method :draw_columns, :side_70S_1201_1
    alias_method :draw_interchanged_columns, :side_70S_1201_1
    alias_method :outer_wall_frame, :build_outer_wall_frame
    alias_method :frame70mm, :frame_70mm
    alias_method :frame_70_mm, :frame_70mm
    alias_method :build_70mm_frame, :frame_70mm
    alias_method :door_70mm, :build_70s_sliding_door
    alias_method :door_unit_70mm, :build_70s_sliding_door
    alias_method :complete_door_70mm, :build_70s_sliding_door
    alias_method :door_sliders_70mm, :sliders_70mm
    alias_method :sliders70mm, :sliders_70mm
    alias_method :sashes_70mm, :sliders_70mm
    alias_method :full_system_70s, :build_70s_sliding_door
    alias_method :system_70s, :build_70s_sliding_door
    alias_method :clear_all, :clear_scene
  end
end
