# =============================================================================
# ALU DOOR PILOT - 70S 2-TRACK SLIDING DOOR FULL SYSTEM APPLICATION MODULE
# -----------------------------------------------------------------------------
# Complete All-in-One Application Module for:
# 1. 3D BIM/CAD Parametric Assembly (Outer Frame + Sashes + Glass + Hardware)
# 2. Complete Bill of Materials (BOM) Calculation (Weights, Lengths, Quantities)
# 3. 1D Linear Bar Nesting / Cutting Stock Optimization Data Feeder
# 4. CSV & JSON Data Export for Downstream ERP / Production Modules
# =============================================================================

require 'sketchup.rb'
require 'json'
require_relative 'profiles_70s_clean_dxf'
require_relative 'hardware_70s'

module AluDoorPilot
  module System70S
    extend self

    SYSTEM_NAME    = '70S 2-Track Aluminium Sliding Door System'.freeze
    CATALOG_SERIES = '70S Series (Alumex Standard)'.freeze
    DEFAULT_WIDTH  = 1500.0 # mm
    DEFAULT_HEIGHT = 2100.0 # mm
    DEFAULT_STOCK  = 6000.0 # mm (Standard Stock Length)
    DEFAULT_KERF   = 3.5    # mm (Saw Blade Kerf)

    # Technical Profile Catalog Specifications (Linear Weight kg/m & Descriptions)
    PROFILE_SPECS = {
      '70S-1001-1' => { name: 'Top Track Frame Head',       wt_kg_m: 0.940, depth: 32.0,  width: 69.72 },
      '70S-1101-1' => { name: 'Bottom Track Sill',          wt_kg_m: 1.050, depth: 29.96, width: 69.71 },
      '70S-1201-1' => { name: 'Side Wall Upright Jamb',     wt_kg_m: 0.780, depth: 24.96, width: 72.68 },
      '70S-1401'   => { name: 'Top Sash Horizontal Rail',    wt_kg_m: 0.460, depth: 31.66, width: 27.90 },
      '70S-1501'   => { name: 'Bottom Sash Horizontal Rail', wt_kg_m: 0.720, depth: 56.11, width: 21.92 },
      '70S-1701'   => { name: 'Handle Side Sash Stile',      wt_kg_m: 0.433, depth: 25.98, width: 29.90 },
      '70S-1601'   => { name: 'Interlock Meeting Stile',     wt_kg_m: 0.495, depth: 32.00, width: 29.90 }
    }.freeze

    # =========================================================================
    # 1. CORE DATA CALCULATOR: BOM & CUT LIST DERIVATION
    # =========================================================================
    def calculate_system_data(width_mm, height_mm, options = {})
      w = width_mm.to_f
      h = height_mm.to_f
      overlap_mm = (options[:overlap_mm] || 28.0).to_f
      glass_thick = (options[:glass_thick] || 6.0).to_f

      # Door Leaf Calculations
      leaf_w = (w + overlap_mm) / 2.0
      leaf_h = h - 28.0 # Enters top frame pocket 16mm, clears bottom track 12mm
      rail_len = leaf_w - 60.0 # Clear cut length between 30mm left & right stiles

      # Glass Dimensions
      glass_w = leaf_w - 40.0 # Enters 10mm into left & right stile mouths
      glass_h = leaf_h - 68.0 # Enters 10mm into top & bottom rail mouths
      glass_area_m2 = (glass_w * glass_h * 2.0) / 1_000_000.0

      # Profile Cut List Items
      profile_items = [
        # Outer Wall Frame
        { code: '70S-1001-1', role: 'Frame Head',       qty: 1, cut_len_mm: w,        angle_l: 90, angle_r: 90, group: 'Outer Frame' },
        { code: '70S-1101-1', role: 'Frame Sill',       qty: 1, cut_len_mm: w,        angle_l: 90, angle_r: 90, group: 'Outer Frame' },
        { code: '70S-1201-1', role: 'Left Jamb',        qty: 1, cut_len_mm: h,        angle_l: 90, angle_r: 90, group: 'Outer Frame' },
        { code: '70S-1201-1', role: 'Right Jamb',       qty: 1, cut_len_mm: h,        angle_l: 90, angle_r: 90, group: 'Outer Frame' },
        # Sliding Sashes (2 Panels)
        { code: '70S-1401',   role: 'Top Sash Rail',    qty: 2, cut_len_mm: rail_len, angle_l: 90, angle_r: 90, group: 'Door Sashes' },
        { code: '70S-1501',   role: 'Bottom Sash Rail', qty: 2, cut_len_mm: rail_len, angle_l: 90, angle_r: 90, group: 'Door Sashes' },
        { code: '70S-1701',   role: 'Handle Stile',     qty: 2, cut_len_mm: leaf_h,   angle_l: 90, angle_r: 90, group: 'Door Sashes' },
        { code: '70S-1601',   role: 'Interlock Stile',  qty: 2, cut_len_mm: leaf_h,   angle_l: 90, angle_r: 90, group: 'Door Sashes' }
      ]

      # Enhance with weights and metadata
      total_alu_weight_kg = 0.0
      bom_items = profile_items.map do |item|
        spec = PROFILE_SPECS[item[:code]] || { name: 'Aluminium Section', wt_kg_m: 0.5 }
        total_len_m = (item[:cut_len_mm] * item[:qty]) / 1000.0
        total_wt = total_len_m * spec[:wt_kg_m]
        total_alu_weight_kg += total_wt

        item.merge({
          description: spec[:name],
          wt_kg_m: spec[:wt_kg_m],
          total_len_m: total_len_m.round(3),
          total_wt_kg: total_wt.round(3)
        })
      end

      # Hardware List
      hardware_items = [
        { code: '70S-1914', name: 'V-Groove Roller Wheel & Carriage', qty: 4, unit: 'pcs', purpose: 'Bottom Rail Gliding' },
        { code: 'ST-4.2x38', name: 'Stainless Steel ST Self-Tapping Screws', qty: 16, unit: 'pcs', purpose: 'Frame & Sash Assembly' },
        { code: 'WP-7x6',   name: 'Wool Pile / Weatherstrip Seal', qty: ((4 * leaf_h + 4 * leaf_w) / 1000.0).round(2), unit: 'm', purpose: 'Air & Dust Sealing' },
        { code: 'EPDM-10',  name: 'EPDM Glazing Gasket (10mm Pocket)', qty: ((4 * glass_w + 4 * glass_h) / 1000.0).round(2), unit: 'm', purpose: 'Glass Cushioning' }
      ]

      # Glass Schedule
      glass_schedule = [
        {
          name: format('Clear Float Safety Glass %.1fmm', glass_thick),
          qty: 2,
          width_mm: glass_w.round(1),
          height_mm: glass_h.round(1),
          thickness_mm: glass_thick,
          total_area_m2: glass_area_m2.round(3)
        }
      ]

      {
        system_name: SYSTEM_NAME,
        catalog_series: CATALOG_SERIES,
        overall_width_mm: w,
        overall_height_mm: h,
        leaf_width_mm: leaf_w.round(1),
        leaf_height_mm: leaf_h.round(1),
        overlap_mm: overlap_mm,
        total_alu_weight_kg: total_alu_weight_kg.round(2),
        bom_profiles: bom_items,
        hardware: hardware_items,
        glass: glass_schedule
      }
    end

    # =========================================================================
    # 2. BAR NESTING PAYLOAD GENERATOR (1D Linear Cutting Stock Optimization)
    # Formats cut pieces for standard 6000mm stock bars with saw kerf allowance
    # =========================================================================
    def generate_nesting_payload(width_mm, height_mm, stock_bar_len_mm = DEFAULT_STOCK, kerf_mm = DEFAULT_KERF)
      data = calculate_system_data(width_mm, height_mm)

      cuts_by_profile = {}
      data[:bom_profiles].each do |item|
        code = item[:code]
        cuts_by_profile[code] ||= {
          profile_code: code,
          description: item[:description],
          stock_bar_len_mm: stock_bar_len_mm,
          kerf_mm: kerf_mm,
          required_cuts: []
        }
        item[:qty].times do |i|
          cuts_by_profile[code][:required_cuts] << {
            cut_id: format('%s-%s-%d', code, item[:role].gsub(/\s+/, '_'), i + 1),
            length_mm: item[:cut_len_mm].round(1),
            role: item[:role],
            angle_left: item[:angle_l],
            angle_right: item[:angle_r]
          }
        end
      end

      {
        project: 'AluDoorPilot 70S System',
        door_dimensions: { width_mm: width_mm, height_mm: height_mm },
        standard_stock_length_mm: stock_bar_len_mm,
        blade_kerf_mm: kerf_mm,
        profiles_to_nest: cuts_by_profile.values
      }
    end

    # =========================================================================
    # 3. MASTER BUILD FUNCTION: 3D MODEL GENERATION + METADATA ATTACHMENT
    # Single function to call from any script, UI, or automated workflow
    # =========================================================================
    def build_70s_full_system(width_mm = DEFAULT_WIDTH, height_mm = DEFAULT_HEIGHT, entities = nil)
      model = Sketchup.active_model
      ents = entities || model.active_entities

      model.start_operation('Build 70S Full Sliding Door System', true)

      # 1. Clean previous models if generating in root
      if entities.nil?
        prev = model.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70\s*mm|70S|AluDoorPilot/i }
        model.active_entities.erase_entities(prev) unless prev.empty?
      end

      # 2. Build 3D CAD Geometry using verified profiles_70s_clean_dxf
      root = AluDoorPilot::Profiles70SCleanDXF.build_70s_sliding_door(ents, height_mm, width_mm)
      root.name = format('AluDoor 70S Full System [%.0fx%.0f mm]', width_mm, height_mm)

      # 3. Compute Data Model & Attach BIM Attributes
      sys_data = calculate_system_data(width_mm, height_mm)
      nesting_data = generate_nesting_payload(width_mm, height_mm)

      root.set_attribute('ALU_DOOR', 'system_type', SYSTEM_NAME)
      root.set_attribute('ALU_DOOR', 'catalog_series', CATALOG_SERIES)
      root.set_attribute('ALU_DOOR', 'width_mm', width_mm)
      root.set_attribute('ALU_DOOR', 'height_mm', height_mm)
      root.set_attribute('ALU_DOOR', 'total_alu_weight_kg', sys_data[:total_alu_weight_kg])
      root.set_attribute('ALU_DOOR', 'bom_json', JSON.generate(sys_data))
      root.set_attribute('ALU_DOOR', 'nesting_json', JSON.generate(nesting_data))

      model.selection.clear
      model.selection.add(root)
      model.commit_operation
      model.active_view.zoom(root)

      puts "================================================================="
      puts format(" [AluDoor 70S Full System] Generated: %.0fmm W x %.0fmm H", width_mm, height_mm)
      puts format(" Aluminium Total Weight: %.2f kg | Glass: %.2f m²", sys_data[:total_alu_weight_kg], sys_data[:glass][0][:total_area_m2])
      puts " Metadata (BOM JSON & Nesting JSON) embedded in root group attributes."
      puts "================================================================="

      {
        group: root,
        data: sys_data,
        nesting: nesting_data
      }
    end

    # =========================================================================
    # 4. EXPORT UTILITIES: CSV EXPORT FOR BOM & BAR NESTING
    # =========================================================================
    def export_bom_csv(width_mm, height_mm, file_path = nil)
      data = calculate_system_data(width_mm, height_mm)
      path = file_path || UI.savepanel('Save Bill of Materials (CSV)', '', "BOM_70S_#{width_mm.to_i}x#{height_mm.to_i}.csv")
      return unless path

      File.open(path, 'w') do |f|
        f.puts "ALU DOOR PILOT - BILL OF MATERIALS (BOM)"
        f.puts "System,#{data[:system_name]}"
        f.puts "Dimensions,#{data[:overall_width_mm]} mm W x #{data[:overall_height_mm]} mm H"
        f.puts "Total Aluminium Weight,#{data[:total_alu_weight_kg]} kg"
        f.puts ""
        f.puts "PROFILE CUT LIST"
        f.puts "Profile Code,Description,Group,Role,Cut Length (mm),Qty,Total Length (m),Unit Weight (kg/m),Total Weight (kg),Left Cut,Right Cut"
        data[:bom_profiles].each do |p|
          f.puts "#{p[:code]},\"#{p[:description]}\",#{p[:group]},#{p[:role]},#{p[:cut_len_mm]},#{p[:qty]},#{p[:total_len_m]},#{p[:wt_kg_m]},#{p[:total_wt_kg]},#{p[:angle_l]}°,#{p[:angle_r]}°"
        end
        f.puts ""
        f.puts "HARDWARE & ACCESSORIES"
        f.puts "Code,Description,Purpose,Qty,Unit"
        data[:hardware].each do |h|
          f.puts "#{h[:code]},\"#{h[:name]}\",\"#{h[:purpose]}\",#{h[:qty]},#{h[:unit]}"
        end
        f.puts ""
        f.puts "GLASS SPECIFICATIONS"
        f.puts "Description,Qty,Width (mm),Height (mm),Thickness (mm),Total Area (m2)"
        data[:glass].each do |g|
          f.puts "\"#{g[:name]}\",#{g[:qty]},#{g[:width_mm]},#{g[:height_mm]},#{g[:thickness_mm]},#{g[:total_area_m2]}"
        end
      end

      UI.messagebox("BOM successfully exported to:\n#{path}")
      path
    end

    def export_nesting_csv(width_mm, height_mm, file_path = nil)
      nesting = generate_nesting_payload(width_mm, height_mm)
      path = file_path || UI.savepanel('Save Bar Nesting Cutlist (CSV)', '', "Nesting_70S_#{width_mm.to_i}x#{height_mm.to_i}.csv")
      return unless path

      File.open(path, 'w') do |f|
        f.puts "Cut_ID,Profile_Code,Description,Length_mm,Angle_Left,Angle_Right,Stock_Bar_Length_mm"
        nesting[:profiles_to_nest].each do |p|
          p[:required_cuts].each do |c|
            f.puts "#{c[:cut_id]},#{p[:profile_code]},\"#{p[:description]}\",#{c[:length_mm]},#{c[:angle_left]},#{c[:angle_right]},#{p[:stock_bar_len_mm]}"
          end
        end
      end

      UI.messagebox("Bar Nesting Cutlist successfully exported to:\n#{path}")
      path
    end

    # =========================================================================
    # 5. INTERACTIVE APP UI DIALOG (Launch Pad)
    # =========================================================================
    def run_app_interactive
      prompts = [
        'Overall Frame Width (mm)',
        'Overall Frame Height (mm)',
        'Panel Overlap (mm)',
        'Glass Thickness (mm)',
        'Action (1: 3D Model, 2: Export BOM CSV, 3: Export Nesting CSV)'
      ]
      defaults = [1500.0, 2100.0, 28.0, 6.0, '1']
      list = ['', '', '', '', '1: 3D Model|2: Export BOM CSV|3: Export Nesting CSV']

      values = UI.inputbox(prompts, defaults, list, '70S Sliding Door System App')
      return unless values

      w = values[0].to_f
      h = values[1].to_f
      overlap = values[2].to_f
      glass_t = values[3].to_f
      action = values[4].to_s[0]

      case action
      when '1'
        build_70s_full_system(w, h)
      when '2'
        export_bom_csv(w, h)
      when '3'
        export_nesting_csv(w, h)
      end
    end
  end
end
