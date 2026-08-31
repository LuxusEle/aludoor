import ezdxf

def convert_clean_dxf_to_ruby():
    dxf_path = "w_clean.dxf"
    out_path = "c:/Users/asank/Documents/ALU DOOR/aludoor_pilot/aludoor_pilot/profiles_70s_clean_dxf.rb"

    doc = ezdxf.readfile(dxf_path)
    msp = doc.modelspace()

    entities = list(msp)
    print(f"Total entities in w_clean.dxf: {len(entities)}")

    names = [
      ("70S_1001_1", "70S-1001-1 Top Frame"),
      ("70S_1401", "70S-1401 Top Sash"),
      ("70S_1101_1", "70S-1101-1 Bottom Frame"),
      ("70S_1501", "70S-1501 Bottom Sash"),
      ("70S_1201_1", "70S-1201-1 Side Jamb"),
      ("70S_1701", "70S-1701 Side Sash")
    ]

    ruby_code = """module AluDoorPilot
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
"""

    for idx, e in enumerate(entities):
        pts = [(v.dxf.location.x, v.dxf.location.y) for v in e.vertices]
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        min_x, min_y = min(xs), min(ys)
        dx, dy = max(xs) - min_x, max(ys) - min_y

        func_name, label_name = names[idx] if idx < len(names) else (f"Profile_{idx+1}", f"Profile {idx+1}")

        ruby_code += f"\n    # 100% Exact Vector CAD from w_clean.dxf: {label_name} ({dx:.2f}mm x {dy:.2f}mm)\n"
        ruby_code += f"    def draw_{func_name}(entities, length_mm)\n"
        ruby_code += "      pts = [\n"

        pts_list = []
        for x, y in pts:
            # Normalize to start at (0,0)
            rel_x = round(x - min_x, 3)
            rel_y = round(y - min_y, 3)
            pts_list.append(f"        [{rel_x}.mm, {rel_y}.mm, 0]")

        ruby_code += ",\n".join(pts_list) + "\n"
        ruby_code += "      ]\n"
        ruby_code += f'      extrude_profile(entities, pts, length_mm, "{label_name}")\n'
        ruby_code += "    end\n"

    ruby_code += "  end\nend\n"

    with open(out_path, "w") as f:
        f.write(ruby_code)

    print(f"SUCCESS: Exported 100% perfect DXF vector profiles into {out_path}")

if __name__ == "__main__":
    convert_clean_dxf_to_ruby()
