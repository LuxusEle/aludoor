const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const SUPABASE_URL = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://iefeibuhjupnpmcomxbg.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY || 'sb_publishable_3NjI86Sk0ppx1s3f7Hr8ZQ_KiGjuWy9';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const action = req.query.action || req.body?.action || 'list';

  try {
    // 1. List All Fabricator Quotes
    if (action === 'get_quotes') {
      const { data, error } = await supabase
        .from('alu_doors')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50);

      if (error) throw error;
      return res.status(200).json({ success: true, quotes: data });
    }

    // 2. Credit Tokens to User
    if (action === 'credit_tokens' && req.method === 'POST') {
      const { userId, tokensToAdd } = req.body;
      if (!userId || !tokensToAdd) {
        return res.status(400).json({ success: false, error: 'userId and tokensToAdd required.' });
      }

      // Update user metadata in Supabase
      const { data: userRecord, error: fetchErr } = await supabase.auth.admin.getUserById(userId);
      if (fetchErr) throw fetchErr;

      const currentTokens = userRecord.user.user_metadata?.tokens || 100;
      const newTokens = currentTokens + parseInt(tokensToAdd);

      const { data, error } = await supabase.auth.admin.updateUserById(userId, {
        user_metadata: { ...userRecord.user.user_metadata, tokens: newTokens }
      });

      if (error) throw error;
      return res.status(200).json({ success: true, user: data.user, tokens: newTokens });
    }

    // 3. List Users
    if (action === 'list_users') {
      const { data, error } = await supabase.auth.admin.listUsers();
      if (error) throw error;
      return res.status(200).json({ success: true, users: data.users });
    }

    // 4. Default: Return summary stats
    const { data: quotes } = await supabase.from('alu_doors').select('id, name, width_mm, height_mm, created_at').limit(10);
    return res.status(200).json({ success: true, stats: { recentQuotes: quotes || [] } });

  } catch (err) {
    console.error('Admin API Error:', err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
