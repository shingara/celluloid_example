require 'celluloid'

class Person
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(name, parent=nil)
    @name = name
    @parent = parent
    @turn = 1
  end

  def action
    info "person #{@name} : action #{@turn}"
    @turn += 1
    give_birth if @turn % 5 == 0
  end

  def give_birth
    info 'new person?'
    publish('birth', @name)
  end

end

class God
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize
    @people = []
    add_person
  end
  attr_reader :people

  def run
    @subscriber ||= subscribe('birth', :add_person)

    @people.each {|person| person.async.action }
    after(1) { run }
  end

  def add_person(topic='', parent=nil)
    info 'birth'
    @people << Person.new("person-#{people.size}", parent)
  end

  def stop
    @people.each {|person| person.terminate }
    terminate
  end
end

god = God.new
begin
  god.async.run
  sleep
rescue Interrupt
  god.stop
  exit(0)
end
