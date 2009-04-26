Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "sinatra-rest"
  s.version = "0.3.1"
  s.date = "2009-04-26"  
  s.authors = ["blindgaenger"]
  s.email = "blindgaenger@gmail.com"
  s.homepage = "http://github.com/blindgaenger/sinatra-rest"  
  s.summary = "Generates RESTful routes for the models of a Sinatra application (ActiveRecord, DataMapper, Stone)"
  
  s.files = [
    "Rakefile",
    "README.textile",
    "lib/sinatra/rest.rb",
    "lib/sinatra/rest/adapters.rb",    
    "lib/sinatra/rest/controller.tpl.rb",    
    "lib/sinatra/rest/helpers.tpl.rb",    
    "lib/sinatra/rest/routes.tpl.rb",
    "test/call_order_spec.rb",
    "test/crud_spec.rb",
    "test/helper.rb",
    "test/helpers_spec.rb",
    "test/inflection_spec.rb",
    "test/routes_spec.rb",
    "test/test_spec.rb",
    "test/views/people/edit.haml",
    "test/views/people/index.haml",
    "test/views/people/new.haml",
    "test/views/people/show.haml"
  ]

  s.require_paths = ["lib"]
  s.add_dependency "sinatra", [">= 0.9.0.5"]
  s.add_dependency "english", [">= 0.3.1"]

  s.has_rdoc = "false"
end

