require 'sinatra/base'
require 'english/inflect'

libdir = File.dirname(__FILE__) + "/rest"
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'adapters'
require 'yaml'

module Sinatra

  module REST

    #
    # adds restful routes and url helpers for the model
    def rest(model_class, options={}, &block)
      parse_args(model_class, options)
      read_config('rest/rest.yaml')

      # register model specific helpers
      helpers generate_helpers
      
      # create an own module, to override the template with custom methods
      # this way, you can still use #super# in the overridden methods
      controller = generate_controller
      if block_given?
        custom = CustomController.new(@plural)
        custom.instance_eval &block
        custom.module.send :include, controller
        controller = custom.module
      end
      helpers controller
      
      # register routes as DSL extension
      instance_eval generate_routes
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
      routes = [*routes].map {|route| ROUTES[route] || route}.flatten.uniq
      # keep the order of :all routes
      ROUTES[:all].select{|route| routes.include? route}
    end
    
    def read_config(filename)
      file = File.read(File.join(File.dirname(__FILE__), filename))
      @config = YAML.load file
    end

    #
    # creates the necessary forms of the model name
    # pretty much like ActiveSupport's inflections, but don't like to depend on
    def conjugate(model_class)
      model = model_class.to_s.match(/(\w+)$/)[0]
      singular = model.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      return model, singular, singular.pluralize
    end

    def replace_variables(t, route=nil)
      if route
        t.gsub!('NAME', route.to_s)
        t.gsub!('VERB', @config[route][:verb].downcase)
        t.gsub!('URL', @config[route][:url])
        t.gsub!('CONTROL', @config[route][:control])
        t.gsub!('RENDER', @config[route][:render]) 
      end    
      t.gsub!(/PLURAL/, @plural)
      t.gsub!(/SINGULAR/, @singular)
      t.gsub!(/MODEL/, @model)
      t.gsub!(/RENDERER/, @renderer)
      t    
    end

    def generate_routes
      @route_flags.map{|r| route_template(r)}.join("\n\n")
    end
    
    def route_template(route)
      t = <<-RUBY
        VERB 'URL' do
          PLURAL_before :NAME
          PLURAL_NAME
          PLURAL_after :NAME   
          RENDER
        end
      RUBY
      replace_variables(t, route)
    end

    def generate_helpers
      m = Module.new
      @route_flags.each {|r|
        m.module_eval helpers_template(r)
      }
      m
    end
    
    def helpers_template(route)
      t = <<-RUBY
        def url_for_PLURAL_NAME(model=nil)
          "URL"
        end
      RUBY
      helper_route = @config[route][:url].gsub(':id', '#{escape_model_id(model)}')
      t.gsub!('URL', helper_route)
      replace_variables(t, route)
    end

    def generate_controller
      m = Module.new
      t = <<-RUBY
        def PLURAL_before(name); end
        def PLURAL_after(name); end
      RUBY
      m.module_eval replace_variables(t)

      @route_flags.each {|route|
        m.module_eval controller_template(route)
      }
      m
    end
    
    def controller_template(route)
      t = <<-RUBY
        def PLURAL_NAME(options=params)
          mp = filter_model_params(options)
          CONTROL
        end
      RUBY
      replace_variables(t, route)
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
