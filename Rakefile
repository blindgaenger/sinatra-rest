require 'spec/rake/spectask'

task :default => [:test]
task :test => :spec

desc "Run specs"
Spec::Rake::SpecTask.new :spec do |t|
  t.spec_opts = %w(--format specdoc --color)
  t.spec_files = FileList['test/*_spec.rb']
end

