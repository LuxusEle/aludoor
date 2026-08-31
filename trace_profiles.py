import cv2
import numpy as np
import os

def trace_image_to_ruby():
    img_path = "c:/Users/asank/Documents/ALU DOOR/w.jpg"
    out_path = "c:/Users/asank/Documents/ALU DOOR/aludoor_pilot/aludoor_pilot/profiles_70s_auto.rb"

    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print("Error: Could not load w.jpg")
        return

    H, W = img.shape
    print(f"Image dimensions: {W}x{H}")

    # Bounding boxes (ymin, ymax, xmin, xmax) in normalized percentages for the 6 profiles
    crops = [
        ("70S_1001_1", 0.10, 0.28, 0.12, 0.55, 70.0), # Top Frame (70mm)
        ("70S_1401",   0.10, 0.28, 0.60, 0.90, 28.0), # Top Sash (28mm)
        ("70S_1101_1", 0.35, 0.53, 0.12, 0.55, 70.0), # Bottom Frame (70mm)
        ("70S_1501",   0.33, 0.65, 0.60, 0.90, 22.0), # Bottom Sash (22mm)
        ("70S_1201_1", 0.62, 0.82, 0.12, 0.55, 73.0), # Side Jamb (73mm)
        ("70S_1701",   0.68, 0.88, 0.60, 0.90, 30.0)  # Side Sash (30mm)
    ]

    ruby_code = """module AluDoorPilot
  module Profiles70SAuto
    extend self

    def extrude_profile(entities, points, length_mm, name="Auto Profile")
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
      face.pushpull(length_mm.mm) if face&.valid?
      group
    end
"""

    for name, y1_pct, y2_pct, x1_pct, x2_pct, known_width_mm in crops:
        y1, y2 = int(y1_pct * H), int(y2_pct * H)
        x1, x2 = int(x1_pct * W), int(x2_pct * W)
        
        crop = img[y1:y2, x1:x2]
        
        # Binarize: Solid black aluminum faces are dark (< 100)
        _, binary = cv2.threshold(crop, 120, 255, cv2.THRESH_BINARY_INV)

        # Morphological closing to clean noise
        kernel = np.ones((3,3), np.uint8)
        binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)

        # Find contours
        contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if not contours:
            print(f"Warning: No contour found for {name}")
            continue

        # Get largest contour (the profile cross-section)
        c = max(contours, key=cv2.contourArea)

        # Polygon approximation
        epsilon = 0.003 * cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, epsilon, True)

        bx, by, bw, bh = cv2.boundingRect(approx)
        if bw == 0:
            continue

        scale = known_width_mm / float(bw)

        ruby_code += f"\n    # Auto-traced profile: {name}\n"
        ruby_code += f"    def draw_{name}(entities, length_mm)\n"
        ruby_code += "      pts = [\n"

        pts_list = []
        for pt in approx:
            px, py = pt[0]
            mm_x = round((px - bx) * scale, 2)
            mm_y = round((by + bh - py) * scale, 2) # Y up
            pts_list.append(f"        [{mm_x}.mm, {mm_y}.mm, 0]")

        ruby_code += ",\n".join(pts_list) + "\n"
        ruby_code += "      ]\n"
        ruby_code += f'      extrude_profile(entities, pts, length_mm, "{name}")\n'
        ruby_code += "    end\n"

    ruby_code += "  end\nend\n"

    with open(out_path, "w") as f:
        f.write(ruby_code)

    print(f"SUCCESS: Auto-traced all 6 profiles from w.jpg into {out_path}")

if __name__ == "__main__":
    trace_image_to_ruby()
