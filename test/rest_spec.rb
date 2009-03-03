require File.dirname(__FILE__) + '/helper'

describe 'test cases' do

  it 'should work' do
    mock_app {
      class Person; end
      rest Person
    }
    index('/people').should == [200, '<people></people>']
  end

end
