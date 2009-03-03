require 'sinatra/base'
require 'english/inflect'

module Sinatra
  module REST

    #
    # adds restful routes and url helpers for the model
    def rest(model_class, options={}, &block)
      @model, @singular, @plural = conjugate(model_class)

      @renderer = options.delete(:renderer)
      @renderer ||= :haml
      @renderer = @renderer.to_s

      # @false@ will remove the @POST@, @PUT@ and @DELETE@ routes
      # by dfault this is enabled
      # :editable => true
      @editable = options.delete(:editable)
      @editable = true if @editable.nil?

      # @true@ will add the @/models/new@ and @/models/edit@ routes
      # by default this is disabled
      # :inputable => false
      @inputable = options.delete(:inputable)
      @inputable = true if @inputable.nil?

      generate_helpers
      
      helpers read_module_template('controller.tpl.rb')
      instance_eval read_template('routes.tpl.rb')
    end

  protected
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

  end # REST

  #
  # register as DSL extension
  register REST

end # Sinatra
