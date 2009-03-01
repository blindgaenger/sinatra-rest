require File.dirname(__FILE__) + '/helper'

describe 'rspec helper' do

  it 'helpers should work in mock_app' do
    mock_app {
      helpers do
        def hello
          "Hello World!"
        end
      end
      get '/hello' do
        hello
      end
    }
  
    get '/hello'
    response.should be_ok
    response.body.should == 'Hello World!'
  end

end
