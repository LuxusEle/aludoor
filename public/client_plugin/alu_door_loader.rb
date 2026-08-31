# =============================================================================
# ALU DOOR 70S PRO — LIGHTWEIGHT CLOUD RAM-STREAMING LOADER (8 KB)
# -----------------------------------------------------------------------------
# Authenticates with Supabase cloud backend, checks fabricator bar token balance,
# streams the complete 70S Sliding Door system into SketchUp RAM (eval),
# leaving ZERO proprietary code on the local hard disk.
# =============================================================================

require 'sketchup.rb'
require 'net/http'
require 'uri'
require 'json'

module AluDoorCloudLoader
  extend self

  CLOUD_ENDPOINT = "https://alu-door-70s.vercel.app/api/load-engine"
  LOCAL_DEV_ENDPOINT = "http://localhost:3000/api/load-engine"

  def launch_engine
    email = Sketchup.read_default('AluDoorCloud', 'user_email', '')
    saved_pwd = Sketchup.read_default('AluDoorCloud', 'user_pwd', '')

    if email.empty? || saved_pwd.empty?
      prompts = ["Fabricator Email:", "Account Password:", "Server URL:"]
      defaults = [email.empty? ? "workshop@gmail.com" : email, "", CLOUD_ENDPOINT]
      input = UI.inputbox(prompts, defaults, "🔑 ALU DOOR 70S Pro — Fabricator Login")
      return unless input

      email = input[0].strip
      saved_pwd = input[1].strip
      endpoint = input[2].strip.empty? ? CLOUD_ENDPOINT : input[2].strip

      Sketchup.write_default('AluDoorCloud', 'user_email', email)
      Sketchup.write_default('AluDoorCloud', 'user_pwd', saved_pwd)
      Sketchup.write_default('AluDoorCloud', 'endpoint', endpoint)
    else
      endpoint = Sketchup.read_default('AluDoorCloud', 'endpoint', CLOUD_ENDPOINT)
    end

    UI.set_cursor(6) # Wait cursor
    puts "=> [ALU DOOR Cloud] Authenticating fabricator (#{email})..."

    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = 10
    http.read_timeout = 25

    request = Net::HTTP::Post.new(uri.path.empty? ? '/api/load-engine' : uri.path, { 'Content-Type' => 'application/json' })
    request.body = JSON.generate({
      email: email,
      password: saved_pwd
    })

    response = nil
    begin
      response = http.request(request)
    rescue StandardError => net_err
      UI.messagebox("❌ Network Error: Could not connect to #{endpoint}\n#{net_err.message}")
      return
    end

    if response.code.to_i == 200
      res_data = JSON.parse(response.body)
      if res_data['success'] && res_data['code']
        tokens_left = res_data['user']['tokens_remaining'] || 100
        puts "=> [ALU DOOR Cloud] Authentication successful! Tokens: #{tokens_left} 6m Bars remaining."
        
        # Stream directly to RAM
        begin
          eval(res_data['code'], TOPLEVEL_BINDING)
        rescue StandardError => eval_err
          puts "=> [ALU DOOR Cloud] Runtime eval error: #{eval_err.message}"
          puts eval_err.backtrace.join("\n")
          UI.messagebox("❌ RAM Engine Execution Error:\n#{eval_err.message}")
        end
      else
        UI.messagebox("❌ Cloud Error: #{res_data['error'] || 'Unknown error'}")
      end
    else
      begin
        err_body = JSON.parse(response.body)
        msg = err_body['error'] || "Server returned HTTP #{response.code}"
      rescue
        msg = "Server returned HTTP #{response.code}"
      end

      if response.code.to_i == 401
        Sketchup.write_default('AluDoorCloud', 'user_pwd', '')
        UI.messagebox("❌ Login Failed: #{msg}\n\nPlease check your email/password or create an account in the admin portal.")
      else
        UI.messagebox("❌ Cloud Stream Failed: #{msg}")
      end
    end
  end

  def logout
    Sketchup.write_default('AluDoorCloud', 'user_email', '')
    Sketchup.write_default('AluDoorCloud', 'user_pwd', '')
    UI.messagebox("✅ Successfully logged out of ALU DOOR Cloud.")
  end

  # Register SketchUp Menus
  unless file_loaded?(__FILE__)
    ext_menu = UI.menu('Extensions')
    alu_menu = ext_menu.add_submenu('ALU Door 70S Pro')
    alu_menu.add_item('⚡ Launch Cloud 70S Engine (RAM Stream)') { AluDoorCloudLoader.launch_engine }
    alu_menu.add_item('🔑 Switch Fabricator Account (Logout)') { AluDoorCloudLoader.logout }
    file_loaded(__FILE__)
  end
end
