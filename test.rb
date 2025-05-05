require 'pty'
require 'expect'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

Dir["./lib/*.rb"].each {|file| require file }

class GameTest < Minitest::Test
  def test_a_normal_game
    PTY.spawn("ruby play.rb") do |stdout, stdin, pid|
      output = +""
      Thread.new { stdout.each { |line| output << line } }

      %w[
        X
        O
        1,1
        2,3
        2,2
        1,3
        3,3
      ].each { |input| stdin.puts(input) }

      sleep 3

      assert_match(/X wins/i, output)
    end
  end

  def test_a_cats_game
    PTY.spawn("ruby play.rb") do |stdout, stdin, pid|
      stdout.expect(/PLAYER 1.*Choose your glyph!/, 2)

      %w[
        X
        O
        1,1
        1,2
        1,3
        2,2
        2,1
        2,3
        3,2
        3,1
        3,3
      ].each { |input| stdin.puts(input) }

      result = stdout.expect(/CAT'S/, 2)
      refute_nil result
      refute_empty result
    end
  end
end

class CliTest < Minitest::Test
  def test_can_be_called_with_blank_args
    assert_silent do
      Cli.new
    end
  end

  def test_parses_args_correctly
    cli = Cli.new [
      "--players", "3",
      "--board", "16"
    ]
    assert_equal 3, cli.options[:players]
    assert_equal 16, cli.options[:board_size]
  end

  def test_rejects_bad_args
    error = assert_raises(Cli::SquareError) {
      Cli.new ["--board", "5"]
    }

    assert_equal "Must be a square number!", error.message
  end
end

class BoardTest < Minitest::Test
  def setup
    @board = Board.new 9
  end

  def test_must_be_square
    assert_raises(RuntimeError) do
      Board.new 5
    end
  end

  def test_can_differently_sized
    assert_silent do
      Board.new 4
      Board.new 64
      Board.new 25
    end
  end

  def test_prints_nicely
    padded_edge = @board.size * 2 + 1
    assert_equal padded_edge, @board.to_s.split("\n").length
  end


  def test_can_win_with_rows
    winners = [
      "XXX45678 ",
      " 23XXX789",
      " 23456XXX"
    ]

    winners.each do |w|
      @board.state = w
      assert_equal "X", @board.check_for_winner
    end
  end

  def test_can_win_with_columns
    winners = [
      "X23X56X8 ",
      "1X34X67X ",
      " 2X45X78X"
    ]

    winners.each do |w|
      @board.state = w
      assert_equal "X", @board.check_for_winner
      assert_equal true, @board.complete?
    end
  end

  def test_can_win_with_TLBR_diagonal
    @board.state = "X 34X678X"
    assert_equal "X", @board.check_for_winner
    assert_equal true, @board.complete?
  end

  def test_can_win_with_BLTR_diagonal
    @board.state = " 2X4X6X89"
    assert_equal "X", @board.check_for_winner
    assert_equal true, @board.complete?
  end

  def test_cannot_win_with_blanks
    @board.state = " " * 9
    assert_nil @board.check_for_winner
    assert_equal false, @board.complete?
  end

  def test_cats_game_is_still_complete
    @board.state = "123456789"
    assert_equal "🙀", @board.check_for_winner
    assert_equal true, @board.complete?
  end
end
