# =============================================================================
# ALU DOOR PILOT - MULTI-OPENING PROJECT MANAGER & VENDOR PO REPORT DIALOG
# -----------------------------------------------------------------------------
# Launches the interactive HTML workshop production & procurement pack:
# 1. Multi-door project schedule manager (D1, D2, W1, etc.) with Unit Numbering.
# 2. Batch 3D model generator in SketchUp viewport (user-triggered).
# 3. Live Supabase Auth & Bar Token deduction ($1 Bar = 1 Token).
# 4. Vendor-wise Purchase Orders (Alumex/Amex per-bar LKR, Hardware, Glass).
# 5. Direct 1-Click PDF download & Supabase Cloud Sync.
# =============================================================================

require 'sketchup.rb'
require 'json'
require_relative 'profiles_70s_clean_dxf'
require_relative 'system_70s_app'
require_relative 'alu_nesting_engine'
require_relative 'supabase_auth'

module AluDoorPilot
  module ReportDialog
    extend self

    HTML_FILE = File.expand_path(File.join(__dir__, 'alu_workshop_report.html'))

    def show_report(_width_mm = 1500.0, _height_mm = 2100.0)
      dialog = UI::HtmlDialog.new({
        :dialog_title => "ALU DOOR 70S Pro — Multi-Opening Project Manager & Vendor POs",
        :preferences_key => "com.aludoor.workshop_report_v4",
        :width => 1260,
        :height => 900,
        :min_width => 920,
        :min_height => 650,
        :resizable => true,
        :style => UI::HtmlDialog::STYLE_DIALOG
      })

      # Action Callback 1: Batch 3D Generation in SketchUp Viewport
      dialog.add_action_callback("generateBatchSchedule") do |_action_context, json_schedule|
        begin
          schedule_items = JSON.parse(json_schedule)
          m = Sketchup.active_model
          m.start_operation('Generate Batch ALU Door Project', true)

          # Clear previous 70S generated groups
          old_grps = m.active_entities.grep(Sketchup::Group).select { |g| g.name =~ /70\s*mm|70S|Aluminium|Profile|Door|Frame|Slider|Opening|Unit/i }
          m.active_entities.erase_entities(old_grps) unless old_grps.empty?

          # Place each door side-by-side along the Y axis
          current_y_offset = 0.0
          total_units_created = 0

          schedule_items.each do |item|
            tag = item['tag'] || 'D1'
            dw = item['width'].to_f
            dh = item['height'].to_f
            qty = (item['qty'] || 1).to_i

            qty.times do |q_idx|
              unit_num_str = "#" + (total_units_created + 1).to_s.rjust(2, '0')
              door_grp = m.active_entities.add_group
              door_grp.name = "#{unit_num_str} #{tag} (Unit #{q_idx + 1}/#{qty}) - 70S [#{dw.to_i}x#{dh.to_i}mm]"
              
              # Build 3D door in group (height_mm is 1st param, width_mm is 2nd param)
              AluDoorPilot::Profiles70SCleanDXF.build_70s_sliding_door(door_grp.entities, dh, dw)

              # Offset position along Y axis
              door_grp.transform!(Geom::Transformation.translation([0, current_y_offset.mm, 0]))
              current_y_offset += (dw + 350.0) # 350mm spacing between openings
              total_units_created += 1
            end
          end

          m.commit_operation
          m.active_view.zoom_extents
          dialog.execute_script("recalculateLocalPayload();")
          dialog.execute_script("showToast('✅ Generated #{total_units_created} Opening(s) across #{schedule_items.length} Type(s) in 3D!');")
        rescue StandardError => err
          dialog.execute_script("showToast('❌ 3D Generation Error: #{err.message}');")
        end
      end

      # Action Callback 2: Save to Supabase Cloud
      dialog.add_action_callback("saveToCloud") do |_action_context, json_str|
        begin
          payload = JSON.parse(json_str)
          saved_email = Sketchup.read_default('AluDoorCloud', 'user_email', 'fabricator@aludoor.com')
          AluDoorPilot::SupabaseAuth.save_door_to_cloud(
            payload['name'] || "ALU Door Project (#{saved_email})",
            1500.0, 2100.0,
            payload,
            {}
          )
          dialog.execute_script("showToast('☁️ Project schedule, Vendor Catalogs & POs saved to Supabase!');")
        rescue StandardError => err
          dialog.execute_script("showToast('❌ Supabase Error: #{err.message}');")
        end
      end

      # Action Callback 3: Native Supabase Login
      dialog.add_action_callback("authLogin") do |_action_context, json_str|
        begin
          creds = JSON.parse(json_str)
          res = AluDoorPilot::SupabaseAuth.sign_in(creds['email'], creds['password'])
          if res[:success]
            tokens = res.dig(:user, 'user_metadata', 'tokens') || 100
            Sketchup.write_default('AluDoorCloud', 'user_email', creds['email'])
            Sketchup.write_default('AluDoorCloud', 'user_tokens', tokens)
            dialog.execute_script("onAuthSuccess(#{creds['email'].to_json}, #{tokens});")
          else
            dialog.execute_script("onAuthError(#{res[:error].to_json});")
          end
        rescue StandardError => err
          dialog.execute_script("onAuthError(#{err.message.to_json});")
        end
      end

      # Action Callback 4: Native Supabase Logout
      dialog.add_action_callback("authLogout") do |_action_context|
        Sketchup.write_default('AluDoorCloud', 'user_email', '')
        Sketchup.write_default('AluDoorCloud', 'user_tokens', 0)
        dialog.execute_script("onAuthLoggedOut();")
      end

      # Display HTML
      html_content = File.read(HTML_FILE, encoding: 'utf-8')
      dialog.set_html(html_content)
      dialog.show

      # Pass saved credentials if any
      saved_email = Sketchup.read_default('AluDoorCloud', 'user_email', 'asankasampath@gmail.com')
      saved_tokens = Sketchup.read_default('AluDoorCloud', 'user_tokens', 100)
      if saved_email && !saved_email.empty?
        UI.start_timer(0.5, false) do
          dialog.execute_script("if(window.setInitialAuthState) window.setInitialAuthState(#{saved_email.to_json}, #{saved_tokens});")
        end
      end

      puts "=> [Project Manager] ALU DOOR 70S Pro launched with Live Supabase Auth (#{saved_email})."
      dialog
    end

    def show_interactive
      show_report
    end
  end
end
