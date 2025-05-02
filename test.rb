require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)
require_relative 'main'

class BoardTest < Minitest::Test
  def test_must_be_square
    assert_raises(RuntimeError) do
      Board.new 5
    end
  end

  def test_prints_nicely
    board = Board.new 64

    # account for padding && borders
    assert_equal 8 * 2 + 1, board.to_s.split("\n").length
  end
end

class GameTest < Minitest::Test
  def setup
    @game = Game.new
  end

  def test_can_win_with_rows
    winners = [
      "XXX456789",
      "123XXX789",
      "123456XXX"
    ]

    winners.each do |w|
      @game.board.state = w
      assert_equal "X", @game.score
    end
  end

  def test_can_win_with_columns
    winners = [
      "X23X56X89",
      "1X34X67X9",
      "12X45X78X"
    ]

    winners.each do |w|
      @game.board.state = w
      assert_equal "X", @game.score
    end
  end

  def test_can_win_with_TLBR_diagonal
    @game.board.state = "X234X678X"
    assert_equal "X", @game.score
  end

  def test_can_win_with_BLTR_diagonal
    @game.board.state = "12X4X6X89"
    assert_equal "X", @game.score
  end

  def test_cannot_win_with_blanks
    @game.board.state = " " * 9
    assert_nil @game.score
  end

  def test_other_states_that_should_not_win
    losers = [
      "2  23 3  ",
    ]

    losers.each do |loser|
      @game.board.state = loser
      assert_nil @game.score, loser
    end
  end
end