class Player
  attr_reader :color, :piece

  def initialize color, piece
    @color, @piece = color, piece
  end
end