# =============================================================================
# ALU DOOR PILOT - 1D LINEAR BAR NESTING & BATCH PROJECT OPTIMIZER
# -----------------------------------------------------------------------------
# Solves the 1D Cutting Stock Problem across single or multiple doors/windows
# for standard 6000mm extrusion bars (per-bar procurement pricing).
# =============================================================================

require 'json'

module AluDoorPilot
  module NestingEngine
    extend self

    DEFAULT_STOCK_LEN = 6000.0 # mm (Standard 6.0m stock bar)
    DEFAULT_BLADE_KERF = 3.5   # mm (Saw blade kerf)
    USABLE_OFFCUT_MIN = 500.0  # mm (Offcuts >= 500mm are reusable)

    # 1. Optimize cutting pieces for a single profile type
    def optimize_cutting_stock(required_cuts, stock_len_mm = DEFAULT_STOCK_LEN, kerf_mm = DEFAULT_BLADE_KERF)
      sorted_pieces = required_cuts.sort_by { |p| -p[:length_mm] }
      bars = []

      sorted_pieces.each do |piece|
        piece_len = piece[:length_mm]
        placed = false

        bars.each do |bar|
          kerf_needed = bar[:cuts].empty? ? 0.0 : kerf_mm
          if (bar[:used_length_mm] + kerf_needed + piece_len) <= stock_len_mm
            bar[:cuts] << piece
            bar[:used_length_mm] += (kerf_needed + piece_len)
            bar[:cuts_count] += 1
            placed = true
            break
          end
        end

        unless placed
          bars << {
            bar_index: bars.length + 1,
            stock_length_mm: stock_len_mm,
            used_length_mm: piece_len,
            cuts_count: 1,
            cuts: [piece]
          }
        end
      end

      total_stock_used_mm = bars.length * stock_len_mm
      total_net_cuts_mm = 0.0
      total_kerf_waste_mm = 0.0
      total_scrap_offcut_mm = 0.0
      total_reusable_offcut_mm = 0.0

      bars.each do |bar|
        cuts_sum = bar[:cuts].sum { |c| c[:length_mm] }
        kerf_sum = (bar[:cuts].length - 1) * kerf_mm
        rem = stock_len_mm - (cuts_sum + kerf_sum)

        bar[:net_cuts_length_mm] = cuts_sum.round(1)
        bar[:kerf_waste_mm] = kerf_sum.round(1)
        bar[:remaining_offcut_mm] = rem.round(1)
        bar[:is_reusable_offcut] = rem >= USABLE_OFFCUT_MIN
        bar[:efficiency_percent] = ((cuts_sum / stock_len_mm) * 100.0).round(1)

        total_net_cuts_mm += cuts_sum
        total_kerf_waste_mm += kerf_sum
        if bar[:is_reusable_offcut]
          total_reusable_offcut_mm += rem
        else
          total_scrap_offcut_mm += rem
        end
      end

      overall_yield_pct = total_stock_used_mm > 0 ? ((total_net_cuts_mm / total_stock_used_mm) * 100.0).round(1) : 100.0

      {
        total_stock_bars: bars.length,
        stock_length_mm: stock_len_mm,
        blade_kerf_mm: kerf_mm,
        total_net_profile_length_m: (total_net_cuts_mm / 1000.0).round(2),
        total_stock_pulled_m: (total_stock_used_mm / 1000.0).round(2),
        overall_yield_percent: overall_yield_pct,
        total_scrap_waste_percent: (100.0 - overall_yield_pct).round(1),
        total_reusable_offcuts_m: (total_reusable_offcut_mm / 1000.0).round(2),
        nested_bars: bars
      }
    end

    # 2. Batch project nesting across all profile numbers
    def nest_all_profiles(profile_bom_items, stock_len_mm = DEFAULT_STOCK_LEN, kerf_mm = DEFAULT_BLADE_KERF)
      grouped_cuts = {}
      profile_bom_items.each do |item|
        code = item[:code]
        grouped_cuts[code] ||= {
          code: code,
          description: item[:description],
          unit_wt_kg_m: item[:wt_kg_m],
          group: item[:group],
          pieces: []
        }
        item[:qty].times do |i|
          grouped_cuts[code][:pieces] << {
            cut_id: format('%s-%s-%d', code, item[:role].gsub(/\s+/, '_'), i + 1),
            role: item[:role],
            door_tag: item[:door_tag] || 'D1',
            length_mm: item[:cut_len_mm].to_f.round(1),
            angle_left: item[:angle_l] || 90,
            angle_right: item[:angle_r] || 90
          }
        end
      end

      results_by_profile = []
      total_bars_all = 0
      total_weight_all = 0.0

      grouped_cuts.each do |code, p_data|
        opt = optimize_cutting_stock(p_data[:pieces], stock_len_mm, kerf_mm)
        total_bars_all += opt[:total_stock_bars]
        net_wt = (opt[:total_net_profile_length_m] * p_data[:unit_wt_kg_m]).round(2)
        stock_wt = (opt[:total_stock_pulled_m] * p_data[:unit_wt_kg_m]).round(2)
        total_weight_all += net_wt

        results_by_profile << {
          profile_code: code,
          description: p_data[:description],
          unit_wt_kg_m: p_data[:unit_wt_kg_m],
          group: p_data[:group],
          total_pieces: p_data[:pieces].length,
          stock_bars_needed: opt[:total_stock_bars],
          net_weight_kg: net_wt,
          stock_weight_kg: stock_wt,
          nesting_summary: opt
        }
      end

      {
        total_unique_profiles: results_by_profile.length,
        total_stock_bars_to_pull: total_bars_all,
        total_net_weight_kg: total_weight_all.round(2),
        profile_nesting: results_by_profile
      }
    end
  end
end
