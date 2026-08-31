import cv2
import numpy as np

def clean_stencil_trace():
    img_path = "c:/Users/asank/Documents/ALU DOOR/w.jpg"
    out_path = "c:/Users/asank/Documents/ALU DOOR/aludoor_pilot/aludoor_pilot/profiles_70s_clean.rb"

    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print("Error: Could not load w.jpg")
        return

    H, W = img.shape
    print(f"Loaded high-res image {W}x{H}")

    # 1. Binarize: Black shapes (aluminum profiles) become white (255), white background becomes black (0)
    _, binary = cv2.threshold(img, 150, 255, cv2.THRESH_BINARY_INV)

    # 2. Morphological Erosion to ERASE thin dimension lines, arrows, and text!
    # Thin lines are < 4px thick. Solid walls are > 8px thick.
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (4, 4))
    eroded = cv2.erode(binary, kernel, iterations=2)
    # Dilate back to restore original wall thickness
    cleaned_solid = cv2.dilate(eroded, kernel, iterations=2)

    # 6 Profile region crops (ymin, ymax, xmin, xmax, known_width_mm, name)
    regions = [
        ("70S_1001_1", 0.10, 0.28, 0.12, 0.55, 70.0), # Top Frame
        ("70S_1401",   0.10, 0.28, 0.60, 0.90, 28.0), # Top Sash
        ("70S_1101_1", 0.35, 0.53, 0.12, 0.55, 70.0), # Bottom Frame
        ("70S_1501",   0.33, 0.65, 0.60, 0.90, 22.0), # Bottom Sash
        ("70S_1201_1", 0.62, 0.82, 0.12, 0.55, 73.0), # Side Jamb
        ("70S_1701",   0.68, 0.88, 0.60, 0.90, 30.0)  # Side Sash
    ]

    ruby_code = """module AluDoorPilot
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
"""

    for name, y1_pct, y2_pct, x1_pct, x2_pct, known_width_mm in regions:
        y1, y2 = int(y1_pct * H), int(y2_pct * H)
        x1, x2 = int(x1_pct * W), int(x2_pct * W)

        crop = cleaned_solid[y1:y2, x1:x2]

        # Find external boundary contour
        contours, _ = cv2.findContours(crop, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if not contours:
            print(f"Warning: Could not find solid contour for {name}")
            continue

        # Get largest solid contour
        c = max(contours, key=cv2.contourArea)

        # Polygon approximation for crisp corners
        epsilon = 0.004 * cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, epsilon, True)

        bx, by, bw, bh = cv2.boundingRect(approx)
        if bw == 0: continue

        scale = known_width_mm / float(bw)

        ruby_code += f"\n    # Clean Outer Boundary Stencil: {name} (Width: {known_width_mm}mm)\n"
        ruby_code += f"    def draw_{name}(entities, length_mm)\n"
        ruby_code += "      pts = [\n"

        pts_list = []
        for pt in approx:
            px, py = pt[0]
            mm_x = round((px - bx) * scale, 2)
            mm_y = round((by + bh - py) * scale, 2) # Y pointing UP
            pts_list.append(f"        [{mm_x}.mm, {mm_y}.mm, 0]")

        ruby_code += ",\n".join(pts_list) + "\n"
        ruby_code += "      ]\n"
        ruby_code += f'      extrude_profile(entities, pts, length_mm, "{name}")\n'
        ruby_code += "    end\n"

    ruby_code += "  end\nend\n"

    with open(out_path, "w") as f:
        f.write(ruby_code)

    print(f"SUCCESS: Erased dimension lines & extracted clean outer boundaries into {out_path}")

if __name__ == "__main__":
    clean_stencil_trace()
