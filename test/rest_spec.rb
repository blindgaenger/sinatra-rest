require File.dirname(__FILE__) + '/helper'

describe 'test cases' do

  it 'should work' do
    mock_app {
      rest Person
    }
    index('/people').should == [200, '<people></people>']
  end

end
