require 'rubygems'
require 'spec'
require 'sinatra'
require 'sinatra/test/rspec'
require 'lib/rest'
require "rexml/document"
require 'ruby-debug'

#
# kind of a 'minimal model'
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

  @@people = nil

  def self.all
    #puts 'all'
    return @@people
  end

  def self.find_by_id(id)
    #puts "find_by_id #{id}"
    all.find {|f| f.id == id.to_i}
  end

  def self.reset!
    #puts 'reset!'
    @@people = [
      Person.new(1, 'one'),
      Person.new(2, 'two'),
      Person.new(3, 'three')
    ]
  end
end


def doc(xml)
  REXML::Document.new(xml.gsub(/>\s+</, '><').strip)
end

def response_should_be(status, body)
  @response.status.should == status
  doc(@response.body).to_s.should == body
end

def model_should_be(size)
  Person.all.size.should == size
end

def call_order_should_be(order, &block)
  Person.call_order = []
  block.call
  Person.call_order.map {|c| c[:method]}.should == order
end

def called_should_be(name, &block)
  Person.call_order = []
  block.call
  called = Person.call_order.map {|c| c[:called]}
  called.should_not be_nil
  called.each {|c| c.should == name }
end


describe Sinatra::REST do

  describe 'as inflection generator' do
    it "should conjugate a simple model name" do
      Sinatra::REST.conjugate(Person).should eql(%w(Person person people))
    end

    it "should conjugate a String as model name" do
      Sinatra::REST.conjugate('Person').should eql(%w(Person person people))
    end

    it "should conjugate a model name in camel cases" do
      Sinatra::REST.conjugate('SomePerson').should eql(%w(SomePerson some_person some_people))
    end

    it "should conjugate a model name without module" do
      Sinatra::REST.conjugate('MyModule::ModulePerson').should eql(%w(ModulePerson module_person module_people))
    end
  end


  describe 'as route generator' do

    before(:each) do
      Sinatra.application = nil
      @app = Sinatra.application

      response_mock = mock "Response"
      response_mock.should_receive(:"body=").with(nil).and_return(nil)
      @context = Sinatra::EventContext.new(nil, response_mock, nil)
    end


    it 'should not add editable url_for_* helpers' do
      rest Person, :editable => false

      methods = Sinatra::EventContext.instance_methods.grep /^url_for_people_/
      methods.size.should == 2

      @person = Person.new
      @person.id = 99

      @context.url_for_people_index.should == '/people'
      @context.url_for_people_show(@person).should == '/people/99'
    end

    it 'should not add editable restful routes' do
      @app.events.clear
      rest Person, :editable => false
      @app.events[:get].map {|r| r.path}.should == ["/people", "/people/:id"]
      @app.events[:post].map {|r| r.path}.should == []
      @app.events[:put].map {|r| r.path}.should == []
      @app.events[:delete].map {|r| r.path}.should == []
    end


    it 'should not add inputable url_for_* helpers' do
      rest Person, :inputable => false

      methods = Sinatra::EventContext.instance_methods.grep /^url_for_people_/
      methods.size.should == 5

      @person = Person.new
      @person.id = 99

      @context.url_for_people_index.should == '/people'
      @context.url_for_people_create.should == '/people'
      @context.url_for_people_show(@person).should == '/people/99'
      @context.url_for_people_update(@person).should == '/people/99'
      @context.url_for_people_destroy(@person).should == '/people/99'
    end

    it 'should not add inputable restful routes' do
      @app.events.clear
      rest Person, :inputable => false
      @app.events[:get].map {|r| r.path}.should == ["/people", "/people/:id"]
      @app.events[:post].map {|r| r.path}.should == ["/people"]
      @app.events[:put].map {|r| r.path}.should == ["/people/:id"]
      @app.events[:delete].map {|r| r.path}.should == ["/people/:id"]
    end


    it 'should add all url_for_* helpers' do
      rest Person

      methods = Sinatra::EventContext.instance_methods.grep /^url_for_people_/
      methods.size.should == 7

      @person = Person.new
      @person.id = 99

      @context.url_for_people_index.should == '/people'
      @context.url_for_people_new.should == '/people/new'
      @context.url_for_people_create.should == '/people'
      @context.url_for_people_show(@person).should == '/people/99'
      @context.url_for_people_edit(@person).should == '/people/99/edit'
      @context.url_for_people_update(@person).should == '/people/99'
      @context.url_for_people_destroy(@person).should == '/people/99'
    end

    it 'should add all restful routes' do
      @app.events.clear
      rest Person
      @app.events[:get].map {|r| r.path}.should == ["/people", "/people/new", "/people/:id", "/people/:id/edit"]
      @app.events[:post].map {|r| r.path}.should == ["/people"]
      @app.events[:put].map {|r| r.path}.should == ["/people/:id"]
      @app.events[:delete].map {|r| r.path}.should == ["/people/:id"]
    end

    it 'should support models, strings and integers' do
      @person = Person.new('id' => 99)

      @context.url_for_people_show(@person).should == '/people/99'
      @context.url_for_people_show(99).should == '/people/99'
      @context.url_for_people_show('99').should == '/people/99'
      lambda {@context.url_for_people_show(nil)}.should raise_error('can not generate url for nil')

      @context.url_for_people_edit(@person).should == '/people/99/edit'
      @context.url_for_people_edit(99).should == '/people/99/edit'
      @context.url_for_people_edit('99').should == '/people/99/edit'
      lambda {@context.url_for_people_edit(nil)}.should raise_error('can not generate url for nil')

      @context.url_for_people_update(@person).should == '/people/99'
      @context.url_for_people_update(99).should == '/people/99'
      @context.url_for_people_update('99').should == '/people/99'
      lambda {@context.url_for_people_update(nil)}.should raise_error('can not generate url for nil')

      @context.url_for_people_destroy(@person).should == '/people/99'
      @context.url_for_people_destroy(99).should == '/people/99'
      @context.url_for_people_destroy('99').should == '/people/99'
      lambda {@context.url_for_people_destroy(nil)}.should raise_error('can not generate url for nil')
    end
  end


  describe 'as restful service' do

    before(:each) do
      Sinatra.application = nil
      @app = Sinatra.application
      @app.configure :test do
        set :views, File.join(File.dirname(__FILE__), "views")
      end

      Person.reset!
      rest Person, :renderer => 'erb'
    end

    describe 'each method' do

      # index GET /models
      it 'should list all people on index by their id' do
        get_it '/people'
        response_should_be 200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>'
      end

      # new GET /models/new
      it 'should prepare an empty item on new' do
        get_it '/people/new'
        response_should_be 200, '<person><id/><name/></person>'
      end

      # create POST /models
      it 'should create an item on post' do
        post_it '/people', :name => 'new resource'
        response_should_be 302, 'person created'
      end

      # show GET /models/1
      it 'should show an item on get' do
        get_it '/people/1'
        response_should_be 200, '<person><id>1</id><name>one</name></person>'
      end

      # edit GET /models/1/edit
      it 'should get the item for editing' do
        get_it '/people/1/edit'
        response_should_be 200, '<person><id>1</id><name>one</name></person>'
      end

      # update PUT /models/1
      it 'should update an item on put' do
        put_it '/people/1', :name => 'another name'
        response_should_be 302, 'person updated'
      end

      # destroy DELETE /models/1
      it 'should destroy an item on delete' do
        delete_it '/people/1'
        response_should_be 302, 'person deleted'
      end

    end

    describe 'some use cases' do

      it 'should list all persons' do
        get_it '/people'
        response_should_be 200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>'
        model_should_be 3
      end

      it 'should read all persons' do
        get_it '/people'

        el_people = doc(body).elements.to_a("*/person/id")
        el_people.size.should == 3
        model_should_be 3

        get_it "/people/#{el_people[0].text}"
        response_should_be 200, '<person><id>1</id><name>one</name></person>'
        model_should_be 3

        get_it "/people/#{el_people[1].text}"
        response_should_be 200, '<person><id>2</id><name>two</name></person>'
        model_should_be 3

        get_it "/people/#{el_people[2].text}"
        response_should_be 200, '<person><id>3</id><name>three</name></person>'
        model_should_be 3
      end

      it 'should create a new person' do
        get_it '/people'
        response_should_be 200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>'
        model_should_be 3

        get_it '/people/new'
        response_should_be 200, '<person><id/><name/></person>'
        model_should_be 3

        post_it '/people', {:name => 'four'}
        response_should_be 302, 'person created'
        model_should_be 4

        get_it '/people'
        response_should_be 200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person><person><id>4</id></person></people>'
        model_should_be 4
      end

      it 'should update a person' do
        get_it '/people/2'
        response_should_be 200, '<person><id>2</id><name>two</name></person>'
        model_should_be 3

        put_it '/people/2', {:name => 'tomorrow'}
        response_should_be 302, 'person updated'
        model_should_be 3

        get_it '/people/2'
        response_should_be 200, '<person><id>2</id><name>tomorrow</name></person>'
        model_should_be 3
      end

      it 'should delete a person' do
        get_it '/people'
        response_should_be 200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>'
        model_should_be 3

        delete_it '/people/2'
        response_should_be 302, 'person deleted'
        model_should_be 2

        get_it '/people'
        response_should_be 200, '<people><person><id>1</id></person><person><id>3</id></person></people>'
        model_should_be 2

        get_it '/people/2'
        response_should_be 404, 'person not found'
        model_should_be 2
      end

    end

    describe 'life-cycle' do

      before(:each) do
        Person.class_eval '@call_order = []; def self.call_order; @call_order; end; def self.call_order=(arr); @call_order = arr; end'
        rest Person, :renderer => 'erb' do
          def before(name)
            Person.call_order << {:method => :before, :called => name}
          end

          def after(name)
            Person.call_order << {:method => :after, :called => name}
          end

          def index
            Person.call_order << {:method => :index, :called => :index}
            super
          end

          def new
            Person.call_order << {:method => :new, :called => :new}
            super
          end

          def create
            Person.call_order << {:method => :create, :called => :create}
            super
          end

          def show
            Person.call_order << {:method => :show, :called => :show}
            super
          end

          def edit
            Person.call_order << {:method => :edit, :called => :edit}
            super
          end

          def update
            Person.call_order << {:method => :update, :called => :update}
            super
          end

          def destroy
            Person.call_order << {:method => :destroy, :called => :destroy}
            super
          end
        end
      end

      it 'should call :before and :after in the right order' do
        call_order_should_be [:before, :index, :after]   do get_it    '/people' end
        call_order_should_be [:before, :new, :after]     do get_it    '/people/new' end
        call_order_should_be [:before, :create, :after]  do post_it   '/people', :name => 'initial name' end
        call_order_should_be [:before, :show, :after]    do get_it    '/people/1' end
        call_order_should_be [:before, :edit, :after]    do get_it    '/people/1/edit' end
        call_order_should_be [:before, :update, :after]  do put_it    '/people/1', :name => 'new name' end
        call_order_should_be [:before, :destroy, :after] do delete_it '/people/1' end
      end

      it 'should call :before and :after with the name of the called method' do
        called_should_be :index   do get_it    '/people' end
        called_should_be :new     do get_it    '/people/new' end
        called_should_be :create  do post_it   '/people', :name => 'initial name' end
        called_should_be :show    do get_it    '/people/1' end
        called_should_be :edit    do get_it    '/people/1/edit' end
        called_should_be :update  do put_it    '/people/1', :name => 'new name' end
        called_should_be :destroy do delete_it '/people/1' end
      end

    end

  end

end


