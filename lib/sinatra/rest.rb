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
      
      # create an own module, to override the template with custom methods
      # this way, you can still use #super# in the overridden methods
      controller = read_module_template('rest/controller.tpl.rb')
      if block_given?
        custom = CustomController.new(@plural)
        custom.instance_eval &block
        custom.module.send :include, controller
        controller = custom.module
      end
      helpers controller
      
      # register routes as DSL extension
      instance_eval read_template('rest/routes.tpl.rb')
    end

  protected

    ROUTES = {
      :all       => [:index, :new, :create, :show, :edit, :update, :destroy],
      :readable  => [:index, :show],
      :writeable => [:index, :show, :create, :update, :destroy],      
      :editable  => [:index, :show, :create, :update, :destroy, :new, :edit],                        
    }

    def parse_args(model_class, options)
      @model, @singular, @plural = conjugate(model_class)
      @renderer = (options.delete(:renderer) || :haml).to_s
      @route_flags = parse_routes(options.delete(:routes) || :all)
    end
    
    def parse_routes(routes)
      [*routes].map {|route| ROUTES[route] || route}.flatten.uniq
    end
    
    def gsub_routes(routes, template)
      routes.each {|route| template.gsub!(/#{route.to_s.upcase}/, true.to_s) }
      (ROUTES[:all] - routes).each {|route| template.gsub!(/#{route.to_s.upcase}/, false.to_s) }
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
      gsub_routes(@route_flags, t)
      t
    end

    #
    # read the template and put it into an anonymous module
    def read_module_template(filename)
      t = read_template(filename)
      m = Module.new
      m.module_eval(t, filename)
      m
    end

    #
    # model unspecific helpers, will be included once
    module Helpers
      # for example _method will be removed
      def filter_model_params(params)
        params.reject {|k, v| k =~ /^_/}
      end
    
      def escape_model_id(model)
        if model.nil?
          raise 'can not generate url for nil'
        elsif model.kind_of?(String)
          Rack::Utils.escape(model)
        elsif model.kind_of?(Fixnum)
          model
        elsif model.id.kind_of? String
          Rack::Utils.escape(model.id)
        else
          model.id
        end
      end

      def call_model_method(model_class, name, options={})
        method = model_class.method(name)
        if options.nil? || method.arity == 0
          Kernel.warn "warning: calling #{model_class.to_s}##{name} with args, although it doesn't take args" if options
          method.call
        else
          method.call(options)
        end
      end
    end

    #
    # used as context to evaluate the controller's module
    class CustomController
      attr_reader :module

      def initialize(prefix)
        @prefix = prefix
        @module = Module.new
      end

      def before(options={}, &block)  prefix :before,  &block; end
      def after(options={}, &block)   prefix :after,   &block; end      
      def index(options={}, &block)   prefix :index,   &block; end
      def new(options={}, &block)     prefix :new,     &block; end
      def create(options={}, &block)  prefix :create,  &block; end
      def show(options={}, &block)    prefix :show,    &block; end
      def edit(options={}, &block)    prefix :edit,    &block; end
      def update(options={}, &block)  prefix :update,  &block; end
      def destroy(options={}, &block) prefix :destroy, &block; end                        

    private 
      def prefix(name, &block)
        @module.send :define_method, "#{@prefix}_#{name}", &block if block_given?
      end
    end

  end # REST

  helpers REST::Helpers
  register REST

end # Sinatra
