Dir["./lib/*.rb"].each {|file| require file }

begin
  Cli.new(ARGV).start
rescue Interrupt
  puts "\nGoodbye"
  exit 0
end
