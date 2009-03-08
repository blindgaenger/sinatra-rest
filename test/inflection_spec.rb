require File.dirname(__FILE__) + '/helper'

describe 'model inflection' do

  def conjugate(model)
    mock_app {
      include Sinatra::REST
      conjugate(model)
    }
  end

  it "should conjugate a simple model name" do
    conjugate(Person).should == %w(Person person people)
  end

  it "should conjugate a String as model name" do
    conjugate('Person').should == %w(Person person people)  
  end

  it "should conjugate a model name in camel cases" do
    conjugate('SomePerson').should == %w(SomePerson some_person some_people)
  end

  it "should conjugate a model name without module" do
    conjugate('MyModule::ModulePerson').should == %w(ModulePerson module_person module_people)
  end

end

