class Game
  attr_reader :board, :winner
  def initialize with_board
    @board = with_board
    @players = []
  end

  def play
    round = 0
    winner = nil
    rounds = "🯰🯱🯲🯳🯴🯵🯶🯷🯸🯹"

    while winner.nil? do
      round += 1
      puts
      Prompt.log ("🮐" + "" * @board.size - 1 ), :cyan
      Prompt.log "🮐🯁🯂🯃 ROUND #{rounds[round-1]}!\n", :cyan

      @players.each do |player|
        color = player.color
        piece = player.piece

        render_board color

        loop do
          placement = Prompt.ask(
            "#{color.to_s.capitalize} Player. Where whould you like to place your #{piece}?\n  (row, column)",
            color: color,
            error: "Must be comma separated coordinates within range, eg: 1,3"
          ) { |input|
            input.include?(",") &&
            input.split(",").map { |c| c.strip.to_i }.all? {|n| @board.size >= n && n > 0 }
          }

          row, column = placement.split(",").map { |c| c.strip.to_i }

          if @board[column - 1, row - 1] = piece
            break
          else
            Prompt.log( "SPACE IS TAKEN!", color: :red )
          end
        end

        if @board.complete?
          if winner = @players.find {|p| @board.completed_with == p.piece }
            report_winner winner
          else
            report_cat
          end
        end
      end
    end
  end

  def signup_players count
    while @players.size < count
      Prompt.log "\nPLAYER #{@players.size + 1}, APPROACH!\n"

      piece = Prompt.ask(
        "Choose your glyph!\n  (Eg. X or O or ❖ or 𐩕)",
        error: "Must be only one character, unused by another player!") do |c|
          c.length == 1 && !@players.map(&:piece).include?(c)
      end

      valid_colors = Prompt::COLORS.keys.filter do |c|
        ![:reset, :red, :cyan, :yellow, :pink].include? c
      end

      color = Prompt.select( "What color would you like to play as?", valid_colors, error: "Players can't use the same colors!") { |choice|
        !@players.map(&:color).include? choice
      }

      @players << Player.new(color, piece)
    end
  end

  private

    def report_winner player
      banner = <<~WINNER
        ======= 🏆 ======
        WOOOOOOOOOOOOOO!
        #{player.piece} wins!
        #{@board}
        =================
      WINNER

      Prompt.log banner, player.color
    end

    def report_cat
      banner = <<~MEOW
        == CAT'S ===========
            |\\__/,|   (`\
          _.|o o  |_   ) )
        =(((==(((= GAME ====
      MEOW

      Prompt.log banner, :yellow
    end

    def render_board in_color=:reset
      board = <<~BOARD
        ╭#{ "───┬" * (@board.size-1) }───╮
        #{
          @board.tiles.each_slice(@board.size)
            .map { |row| "│ " + row.join(" │ ") + " │" }
            .join("\n├#{ "───┼" * (@board.size-1) }───┤\n")
        }
        ╰#{ "───┴" * (@board.size-1) }───╯
      BOARD

      Prompt.log board, in_color
    end
end
