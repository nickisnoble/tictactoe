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
      "XXX456789",
      "123XXX789",
      "123456XXX"
    ]

    winners.each do |w|
      @board.state = w
      assert_equal "X", @board.completed_with
    end
  end

  def test_can_win_with_columns
    winners = [
      "X23X56X89",
      "1X34X67X9",
      "12X45X78X"
    ]

    winners.each do |w|
      @board.state = w
      assert_equal true, @board.complete?
      assert_equal "X", @board.completed_with
    end
  end

  def test_can_win_with_TLBR_diagonal
    @board.state = "X234X678X"
    assert_equal true, @board.complete?
    assert_equal "X", @board.completed_with
  end

  def test_can_win_with_BLTR_diagonal
    @board.state = "12X4X6X89"
    assert_equal true, @board.complete?
    assert_equal "X", @board.completed_with
  end

  def test_cannot_win_with_blanks
    @board.state = " " * 9
    assert_equal false, @board.complete?
    assert_nil @board.completed_with
  end
end
