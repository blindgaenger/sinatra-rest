require 'rubygems'
require 'english/inflect'
require 'cgi'

class Object
  def instance_variables_map
    instance_variables.inject({}) {|map, var|
      map[var[1..-1]] = instance_variable_get(var); map
    }
  end
end

module Stone
  module Resource
    def find_by_id(id)
      get(id)
    end
  end
end

module Sinatra
  module REST

    #
    # adds restful routes and url helpers for the model
    def rest(model_class, options={}, &block)
      model, singular, plural = conjugate(model_class)

      renderer = options.delete(:renderer)
      renderer ||= :haml

      # @false@ will remove the @POST@, @PUT@ and @DELETE@ routes
      # by dfault this is enabled
      # :editable => true
      editable = options.delete(:editable)
      editable = true if editable.nil?

      # @true@ will add the @/models/new@ and @/models/edit@ routes
      # by default this is disabled
      # :inputable => false
      inputable = options.delete(:inputable)
      inputable = true if inputable.nil?


      # add some url_for_* helpers
      Sinatra::EventContext.class_eval <<-XXX
        public
              
        # index GET /models
        def url_for_#{plural}_index
          '/#{plural}'
        end

        # new GET /models/new
        if editable && inputable
          def url_for_#{plural}_new
            '/#{plural}/new'
          end
        end

        # create POST /models
        if editable
          def url_for_#{plural}_create
            '/#{plural}'
          end
        end

        # show GET /models/1
        def url_for_#{plural}_show(model)
          "/#{plural}/\#{escape_model_id(model)}"
        end

        # edit GET /models/1/edit
        if editable && inputable
          def url_for_#{plural}_edit(model)
            "/#{plural}/\#{escape_model_id(model)}/edit"
          end
        end

        # update PUT /models/1
        if editable
          def url_for_#{plural}_update(model)
            "/#{plural}/\#{escape_model_id(model)}"
          end
        end

        # destroy DELETE /models/1
        if editable
          def url_for_#{plural}_destroy(model)
            "/#{plural}/\#{escape_model_id(model)}"
          end
        end
        
        private
        
        def escape_model_id(model)
          if model.nil?
            raise 'can not generate url for nil'
          elsif model.kind_of?(String)
            CGI.escape(model)
          elsif model.kind_of?(Fixnum)
            model
          elsif model.id.kind_of? String
            CGI.escape(model.id)
          else
            model.id
          end
        end
        
        public
      XXX

      # create an own module and fill it with the template
      controller_template = Module.new
      controller_template.class_eval <<-XXX
        # index GET /models
        def index
          @#{plural} = #{model}.all
        end

        # new GET /models/new
        if editable && inputable
          def new
            @#{singular} = #{model}.new
          end
        end

        # create POST /models
        if editable
          def create
            @#{singular} = #{model}.new(params)
            @#{singular}.save
          end
        end

        # show GET /models/1
        def show
          @#{singular} = #{model}.find_by_id(params[:id])
        end

        # edit GET /models/1/edit
        if editable && inputable
          def edit
            @#{singular} = #{model}.find_by_id(params[:id])
          end
        end

        # update PUT /models/1
        if editable
          def update
            @#{singular} = #{model}.find_by_id(params[:id])
            @#{singular}.update_attributes(params)
          end
        end

        # destroy DELETE /models/1
        if editable
          def destroy
            #{model}.delete(params[:id])
          end
        end
      XXX

      # create an own module, to override the template with custom methods
      # this way, you can still use #super# in the overridden methods
      if block_given?
        controller_custom = Module.new &block
      end

      # create the restful routes
      Sinatra.application.instance_eval <<-XXX
        # add the correct modules to the EventContext
        # use a metaclass so it isn't included again next time
        before do
          if request.path_info =~ /^\\/#{plural}\\b/
            metaclass = class << self; self; end
            metaclass.send(:include, controller_template)
            metaclass.send(:include, controller_custom) if controller_custom
          end
        end

        # index GET /models
        get '/#{plural}' do
          index
          #{renderer.to_s} :"#{plural}/index", options
        end

        # new GET /models/new
        if editable && inputable
          get '/#{plural}/new' do
            new
            #{renderer.to_s} :"#{plural}/new", options
          end
        end

        # create POST /models
        if editable
          post '/#{plural}' do
            create
            redirect url_for_#{plural}_show(@#{singular}), '#{singular} created'
          end
        end

        # show GET /models/1
        get '/#{plural}/:id' do
          show
          if @#{singular}.nil?
            throw :halt, [404, '#{singular} not found']
          else
            #{renderer.to_s} :"#{plural}/show", options
          end
        end

        # edit GET /models/1/edit
        if editable && inputable
          get '/#{plural}/:id/edit' do
            edit
            #{renderer.to_s} :"#{plural}/edit", options
          end
        end

        # update PUT /models/1
        if editable
          put '/#{plural}/:id' do
            update
            redirect url_for_#{plural}_show(@#{singular}), '#{singular} updated'
          end
        end

        # destroy DELETE /models/1
        if editable
          delete '/#{plural}/:id' do
            destroy
            redirect url_for_#{plural}_index, '#{singular} deleted'
          end
        end
      XXX

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

  end # REST
end # Sinatra

include Sinatra::REST

