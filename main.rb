

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
          input.split(",").map { |c| c.strip.to_i }.all? {|n| @board.size >= n && n > 0 }
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
end

class Board
  attr_reader :size
  attr_accessor :state

  def initialize tile_count
    @state = " " * tile_count
    @size = Math.sqrt(tile_count)

    raise "Board must be square!" unless @size % 1 == 0
    @size = @size.to_i
  end

  def []=(x, y, value)
    @state[x + y * @size] = value

    # could check if *just* this row / col / diag triggers a win, for less loops
  end

  def [](x, y)
    @state[x + y * @size]
  end

  def tiles
    @state.chars
  end

  def to_s
    <<~BOARD
      ╭#{ "───┬" * (@size-1) }───╮
      #{
        tiles.each_slice(@size)
          .map { |row| "│ " + row.join(" │ ") + " │" }
          .join("\n├#{ "───┼" * (@size-1) }───┤\n")
      }
      ╰#{ "───┴" * (@size-1) }───╯
    BOARD
  end

  def complete?
    !!completed_with
  end

  Checker = Data.define(:step, :sequencer)
  def completed_with
    [
      Checker.new(@size, ->(step, index) { step * @size + index }), # rows
      Checker.new(@size, ->(step, index) { step + index * @size }), # columns
      Checker.new(1,     ->(_, index)    { index * (@size + 1) }), # desc_diag
      Checker.new(1,     ->(_, index)    { (index + 1) * (@size - 1) }), # asc_diag
    ].each do |check|
      check.step.times do |step|
        range = @size.times.map { |index|
          tiles[check.sequencer.call(step, index)]
        }

        return range.first if is_match?(range)
      end
    end

    nil
  end

  private
    def is_match? selection
      !selection.first.strip.empty? && selection.uniq.size == 1
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