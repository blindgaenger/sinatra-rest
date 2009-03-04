require 'sinatra/base'
require 'english/inflect'

libdir = File.dirname(__FILE__) + "/rest"
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'adapters'

module Sinatra

  module REST

    #
    # adds restful routes and url helpers for the model
    def rest(model_class, options={}, &block)
      parse_args(model_class, options)

      # register model specific helpers
      helpers read_module_template('rest/helpers.tpl.rb')
      
      # register as DSL extension
      helpers read_module_template('rest/controller.tpl.rb')
      instance_eval read_template('rest/routes.tpl.rb')
    end

  protected

    def parse_args(model_class, options)
      @model, @singular, @plural = conjugate(model_class)

      @renderer = (options.delete(:renderer) || :haml).to_s

      # @false@ will remove the @POST@, @PUT@ and @DELETE@ routes
      @editable = options.delete(:editable)
      @editable = true if @editable.nil?

      # @true@ will add the @/models/new@ and @/models/edit@ routes
      @inputable = options.delete(:inputable)
      @inputable = true if @inputable.nil?
    end
    
    #
    # creates the necessary forms of the model name
    # pretty much like ActiveSupport's inflections, but don't like to depend on
    def conjugate(model_class)
      model = model_class.to_s.match(/(\w+)$/)[0]
      singular = model.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      return model, singular, singular.pluralize
    end

    #
    # read the file and do some substitutions
    def read_template(filename)
      t = File.read(File.join(File.dirname(__FILE__), filename))
      t.gsub!(/PLURAL/, @plural)
      t.gsub!(/SINGULAR/, @singular)
      t.gsub!(/MODEL/, @model)
      t.gsub!(/RENDERER/, @renderer)      
      t
    end

    #
    # read the template and put it into an anonymous module
    def read_module_template(filename)
      t = read_template(filename)
      m = Module.new
      m.module_eval(t)
      m
    end

    #
    # model unspecific helpers, will be included once
    module Helpers
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

  end # REST

  helpers REST::Helpers
  register REST

end # Sinatra
