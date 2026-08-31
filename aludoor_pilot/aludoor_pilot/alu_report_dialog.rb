# =============================================================================
# ALU DOOR PILOT - MULTI-OPENING PROJECT MANAGER & VENDOR PO REPORT DIALOG
# -----------------------------------------------------------------------------
# Launches the interactive HTML workshop production & procurement pack:
# 1. Prompts for Supabase Sign In / Register on launch if not authenticated.
# 2. Multi-door project schedule manager (D1, D2, W1, etc.) with Unit Numbering.
# 3. Batch 3D model generator in SketchUp viewport (user-triggered).
# 4. Live Supabase Auth & Bar Token deduction ($1 Bar = 1 Token).
# 5. Vendor-wise Purchase Orders (Alumex/Amex per-bar LKR, Hardware, Glass).
# 6. Direct 1-Click PDF download & Supabase Cloud Sync.
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

    def show_report(_width_mm = 1500.0, _height_mm = 2100.0, force_auth_prompt = false)
      # 1. Check Authentication Status
      email = Sketchup.read_default('AluDoorCloud', 'user_email', '')
      saved_pwd = Sketchup.read_default('AluDoorCloud', 'user_pwd', '')

      if email.empty? || saved_pwd.empty? || force_auth_prompt
        prompts = ["Fabricator Email:", "Password:"]
        defaults = [email.empty? ? "luxuselemente@gmail.com" : email, ""]
        input = UI.inputbox(prompts, defaults, "🔑 ALU DOOR 70S Pro — Fabricator Sign In")
        
        if input.nil?
          puts "=> [ALU DOOR Cloud] Sign-in cancelled by user. Operation stopped."
          return
        end

        email = input[0].strip
        saved_pwd = input[1].strip

        if email.empty? || saved_pwd.empty?
          UI.messagebox("❌ Sign-in Error: Email and password cannot be empty.")
          return
        end

        puts "=> [ALU DOOR Cloud] Authenticating #{email} with Supabase..."
        res = AluDoorPilot::SupabaseAuth.sign_in(email, saved_pwd)

        if res[:success]
          tokens = res.dig(:user, 'user_metadata', 'tokens') || 100
          Sketchup.write_default('AluDoorCloud', 'user_email', email)
          Sketchup.write_default('AluDoorCloud', 'user_pwd', saved_pwd)
          Sketchup.write_default('AluDoorCloud', 'user_tokens', tokens)
          UI.messagebox("✅ Supabase Login Successful!\n\nFabricator: #{email}\nActive Quota: #{tokens} Bar Tokens (6000mm)")
        else
          UI.messagebox("❌ Login Failed: #{res[:error] || 'Invalid credentials'}\n\nPlease check your email/password or create an account in the admin portal.")
          Sketchup.write_default('AluDoorCloud', 'user_pwd', '')
          return # STOP COMPLETELY! Do not proceed or open app in guest mode.
        end
      else
        tokens = Sketchup.read_default('AluDoorCloud', 'user_tokens', 100)
      end

      # 2. Launch Main Interactive Workshop Dialog
      dialog = UI::HtmlDialog.new({
        :dialog_title => "ALU DOOR 70S Pro — Multi-Opening Project Manager & Vendor POs (#{email})",
        :preferences_key => "com.aludoor.workshop_report_v5",
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
          AluDoorPilot::SupabaseAuth.save_door_to_cloud(
            payload['name'] || "ALU Door Project (#{email})",
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
            u_tokens = res.dig(:user, 'user_metadata', 'tokens') || 100
            Sketchup.write_default('AluDoorCloud', 'user_email', creds['email'])
            Sketchup.write_default('AluDoorCloud', 'user_pwd', creds['password'])
            Sketchup.write_default('AluDoorCloud', 'user_tokens', u_tokens)
            dialog.execute_script("onAuthSuccess(#{creds['email'].to_json}, #{u_tokens});")
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
        Sketchup.write_default('AluDoorCloud', 'user_pwd', '')
        Sketchup.write_default('AluDoorCloud', 'user_tokens', 0)
        dialog.execute_script("onAuthLoggedOut();")
      end

      # Display HTML
      html_content = File.read(HTML_FILE, encoding: 'utf-8')
      dialog.set_html(html_content)
      dialog.show

      # Pass authenticated state
      UI.start_timer(0.4, false) do
        dialog.execute_script("if(window.setInitialAuthState) window.setInitialAuthState(#{email.to_json}, #{tokens});")
      end

      puts "=> [Project Manager] ALU DOOR 70S Pro active with Supabase Auth (#{email}, #{tokens} Tokens)."
      dialog
    end

    def logout
      Sketchup.write_default('AluDoorCloud', 'user_email', '')
      Sketchup.write_default('AluDoorCloud', 'user_pwd', '')
      Sketchup.write_default('AluDoorCloud', 'user_tokens', 0)
      UI.messagebox("✅ Successfully signed out of ALU DOOR Cloud.\nNext launch will prompt for login.")
    end

    def show_interactive
      show_report
    end
  end
end
