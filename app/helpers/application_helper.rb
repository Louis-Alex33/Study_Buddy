module ApplicationHelper
  def rank_badge(rank, division)
    rank_colors = {
      'iron' => '#6B5B4F',
      'bronze' => '#CD7F32',
      'silver' => '#C0C0C0',
      'gold' => '#FFD700',
      'platinum' => '#00CED1',
      'diamond' => '#B9F2FF',
      'master' => '#8B00FF',
      'grandmaster' => '#FF1493',
      'challenger' => '#FF6B00'
    }

    color = rank_colors[rank] || rank_colors['iron']
    content_tag(:span, "#{rank.capitalize} #{division}",
                class: 'rank-badge',
                style: "background: #{color}; color: white; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600;")
  end

  def rank_icon_inline(rank)
    content_tag(:span, class: 'rank-icon-inline', style: "margin-left: 0.375rem;") do
      render partial: 'multiplayer/rank_logo', locals: { rank: rank }
    end
  end
end
