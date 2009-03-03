module Stone
  module Resource
    def find_by_id(id)
      get(id)
    end
  end
end

module DataMapper
  module Model
    def find_by_id(id)
      get(id)
    end
  end
end

module ActiveRecord
  module Base
    def find_by_id(id)
      first(id)
    end
  end
end

