require 'activerecord'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::WARN

config = {
  :adapter => 'sqlite3',
  :database => "db/#{Sinatra::Application.environment.to_s}.sqlite3"
}
ActiveRecord::Base.establish_connection(config)
ActiveRecord::Migrator.up('db/migrate')

class Person < ActiveRecord::Base
end

