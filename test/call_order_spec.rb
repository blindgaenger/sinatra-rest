require File.dirname(__FILE__) + '/helper'

describe 'call order' do

  def called_routes
    @app.call_order.map {|r, m| r}.uniq
  end

  def called_methods
    @app.call_order.map {|r, m| m}
  end

  before(:each) do
    mock_app {
      configure do
        set :call_order, []
      end
    
      rest Person do
        before do |route|
          options.call_order << [route, :before]
          super
        end

        after do |route|
          options.call_order << [route, :after]
          super
        end

        index do
          options.call_order << [:index, :index]
          super
        end

        new do
          options.call_order << [:new, :new]
          super
        end

        create do
          options.call_order << [:create, :create]
          super
        end

        show do
          options.call_order << [:show, :show]
          super
        end

        edit do
          options.call_order << [:edit, :edit]
          super
        end

        update do
          options.call_order << [:update, :update]
          super
        end

        destroy do
          options.call_order << [:destroy, :destroy]
          super
        end
      end
    }
  end

  it 'should call :index in the right order' do
    index '/people'
    called_methods.should == [:before, :index, :after]
    called_routes.should  == [:index]
  end

  it 'should call :new in the right order' do
    new '/people/new'
    called_methods.should == [:before, :new, :after]
    called_routes.should  == [:new]
  end

  it 'should call :create in the right order' do
    create('/people', :name => 'initial name')
    called_methods.should == [:before, :create, :after]
    called_routes.should  == [:create]
  end

  it 'should call :show in the right order' do
    show '/people/1'
    called_methods.should == [:before, :show, :after]
    called_routes.should  == [:show]    
  end

  it 'should call :edit in the right order' do
    edit '/people/1/edit'
    called_methods.should == [:before, :edit, :after]
    called_routes.should  == [:edit]    
  end

  it 'should call :update in the right order' do
    update '/people/1', :name => 'new name'
    called_methods.should == [:before, :update, :after]
    called_routes.should  == [:update]    
  end

  it 'should call :destroy in the right order' do
    destroy '/people/1'
    called_methods.should == [:before, :destroy, :after]
    called_routes.should  == [:destroy]    
  end

end

