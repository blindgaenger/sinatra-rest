module Sinatra
  module REST

    module Helpers
    private
      def escape_model_id(model)
        if model.nil?
          raise 'can not generate url for nil'
        elsif model.kind_of?(String)
          Rake::Utils.escape(model)
        elsif model.kind_of?(Fixnum)
          model
        elsif model.id.kind_of? String
          Rake::Utils.escape(model.id)
        else
          model.id
        end
      end
    end
    
    # register standard helpers
    Sinatra.helpers Helpers

    #
    # generate helpers for the model
    def generate_helpers
      helpers read_module_template('helpers.tpl.rb')
    end

  end # REST

end # Sinatra
