const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const SUPABASE_URL = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://iefeibuhjupnpmcomxbg.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY || 'sb_publishable_3NjI86Sk0ppx1s3f7Hr8ZQ_KiGjuWy9';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Method not allowed. Use POST.' });
  }

  try {
    const { email, password, auth_token } = req.body || {};

    if (!email && !auth_token) {
      return res.status(400).json({ success: false, error: 'Email or Auth Token required.' });
    }

    let user = null;

    // 1. Authenticate with Supabase
    if (password && email) {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password });
      if (error || !data.user) {
        return res.status(401).json({ success: false, error: error ? error.message : 'Invalid credentials.' });
      }
      user = data.user;
    } else if (auth_token) {
      const { data, error } = await supabase.auth.getUser(auth_token);
      if (error || !data.user) {
        return res.status(401).json({ success: false, error: 'Invalid auth token.' });
      }
      user = data.user;
    }

    // 2. Check Token / Bar Balance
    let tokens = user.user_metadata?.tokens ?? 100; // Default 100 trial tokens for new fabricators

    if (tokens <= 0) {
      return res.status(403).json({
        success: false,
        error: 'Zero token balance remaining. Please purchase additional bar tokens from the admin panel.'
      });
    }

    // 3. Read & Bundle 70S Ruby Modules into RAM Payload
    const pilotDir = path.join(process.cwd(), 'aludoor_pilot', 'aludoor_pilot');
    const htmlReportPath = path.join(pilotDir, 'alu_workshop_report.html');

    let htmlReportContent = '';
    if (fs.existsSync(htmlReportPath)) {
      htmlReportContent = fs.readFileSync(htmlReportPath, 'utf8');
    }

    // List of core ruby files to bundle in exact dependency order
    const rubyFiles = [
      'profiles_70s_clean_dxf.rb',
      'hardware_70s.rb',
      'alu_nesting_engine.rb',
      'supabase_auth.rb',
      'system_70s_app.rb',
      'alu_report_dialog.rb',
      'main.rb'
    ];

    let bundledCode = "# =============================================================================\n";
    bundledCode += "# ALU DOOR 70S PRO — CLOUD RAM STREAMING RUNTIME (MEMORY-ONLY)\n";
    bundledCode += "# Authenticated Fabricator: " + user.email + "\n";
    bundledCode += "# Tokens Remaining: " + tokens + " Bars\n";
    bundledCode += "# =============================================================================\n\n";

    for (const file of rubyFiles) {
      const filePath = path.join(pilotDir, file);
      if (fs.existsSync(filePath)) {
        let code = fs.readFileSync(filePath, 'utf8');

        // Strip require_relative statements since all modules are concatenated in RAM
        code = code.replace(/require_relative\s+['"].*?['"]/g, '# [RAM Stripped require_relative]');

        // Inject the embedded HTML report content directly into AluDoorPilot::ReportDialog
        if (file === 'alu_report_dialog.rb' && htmlReportContent) {
          const escapedHtml = JSON.stringify(htmlReportContent);
          code = code.replace(
            /html_content\s*=\s*File\.read\(HTML_FILE.*?\)/,
            `html_content = ${escapedHtml}`
          );
        }

        bundledCode += `\n# --- BEGIN: ${file} ---\n` + code + `\n# --- END: ${file} ---\n`;
      }
    }

    // Auto-launch dialog upon eval execution in SketchUp
    bundledCode += `\nAluDoorPilot::ReportDialog.show_report\n`;

    return res.status(200).json({
      success: true,
      message: '70S Sliding Door Full System App streamed successfully to RAM.',
      user: {
        id: user.id,
        email: user.email,
        tokens_remaining: tokens
      },
      code: bundledCode
    });

  } catch (err) {
    console.error('Streaming Engine Error:', err);
    return res.status(500).json({ success: false, error: 'Internal Server Error: ' + err.message });
  }
};
