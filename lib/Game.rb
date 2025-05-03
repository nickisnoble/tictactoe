class Game
  attr_reader :board, :winner
  def initialize(options={ players: 2, board: 9 })
    @options = options
    @board = Board.new(options[:board])
    @players = []
  end

  def run
    round = 0
    @winner = false

    while !@winner do
      round += 1
      puts
      puts "=" * 9
      puts "  ROUND #{round}!\n"

      @players.each do |player|
        color = player.color
        piece = player.piece
        puts
        puts @board

        loop do
          placement = Prompt.ask(
            "#{color.to_s.capitalize} Player. Where whould you like to place your #{piece}?",
            color: color,
            error: "Must be comma separated coordinates within range, eg: 1,3"
          ) { |input|
            input.include?(",") &&
            input.split(",").map { |c| c.strip.to_i }.all? {|n| @board.size >= n && n > 0 }
          }

          x, y = placement.split(",").map { |c| c.strip.to_i }

          # flipping these might feel more intuitive while playing
          # "row, column" vs current "column, row"
          if @board[x - 1, y - 1] = piece
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

  def signup_players
    while @players.count < @options[:players]
      puts "\nPLAYER #{@players.count + 1}, APPROACH!\n"

      piece = Prompt.ask("Type a glyph:", error: "Must be only one character, unused by another player!") { |c| c.length == 1 && !@players.map(&:piece).include?(c)
    }

      color = Prompt.select( "What color would you like to play as?", Prompt::COLORS.keys.filter {|c| c != :reset }, error: "Someone already took that!") { |choice| !@players.map(&:color).include? choice }

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

      Prompt.log( banner, color: player.color )
    end

    def report_cat
      banner = <<~MEOW
        == CAT'S ===========
            |\\__/,|   (`\
          _.|o o  |_   ) )
        =(((==(((= GAME ====
      MEOW

      Prompt.log( banner, color: :yellow )
    end

    def complete?

    end
end
