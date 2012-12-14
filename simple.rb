require 'celluloid'

class Hello
  include Celluloid

  def initialize(x)
    @x = x
    @nb_sleep = 0
    @finish = false
  end
  attr_reader :nb_sleep
  attr_reader :finish

  def need_rest
    @x.times do
      sleep 1
      @nb_sleep += 1
    end
    @finish = true
  end
end

hellos = []
20.times do |i|
  h = Hello.new(i)
  h.need_rest!
  hellos << h
end

while true
  hellos.select(&:finish).each do |hello|
    p hello.nb_sleep
    hello.terminate
    hellos.delete(hello)
  end
  break if hellos.empty?
end
