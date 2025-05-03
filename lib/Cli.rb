require 'optparse'

class Cli
  attr_reader :options

  def initialize arguments=[]
    @options = {
      players: 2,
      board_size: 9
    }

    read_options(arguments)
  end

  def start
    @game = Game.new
    @game.signup_players
    @game.run

    continue = Prompt.ask( "Would you like to play again? y/n/q" ).strip.downcase

    unless ["y", "yes"].include? continue
      puts "\n THANKS FOR PLAYING!"
      exit 0
    else
      start
    end
  end

  private

    def read_options from_args
      OptionParser.new do |opts|
        opts.banner = "Usage: ruby play.py --players 2 --board 9"

        opts.on(
          "-p", "--players COUNT", Integer, "Sets the number of players") { |count|
          @options[:players] = count
        }

        opts.accept(SquareNumber) do |n|
          n = n.to_i
          raise SquareError, "Must be a square number!" unless n > 0 && Math.sqrt(n) % 1 == 0

          n
        end

        opts.on("-b", "--board TILES", SquareNumber, "Sets the total tiles in the board." ){ |tiles|
          @options[:board_size] = tiles
        }
      end.parse(from_args)
    end

    class SquareNumber < Integer; end
    class SquareError < StandardError; end
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

  def self.log something, color: :cyan
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

module UI
  COLORS = {
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    reset: 0
  }

  def self.render_board board

  end
end