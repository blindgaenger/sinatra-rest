require File.dirname(__FILE__) + '/helper'

describe 'url helpers' do

  it 'should generate the correct urls for the model' do
    mock_rest Person do
      person = Person.new(99, 'foo')
      url_for_people_create.should == '/people'
      url_for_people_destroy(person).should == '/people/99'
      url_for_people_edit(person).should == '/people/99/edit'
      url_for_people_index.should == '/people'
      url_for_people_new.should == '/people/new'
      url_for_people_show(person).should == '/people/99'
      url_for_people_update(person).should == '/people/99'
    end
  end

  it 'should add :all helpers' do
    mock_rest(Person) { methods.grep(/^url_for_people_/).sort }.should == [
          "url_for_people_create",
          "url_for_people_destroy",
          "url_for_people_edit",
          "url_for_people_index",
          "url_for_people_new",
          "url_for_people_show",
          "url_for_people_update",
    ]
  end

  it 'should add :readable helpers' do
      mock_rest(Person, :routes => :readable) { methods.grep(/^url_for_people_/).sort }.should == [
          "url_for_people_index",
          "url_for_people_show",
      ]
  end

  it 'should add :writeable helpers' do
      mock_rest(Person, :routes => :writeable) { methods.grep(/^url_for_people_/).sort }.should == [
          "url_for_people_create",
          "url_for_people_destroy",
          "url_for_people_index",
          "url_for_people_show",
          "url_for_people_update",
      ]
  end

  it 'should add :editable helpers' do
      mock_rest(Person, :routes => :editable) { methods.grep(/^url_for_people_/).sort }.should == [
          "url_for_people_create",
          "url_for_people_destroy",
          "url_for_people_edit",
          "url_for_people_index",
          "url_for_people_new",
          "url_for_people_show",
          "url_for_people_update",
      ]
  end

  it 'should add helpers by name' do
      mock_rest(Person, :routes => [:new, :create, :destroy]) { methods.grep(/^url_for_people_/).sort }.should == [
          "url_for_people_create",
          "url_for_people_destroy",
          "url_for_people_new",
      ]
  end
  
  it 'should add helpers by mixing aliases and names' do
      mock_rest(Person, :routes => [:readable, :create, :destroy]) { methods.grep(/^url_for_people_/).sort }.should == [
          "url_for_people_create",
          "url_for_people_destroy",
          "url_for_people_index",
          "url_for_people_show",          
      ]
  end

end
