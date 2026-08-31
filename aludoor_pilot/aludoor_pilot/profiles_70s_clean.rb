module AluDoorPilot
  module Profiles70SClean
    extend self

    def extrude_profile(entities, points, length_mm, name="Clean Profile")
      clean_pts = []
      points.each do |p|
        p_pt = Geom::Point3d.new(p[0], p[1], p[2])
        if clean_pts.empty? || clean_pts.last.distance(p_pt) > 0.001.mm
          clean_pts << p_pt
        end
      end
      group = entities.add_group
      group.name = name
      face = group.entities.add_face(clean_pts)
      if face&.valid?
        face.reverse! if face.normal.z < 0
        face.pushpull(length_mm.mm)
      end
      group
    end

    # Clean Outer Boundary Stencil: 70S_1001_1 (Width: 70.0mm)
    def draw_70S_1001_1(entities, length_mm)
      pts = [
        [0.0.mm, 31.86.mm, 0],
        [0.0.mm, 0.08.mm, 0],
        [2.12.mm, 23.7.mm, 0],
        [33.9.mm, 23.53.mm, 0],
        [34.32.mm, 0.08.mm, 0],
        [36.19.mm, 23.62.mm, 0],
        [68.13.mm, 23.62.mm, 0],
        [69.92.mm, 0.08.mm, 0],
        [69.75.mm, 32.11.mm, 0],
        [63.97.mm, 32.11.mm, 0],
        [68.47.mm, 30.41.mm, 0],
        [68.05.mm, 25.06.mm, 0],
        [55.47.mm, 25.06.mm, 0],
        [54.28.mm, 29.65.mm, 0],
        [52.5.mm, 25.06.mm, 0],
        [50.04.mm, 26.42.mm, 0],
        [50.29.mm, 29.65.mm, 0],
        [48.51.mm, 25.06.mm, 0],
        [21.49.mm, 25.06.mm, 0],
        [20.22.mm, 29.65.mm, 0],
        [18.52.mm, 25.06.mm, 0],
        [16.14.mm, 26.17.mm, 0],
        [16.31.mm, 29.65.mm, 0],
        [14.53.mm, 25.06.mm, 0],
        [1.95.mm, 25.06.mm, 0],
        [1.36.mm, 30.24.mm, 0],
        [5.95.mm, 32.11.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S_1001_1")
    end

    # Clean Outer Boundary Stencil: 70S_1401 (Width: 28.0mm)
    def draw_70S_1401(entities, length_mm)
      pts = [
        [0.34.mm, 32.06.mm, 0],
        [0.25.mm, 29.1.mm, 0],
        [1.35.mm, 31.05.mm, 0],
        [3.05.mm, 30.28.mm, 0],
        [2.96.mm, 23.35.mm, 0],
        [0.0.mm, 24.7.mm, 0],
        [0.08.mm, 22.25.mm, 0],
        [3.05.mm, 21.15.mm, 0],
        [3.05.mm, 0.25.mm, 0],
        [8.97.mm, 0.08.mm, 0],
        [8.88.mm, 3.13.mm, 0],
        [7.87.mm, 1.35.mm, 0],
        [4.31.mm, 1.69.mm, 0],
        [4.57.mm, 14.04.mm, 0],
        [23.26.mm, 14.04.mm, 0],
        [23.6.mm, 1.69.mm, 0],
        [20.05.mm, 1.35.mm, 0],
        [19.03.mm, 3.13.mm, 0],
        [18.95.mm, 0.08.mm, 0],
        [24.95.mm, 0.08.mm, 0],
        [24.95.mm, 21.82.mm, 0],
        [27.92.mm, 22.42.mm, 0],
        [27.75.mm, 24.95.mm, 0],
        [26.73.mm, 23.18.mm, 0],
        [24.95.mm, 23.35.mm, 0],
        [24.95.mm, 30.79.mm, 0],
        [26.73.mm, 30.96.mm, 0],
        [27.66.mm, 29.1.mm, 0],
        [27.75.mm, 32.06.mm, 0],
        [23.6.mm, 31.89.mm, 0],
        [23.26.mm, 15.4.mm, 0],
        [17.26.mm, 15.4.mm, 0],
        [16.24.mm, 19.96.mm, 0],
        [14.63.mm, 15.48.mm, 0],
        [12.27.mm, 16.33.mm, 0],
        [12.35.mm, 19.96.mm, 0],
        [10.66.mm, 18.61.mm, 0],
        [10.66.mm, 15.4.mm, 0],
        [4.48.mm, 15.48.mm, 0],
        [4.31.mm, 31.89.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S_1401")
    end

    # Clean Outer Boundary Stencil: 70S_1101_1 (Width: 70.0mm)
    def draw_70S_1101_1(entities, length_mm)
      pts = [
        [69.92.mm, 29.95.mm, 0],
        [66.95.mm, 29.78.mm, 0],
        [68.64.mm, 28.68.mm, 0],
        [68.05.mm, 13.07.mm, 0],
        [53.12.mm, 12.47.mm, 0],
        [53.96.mm, 21.38.mm, 0],
        [51.5.mm, 23.08.mm, 0],
        [49.98.mm, 21.64.mm, 0],
        [50.65.mm, 12.3.mm, 0],
        [19.35.mm, 10.95.mm, 0],
        [19.94.mm, 21.64.mm, 0],
        [17.56.mm, 23.08.mm, 0],
        [16.04.mm, 21.64.mm, 0],
        [17.22.mm, 11.28.mm, 0],
        [0.17.mm, 10.01.mm, 0],
        [0.0.mm, 0.51.mm, 0],
        [6.02.mm, 0.08.mm, 0],
        [1.36.mm, 2.04.mm, 0],
        [2.38.mm, 8.91.mm, 0],
        [14.59.mm, 9.42.mm, 0],
        [16.29.mm, 4.92.mm, 0],
        [16.04.mm, 8.06.mm, 0],
        [18.58.mm, 9.5.mm, 0],
        [20.28.mm, 4.92.mm, 0],
        [21.21.mm, 9.67.mm, 0],
        [48.53.mm, 10.86.mm, 0],
        [50.23.mm, 6.36.mm, 0],
        [50.06.mm, 9.76.mm, 0],
        [52.52.mm, 10.95.mm, 0],
        [54.22.mm, 6.36.mm, 0],
        [55.32.mm, 11.2.mm, 0],
        [67.96.mm, 11.62.mm, 0],
        [68.56.mm, 2.04.mm, 0],
        [63.89.mm, 0.08.mm, 0],
        [69.66.mm, 0.08.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S_1101_1")
    end

    # Clean Outer Boundary Stencil: 70S_1501 (Width: 22.0mm)
    def draw_70S_1501(entities, length_mm)
      pts = [
        [0.0.mm, 56.18.mm, 0],
        [0.0.mm, 0.08.mm, 0],
        [1.27.mm, 4.99.mm, 0],
        [3.3.mm, 5.08.mm, 0],
        [1.27.mm, 6.18.mm, 0],
        [1.86.mm, 45.27.mm, 0],
        [7.62.mm, 45.18.mm, 0],
        [8.63.mm, 40.62.mm, 0],
        [10.24.mm, 45.1.mm, 0],
        [12.69.mm, 44.17.mm, 0],
        [12.61.mm, 40.62.mm, 0],
        [14.22.mm, 45.18.mm, 0],
        [20.56.mm, 44.93.mm, 0],
        [20.56.mm, 6.18.mm, 0],
        [18.62.mm, 5.08.mm, 0],
        [20.56.mm, 4.99.mm, 0],
        [20.56.mm, 0.08.mm, 0],
        [21.92.mm, 0.08.mm, 0],
        [21.92.mm, 56.18.mm, 0],
        [15.91.mm, 56.18.mm, 0],
        [15.91.mm, 53.22.mm, 0],
        [20.56.mm, 54.58.mm, 0],
        [20.22.mm, 46.54.mm, 0],
        [1.61.mm, 46.54.mm, 0],
        [1.27.mm, 54.49.mm, 0],
        [6.01.mm, 53.22.mm, 0],
        [6.01.mm, 56.18.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S_1501")
    end

    # Clean Outer Boundary Stencil: 70S_1201_1 (Width: 73.0mm)
    def draw_70S_1201_1(entities, length_mm)
      pts = [
        [0.0.mm, 24.98.mm, 0],
        [0.0.mm, 0.08.mm, 0],
        [2.12.mm, 3.65.mm, 0],
        [37.14.mm, 3.65.mm, 0],
        [37.39.mm, 6.63.mm, 0],
        [34.5.mm, 5.01.mm, 0],
        [34.5.mm, 12.15.mm, 0],
        [37.48.mm, 10.62.mm, 0],
        [38.24.mm, 15.64.mm, 0],
        [70.88.mm, 15.64.mm, 0],
        [71.64.mm, 0.08.mm, 0],
        [72.92.mm, 0.08.mm, 0],
        [72.66.mm, 25.15.mm, 0],
        [66.97.mm, 25.15.mm, 0],
        [71.64.mm, 23.12.mm, 0],
        [70.62.mm, 16.91.mm, 0],
        [36.37.mm, 16.91.mm, 0],
        [36.12.mm, 13.6.mm, 0],
        [33.14.mm, 13.17.mm, 0],
        [32.38.mm, 4.93.mm, 0],
        [1.7.mm, 5.1.mm, 0],
        [1.27.mm, 23.2.mm, 0],
        [5.95.mm, 25.15.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S_1201_1")
    end

    # Clean Outer Boundary Stencil: 70S_1701 (Width: 30.0mm)
    def draw_70S_1701(entities, length_mm)
      pts = [
        [0.08.mm, 26.03.mm, 0],
        [0.0.mm, 25.1.mm, 0],
        [1.1.mm, 24.93.mm, 0],
        [1.18.mm, 18.08.mm, 0],
        [4.06.mm, 18.17.mm, 0],
        [4.06.mm, 19.35.mm, 0],
        [2.37.mm, 19.44.mm, 0],
        [2.79.mm, 24.59.mm, 0],
        [10.65.mm, 24.08.mm, 0],
        [10.73.mm, 2.37.mm, 0],
        [10.06.mm, 1.44.mm, 0],
        [2.87.mm, 1.52.mm, 0],
        [2.37.mm, 6.68.mm, 0],
        [4.06.mm, 6.76.mm, 0],
        [4.06.mm, 8.03.mm, 0],
        [1.1.mm, 8.03.mm, 0],
        [1.1.mm, 1.27.mm, 0],
        [0.0.mm, 0.08.mm, 0],
        [29.92.mm, 0.08.mm, 0],
        [29.92.mm, 26.03.mm, 0]
      ]
      extrude_profile(entities, pts, length_mm, "70S_1701")
    end
  end
end
