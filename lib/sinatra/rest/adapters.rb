module Stone
  module Resource
    def find_by_id(id)
      get(id)
    end
    
    def delete(id)
      model = self.find_by_id(id)
      model.destroy if model
    end
  end
end

module DataMapper
  module Model
    def find_by_id(id)
      get(id)
    end
    
    def delete(id)
      model = self.find_by_id(id)
      model.destroy if model
    end
  end
end

module ActiveRecord
  class Base
    class << self
      def find_by_id(id)
        find(id)
      end
    end
  end
end

module Ohm
  module Model
    def find_by_id(id)
      self[id]
    end
    
    def delete(id)
      self[id].delete
    end
  end
end

