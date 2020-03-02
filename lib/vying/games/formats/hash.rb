# frozen_string_literal: true

module Vying::Games
  class HashFormat < Format

    def self.type
      :hash
    end

    def load(h)
      rules = Rules.find(h['rules']['id'], h['rules']['version'])

      options = {}
      if h['options']
        h['options'].each { |k, v| options[k.intern] = v }
      end

      if h['random']
        g = Game.new(rules, h['random']['seed'], options)
      else
        g = Game.new(rules, options)
      end

      h['history'].each do |mh|
        move = Move.new(mh['move'], mh['by'].intern)
        move = move.stamp(mh['at'])

        g.append(move)
      end

      h['players'].each do |k, v|
        if v['user']
          g[k.intern].user = User.new(v['user']['username'], v['user']['id'])
        end
      end

      %w(id unrated time_limit).each do |k|
        g.instance_variable_set("@#{k}", h[k]) if h.key?(k)
      end

      %w(created_at last_move_at).each do |k|
        g.history.instance_variable_set("@#{k}", h[k]) if h.key?(k)
      end

      g
    end

    def dump(game)
      h = { 'rules' => { 'name'    => game.rules.name,
                         'id'      => game.rules.to_sc,
                         'version' => game.rules.version } }

      h['history'] = game.history.moves.map do |move|
        { 'move' => move.to_s, 'by' => move.by.to_s, 'at' => move.at }
      end

      h['players'] = {}
      game.players.each do |player|
        ph = {}
        if player.user
          ph['user'] = { 'username' => player.username, 'id' => player.user.id }
        end

        if game.final?
          ph['winner'] = true  if player.winner?
          ph['loser']  = true  if player.loser?
        end

        ph['score'] = player.score if game.has_score?

        h['players'][player.name.to_s] = ph
      end

      unless game.options.empty?
        h['options'] = {}
        game.options.each { |name, value| h['options'][name.to_s] = value }
      end

      if game.final?
        h['final'] = true
        h['draw'] = game.draw?
      end

      if game.random? && (game.deterministic? || game.final?)
        h['random'] = { 'seed' => game.seed }
      end

      h['id']           = game.id            if game.id
      h['unrated']      = game.unrated       if game.unrated
      h['time_limit']   = game.time_limit    if game.time_limit
      h['created_at']   = game.created_at    if game.created_at
      h['last_move_at'] = game.last_move_at  if game.last_move_at

      h
    end

  end
end
