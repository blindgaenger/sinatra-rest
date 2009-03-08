require File.dirname(__FILE__) + '/helper'

describe 'some use cases' do

  def total_models
    Person.all.size
  end

  require "rexml/document"
  def doc(xml)
    REXML::Document.new(xml.gsub(/>\s+</, '><').strip)
  end

  before(:each) do
    Person.reset!
    mock_rest Person
  end

  it 'should list all persons' do
    get '/people'
    normalized_response.should == [200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>']
    total_models.should == 3
  end

  it 'should create a new person' do
    get '/people'
    normalized_response.should == [200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>']
    total_models.should == 3

    get '/people/new'
    normalized_response.should == [200, '<person><id></id><name></name></person>']
    total_models.should == 3

    post '/people', {:name => 'four'}
    normalized_response.should == [302, 'person created']
    total_models.should == 4

    get '/people'
    normalized_response.should == [200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person><person><id>4</id></person></people>']
    total_models.should == 4
  end

  it 'should read all persons' do
    get '/people'

    el_people = doc(body).elements.to_a("*/person/id")
    el_people.size.should == 3
    total_models.should == 3

    get "/people/#{el_people[0].text}"
    normalized_response.should == [200, '<person><id>1</id><name>one</name></person>']
    total_models.should == 3

    get "/people/#{el_people[1].text}"
    normalized_response.should == [200, '<person><id>2</id><name>two</name></person>']
    total_models.should == 3

    get "/people/#{el_people[2].text}"
    normalized_response.should == [200, '<person><id>3</id><name>three</name></person>']
    total_models.should == 3
    
    get "/people/99"
    normalized_response.should == [404, 'route not found']
    total_models.should == 3
  end

  it 'should update a person' do
    get '/people/2'
    normalized_response.should == [200, '<person><id>2</id><name>two</name></person>']
    total_models.should == 3

    put '/people/2', {:name => 'tomorrow'}
    normalized_response.should == [302, 'person updated']
    total_models.should == 3

    get '/people/2'
    normalized_response.should == [200, '<person><id>2</id><name>tomorrow</name></person>']
    total_models.should == 3
  end

  it 'should destroy a person' do
    get '/people'
    normalized_response.should == [200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>']
    total_models.should == 3

    delete '/people/2'
    normalized_response.should == [302, 'person destroyed']
    total_models.should == 2

    get '/people'
    normalized_response.should == [200, '<people><person><id>1</id></person><person><id>3</id></person></people>']
    total_models.should == 2

    get '/people/2'
    normalized_response.should == [404, 'route not found']
    total_models.should == 2
  end

end
