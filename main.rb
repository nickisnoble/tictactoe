

class Cli
  def initialize arguments
    # TODO: parse these!
    #
  end

  def start
    @game = Game.new
    @game.signup_players
    @game.run

    banner = <<~WINNER
      ================
      WOOOOOOOOOOOOOO!
      #{@game.winner.piece} wins!
      #{@game.board}
      ================

      Would you like to play again? y/n/q
    WINNER

    continue = Prompt.ask( banner, color: @game.winner.color ).strip.downcase

    unless ["y", "yes"].include? continue
      puts "\n THANKS FOR PLAYING!"
      exit 0
    else
      start
    end
  end
end


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
        placement = Prompt.ask(
          "#{color.to_s.capitalize} Player. Where whould you like to place your #{piece}?",
          color: color,
          error: "Must be comma separated coordinates within range, eg: 1,3"
        ) { |input|
          input.include?(",") &&
          input.split(",").map { |c| c.strip.to_i }.all? {|n| @board.edge >= n && n > 0 }
        }

        x, y = placement.split(",").map { |c| c.strip.to_i }
        @board[x - 1, y - 1] = piece

        if !score.nil?
          @winner = player
          break
        end

        puts @winner.inspect
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

  def score
    result = [check_rows, check_diagonals, check_columns].compact&.first.strip
    return result unless result.nil? || result&.empty?
    nil
  end

  private

    def check_rows
      @board.state.chars.each_slice( @board.edge ).map do |row|
        return row[0].strip if is_match? row
      end

      nil
    end

    def check_columns
      @board.edge.times.each_with_index do |offset|
        column = @board.state.chars[offset..].each_slice(@board.edge).each.map(&:first)

        return column.first if is_match?(column)
      end

      nil
    end

    def check_diagonals
      tlbr = @board.state.chars
        .each_slice( @board.edge + 1 ).each.map(&:first)

      bltr = @board.state.chars[(@board.edge - 1)..]
        .each_slice(@board.edge - 1).to_a[..@board.edge-1].each.map(&:first)

      return tlbr.first if is_match?(tlbr)
      return bltr.first if is_match?(bltr)

      nil
    end

    def is_match? selection
      selection.uniq.size == 1 && !selection.first.empty?
    end
end

class Board
  attr_reader :edge
  attr_accessor :state # for testing

  def initialize size
    size = size.to_i
    @state = " " * size
    @edge = Math.sqrt(size)

    raise "Board must be square!" unless @edge % 1 == 0
    @edge = @edge.to_i
  end

  def []=(x, y, value)
    @state[x + y * @edge] = value
  end

  def [](x, y)
    @state[x + y * @edge]
  end

  def to_s
    <<~BOARD
      ╭#{ "───┬" * (@edge-1) }───╮
      #{
        @state.chars.each_slice(@edge)
          .map { |row| "│ " + row.join(" │ ") + " │" }
          .join("\n├#{ "───┼" * (@edge-1) }───┤\n")
      }
      ╰#{ "───┴" * (@edge-1) }───╯
    BOARD

  end
end

class Player
  attr_reader :color, :piece

  def initialize color, piece
    @color, @piece = color, piece
  end
end

class Prompt
  COLORS = {
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    reset: 0
  }

  def log something, color: :cyan
    puts colorize something color
  end

  def self.ask( something,
    color: :cyan,
    error: "That doesn't look right",
    validation: nil,
    &block
  )
    validator = block || validation

    loop do
      puts
      print colorize(something + " ", color)
      input = gets&.chomp&.strip
      if input.empty?
        puts "You gotta answer"
      elsif validator && !validator.call(input)
        puts error
      else
        return input
      end
    end
  end

  def self.number()
    ask(prompt, required: true, error: "Enter a positive number") { |i| i.match?(/^\d+$/) && i.to_i > 0 }.to_i
  end

  def self.select something, options, error: nil, &block
    puts
    puts colorize(something, :cyan)
    options.each_with_index do |option, index|
      puts colorize( "  (#{index + 1}) #{option}",
        # magic case for color highlights
        (COLORS.has_key?(option) ? option.to_sym : :blue)
      )
    end

    choice = ask("Enter choice (1–#{options.count}):", error: error || "Invalid choice") do |input|
      i = input.to_i
      return false unless i.between?(1, options.count)
      return false if block_given? && !block.call(options[i - 1])
      true
    end.to_i - 1

    options[ choice ]
  end

  private

    def self.colorize text, swatch
      "\e[#{COLORS[swatch] || COLORS[:reset]}m#{text}\e[0m"
    end
end

if __FILE__ == $0
  program = Cli.new ARGV
  program.start
end