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

  def self.ask query, color: :cyan, error: "Invalid input"
    loop do
      log query, color
      print "\n☏ "
      input = gets.chomp.strip
      return input if !block_given? || block_given? && yield(input)
      log error, :red
    end
  end

  def self.select query, choices, error: "Invalid option!", &validation
    choices.each_with_index { |choice, i| log "  (#{i+1}) #{choice}", :cyan }
    chosen = ask(query, error:) do |input|
      in_range = input.to_i.between?(1, choices.size)
      in_range && (validation ? validation.call(input) : true)
    end.to_i - 1

    choices[chosen]
  end

  def self.log text, color = :reset
    code = COLORS[color] || COLORS[:reset]
    print "\e[#{code}m"
    puts text
    print "\e[0m"
  end
end