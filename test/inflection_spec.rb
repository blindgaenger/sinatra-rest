require File.dirname(__FILE__) + '/helper'

describe 'inflection generator' do
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
