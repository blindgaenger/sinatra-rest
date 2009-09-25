require 'sinatra'


# add some data the first time or use an already existing db
configure :development do
  load 'setup_activerecord.rb'
  
  Person.create(:name => 'foo')
  Person.create(:name => 'bar')
  Person.create(:name => 'baz')
end

# sinatra-rest needs to be loaded after ActiveRecord
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'sinatra/rest'

rest Person

get '/' do
  redirect '/people'
end

