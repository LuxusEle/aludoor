import ezdxf

def parse_dxf():
    dxf_path = "w.dxf"
    out_path = "c:/Users/asank/Documents/ALU DOOR/aludoor_pilot/aludoor_pilot/profiles_70s_dxf.rb"

    doc = ezdxf.readfile(dxf_path)
    msp = doc.modelspace()

    polylines = list(msp.query('POLYLINE LWPOLYLINE'))
    print(f"Total polylines in DXF: {len(polylines)}")

    # Extract DXF profile loops (dimensions in meters, e.g. dx ~ 0.02m to 0.08m)
    loops = []
    for p in polylines:
        pts = [(v.dxf.location.x, v.dxf.location.y) for v in p.vertices] if hasattr(p, 'vertices') else [(pt[0], pt[1]) for pt in p.get_points()]
        if len(pts) > 10:
            xs = [pt[0] for pt in pts]
            ys = [pt[1] for pt in pts]
            dx_m = max(xs) - min(xs)
            dy_m = max(ys) - min(ys)
            
            # Filter profile candidates (dx between 20mm and 80mm)
            if 0.015 < dx_m < 0.085 and 0.015 < dy_m < 0.085:
                # Convert meters to millimeters
                pts_mm = [((x - min(xs))*1000.0, (y - min(ys))*1000.0) for x, y in pts]
                loops.append((dx_m * 1000.0, dy_m * 1000.0, min(ys), min(xs), pts_mm))

    print(f"Filtered to {len(loops)} true CAD vector profile loops.")

    # Sort loops by Y descending (top to bottom of drawing), then X (left to right)
    loops.sort(key=lambda item: (-item[2], item[3]))

    ruby_code = """module AluDoorPilot
  module Profiles70SDXF
    extend self

    def extrude_profile(entities, points, length_mm, name="DXF Profile")
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
"""

    names = ["70S_1001_1", "70S_1401", "70S_1101_1", "70S_1501", "70S_1201_1", "70S_1701"]

    for idx, (width_mm, height_mm, min_y, min_x, pts) in enumerate(loops):
        if idx >= len(names):
            break
        name = names[idx]

        ruby_code += f"\n    # True DXF Vector CAD Profile: {name} ({width_mm:.2f}mm x {height_mm:.2f}mm)\n"
        ruby_code += f"    def draw_{name}(entities, length_mm)\n"
        ruby_code += "      pts = [\n"

        pts_list = []
        for x, y in pts:
            pts_list.append(f"        [{x:.3f}.mm, {y:.3f}.mm, 0]")

        ruby_code += ",\n".join(pts_list) + "\n"
        ruby_code += "      ]\n"
        ruby_code += f'      extrude_profile(entities, pts, length_mm, "{name}")\n'
        ruby_code += "    end\n"

    ruby_code += "  end\nend\n"

    with open(out_path, "w") as f:
        f.write(ruby_code)

    print(f"SUCCESS: Extracted true DXF vector profiles into {out_path}")

if __name__ == "__main__":
    parse_dxf()
