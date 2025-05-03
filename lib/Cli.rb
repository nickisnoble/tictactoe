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
    loop do
      board = Board.new @options[:board_size]
      game = Game.new board
      game.signup_players @options[:players]
      game.play

      unless continue?
        puts "\n THANKS FOR PLAYING!"
        exit 0
      end
    end
  end

  private

    def continue?
      continue = Prompt.ask( "Would you like to play again? y/n/q" ).strip.downcase
      ["y", "yes"].include? continue
    end

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
