require 'rubygems'
require 'english/inflect'

class Object
  def instance_variables_map
    instance_variables.inject({}) {|map, var|
      map[var[1..-1]] = instance_variable_get(var); map
    }
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

      # if set the route 
      # :format => ['xml', 'html', '']  => [/models/:id, /models/:id.?:format?]
      format = options.delete(:format)

      # add some url_for_* helpers
      Sinatra::EventContext.class_eval <<-XXX
        # index GET /models
        def url_for_#{plural}_index
          '/#{plural}'
        end

        # new GET /models/new
        def url_for_#{plural}_new
          '/#{plural}/new'
        end

        # create POST /models
        def url_for_#{plural}_create
          '/#{plural}'
        end

        # show GET /models/1
        def url_for_#{plural}_show(model)
          "/#{plural}/\#{model.id}"
        end

        # edit GET /models/1/edit
        def url_for_#{plural}_edit(model)
          "/#{plural}/\#{model.id}/edit"
        end

        # update PUT /models/1
        def url_for_#{plural}_update(model)
          "/#{plural}/\#{model.id}"
        end

        # destroy DELETE /models/1
        def url_for_#{plural}_destroy(model)
          "/#{plural}/\#{model.id}"
        end
      XXX

      # create an own module and fill it with the template
      controller_template = Module.new
      controller_template.class_eval <<-XXX
        # index GET /models
        def index
          @#{plural} = #{model}.all
        end

        # new GET /models/new
        def new
          @#{singular} = #{model}.new
        end

        # create POST /models
        def create
          @#{singular} = #{model}.new(params)
          @#{singular}.save
        end

        # show GET /models/1
        def show
          @#{singular} = #{model}.first(params[:id])
        end

        # edit GET /models/1/edit
        def edit
          @#{singular} = #{model}.first(params[:id])
        end

        # update PUT /models/1
        def update
          @#{singular} = #{model}.first(params[:id])
          @#{singular}.update_attributes(params)
        end

        # destroy DELETE /models/1
        def destroy
          #{model}.delete(params[:id])
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
        get '/#{plural}/new' do
          new
          #{renderer.to_s} :"#{plural}/new", options
        end

        # create POST /models
        post '/#{plural}' do
          create

          redirect url_for_#{plural}_show(@#{singular}), 'resource created'
        end

        # show GET /models/1
        get '/#{plural}/:id' do
          show

          if @#{singular}.nil?
            throw :halt, [404, 'resource not found']
          else
            #{renderer.to_s} :"#{plural}/show", options
          end
        end

        # edit GET /models/1/edit
        get '/#{plural}/:id/edit' do
          edit
          #{renderer.to_s} :"#{plural}/edit", options
        end

        # update PUT /models/1
        put '/#{plural}/:id' do
          update
          redirect url_for_#{plural}_show(@#{singular}), 'resource updated'
        end

        # destroy DELETE /models/1
        delete '/#{plural}/:id' do
          destroy
          redirect url_for_#{plural}_index, 'resource deleted'
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

