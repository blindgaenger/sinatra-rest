# index GET /models
get '/PLURAL' do
  PLURAL_index
  RENDERER :"PLURAL/index", options  
end

# new GET /models/new
#if @editable && @inputable
  get '/PLURAL/new' do
    PLURAL_new
    RENDERER :"PLURAL/new", options
  end
#end

# create POST /models
#if @editable
  post '/PLURAL' do
    PLURAL_create
    redirect url_for_PLURAL_show(@SINGULAR), 'SINGULAR created'
  end
#end

# show GET /models/1
get '/PLURAL/:id' do
  PLURAL_show
  if @SINGULAR.nil?
    throw :halt, [404, 'SINGULAR not found']
  else
    RENDERER :"PLURAL/show", options
  end
end

# edit GET /models/1/edit
#if @editable && @inputable
  get '/PLURAL/:id/edit' do
    PLURAL_edit
    RENDERER :"PLURAL/edit", options
  end
#end

# update PUT /models/1
#if @editable
  put '/PLURAL/:id' do
    PLURAL_update
    if @SINGULAR.nil?
      throw :halt, [404, 'SINGULAR not found']
    else
      redirect url_for_PLURAL_show(@SINGULAR), 'SINGULAR updated'
    end
  end
#end

# destroy DELETE /models/1
#if @editable
  delete '/PLURAL/:id' do
    PLURAL_destroy
    redirect url_for_PLURAL_index, 'SINGULAR deleted'
  end
#end

