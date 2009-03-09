Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "sinatra-rest"
  s.version = "0.2"
  s.date = "2009-03-08"  
  s.authors = ["blindgaenger"]
  s.email = "blindgaenger@gmail.com"
  s.homepage = "http://github.com/blindgaenger/sinatra-rest"  
  s.summary = "Generates RESTful routes for the models of a Sinatra application (ActiveRecord, DataMapper, Stone)"
  
  s.files = [
    "Rakefile",
    "README.textile",
    "lib/rest.rb",    
    "spec/rest_spec.rb",
    "spec/views/people/edit.erb",
    "spec/views/people/index.erb",
    "spec/views/people/new.erb",
    "spec/views/people/show.erb"
  ]  
  s.require_paths = ["lib"]
  s.add_dependency "sinatra", [">= 0.9.0.5"]
  s.add_dependency "english", [">= 0.3.1"]

  s.has_rdoc = "false"
end

