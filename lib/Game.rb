class Game
  attr_reader :board, :winner
  def initialize with_board
    @board = with_board
    @players = []
  end

  def play
    round = 0
    winner = nil

    while winner.nil? do
      round += 1
      puts
      Prompt.log ("🮐" + "" * (@board.size - 1) ), :cyan
      Prompt.log "🮐🯁🯂🯃 ROUND #{round}!\n", :cyan

      @players.each do |player|
        piece = player.piece
        puts @board

        loop do
          placement = Prompt.ask(
            "#{piece} Player. Where whould you like to place your #{piece}?\n  (row, column)",
            error: "Must be comma separated coordinates within range, eg: 1,3"
          ) { |input|
            input.include?(",") &&
            input.split(",").map { |c| c.strip.to_i }.all? {|n| @board.size >= n && n > 0 }
          }

          row, column = placement.split(",").map { |c| c.strip.to_i }

          unless (@board[column - 1, row - 1] = piece)
            Prompt.log( "SPACE IS TAKEN!", color: :red )
            next
          end

          break
        end

        if @board.complete?
          if winner = @players.find {|p| @board.completed_with == p.piece }
            report_winner winner
          else
            report_cat
          end
          break
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

      @players << Player.new(piece)
    end
  end

  private

    def report_winner player
      puts "======= 🏆 ======"
      puts "WOOOOOOOOOOOOOOO!"
      puts "#{player.piece} wins!"
      puts @board
      puts "================="
    end

    def report_cat
        puts "== CAT'S ==========="
        puts "  |\\__/,|   (`\\"
        puts "_.|o o  |_   ) )"
        puts "=(((==(((= GAME ===="
    end
end
