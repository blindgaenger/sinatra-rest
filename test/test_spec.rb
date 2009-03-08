require File.dirname(__FILE__) + '/helper'

describe 'test helpers' do

  it 'should work with mock_app' do
    Person.clear!
    mock_app {
      rest Person
    }
    index('/people').should == [200, '<people></people>']
  end

  it 'should work with mock_rest' do
    Person.clear!
    mock_rest Person
    index('/people').should == [200, '<people></people>']
  end

end
