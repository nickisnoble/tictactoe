require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)
require_relative 'main'


class GameTest < Minitest::Test
  def setup
    @game = Game.new
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
