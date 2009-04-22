require 'spec/rake/spectask'

task :default => :test

desc "Run tests"
Spec::Rake::SpecTask.new :test do |t|
  t.spec_opts = %w(--format specdoc --color) #--backtrace
  t.spec_files = FileList['test/*_spec.rb']
end

