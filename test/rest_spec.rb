require File.dirname(__FILE__) + '/helper'

describe 'restful service' do

  before(:each) do
    Person.reset!
    mock_rest Person
  end

  it 'should list all people on index by their id' do
    index('/people').should == [200, '<people><person><id>1</id></person><person><id>2</id></person><person><id>3</id></person></people>']
  end

  it 'should prepare an empty item on new' do
    new('/people/new').should == [200, '<person><id></id><name></name></person>']
  end

  it 'should create an item on post' do
    create('/people', :name => 'new resource').should == [302, 'person created']
  end

  it 'should show an item on get' do
    show('/people/1').should == [200, '<person><id>1</id><name>one</name></person>']
  end

  it 'should get the item for editing' do
    edit('/people/1/edit').should == [200, '<person><id>1</id><name>one</name></person>']
  end

  it 'should update an item on put' do
    update('/people/1', :name => 'another name').should == [302, 'person updated']
  end

  it 'should destroy an item on delete' do
    destroy('/people/1').should == [302, 'person destroyed']
  end

end
