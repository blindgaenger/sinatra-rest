require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'sinatra/base'
require 'sinatra/rest'

Sinatra::Default.set(:environment, :test)
Test::Unit::TestCase.send :include, Sinatra::Test


# Sets up a Sinatra::Base subclass defined with the block
# given. Used in setup or individual spec methods to establish
# the application.
def mock_app(&block)
  base = Sinatra::Application
  @app = Sinatra.new(base) do
    set :views, File.dirname(__FILE__) + '/views'
          
    not_found do
      'route not found'
    end
  end
  @app.instance_eval(&block) if block_given?
end


#
# normalize for easier testing
def normalized_response
  return status, body.gsub(/>\s+</, '><').strip
end

# index GET /models
def index(url)
  get url
  normalized_response
end

# new GET /models/new
def new(url)
  get url
  normalized_response
end

# create POST /models
def create(url, params={})
  post url, params
  normalized_response
end

# show GET /models/1
def show(url)
  get url
  normalized_response
end

# edit GET /models/1/edit
def edit(url)
  get url
  normalized_response
end

# update PUT /models/1
def update(url, params={})
  put url, params
  normalized_response
end

# destroy DELETE /models/1
def destroy(url)
  delete url
  normalized_response
end


##
## kind of a 'minimal model'
class Person
  attr_accessor :id
  attr_accessor :name

  def initialize(*args)
    #puts "new #{args.inspect}"
    if args.size == 0
      @id = nil
      @name = nil
    elsif args.size == 2
      @id = args[0].to_i
      @name = args[1]
    else args.size == 1
      update_attributes(args[0])
    end
  end

  def save
    #puts "save #{@id}"
    @@people << self
    self.id = @@people.size
  end

  def update_attributes(hash)
    #puts "update_attributes #{hash.inspect}"
    unless hash.empty?
      @id = hash['id'].to_i if hash.include?('id')
      @name = hash['name'] if hash.include?('name')
    end
  end

  def self.delete(id)
    #puts "delete #{id}"
    @@people.delete_if {|person| person.id == id.to_i}
  end

  @@people = []

  def self.all
    #puts 'all'
    return @@people
  end

  def self.find_by_id(id)
    #puts "find_by_id #{id}"
    all.find {|f| f.id == id.to_i}
  end

  def self.clear!
    @@people = []
  end

  def self.reset!
    clear!
    Person.new(1, 'one').save
    Person.new(2, 'two').save
    Person.new(3, 'three').save
  end
end


