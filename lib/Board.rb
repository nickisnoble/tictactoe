class Board
  attr_reader :size, :completed_with
  attr_accessor :state

  def initialize tile_count
    @state = " " * tile_count
    @size = Math.sqrt(tile_count)
    @completed_with = nil

    raise "Board must be square!" unless @size % 1 == 0
    @size = @size.to_i
  end

  def []=(x, y, piece)
    return if complete?
    target = x + y * @size
    @state[target] = piece if @state[target] == " "
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

  def check_for_winner
    counts = tiles.tally
    counts.each do |piece, count|
      next if piece.strip.empty?
      next if count < @size
      next unless winning? piece
      return @completed_with = piece
    end

    # check for cats
    return @completed_with = "🙀" if !tiles.uniq.include?(" ")

    nil
  end

  def complete?
    check_for_winner
    !@completed_with.nil?
  end

  private


    def win_conditions
      # only needs to be calculated once per board
      @win_conditions ||= begin
        possible_wins = []

        @size.times do |y| # rows
          possible_wins << @size.times.map {|x| x + y * @size }
        end

        @size.times do |x| # columns
          possible_wins << @size.times.map {|y| x + y * @size }
        end

        # diags
        possible_wins << @size.times.map {|i| i * (@size + 1) }
        possible_wins << @size.times.map {|i| (i + 1) * (@size - 1) }
      end
    end

    def winning? piece
      return false if piece.strip.empty?
      win_conditions.each do |selections|
        range = selections.map { |i| tiles[i] }
        next unless range.uniq == [piece]
        return true
      end
      false
    end
end