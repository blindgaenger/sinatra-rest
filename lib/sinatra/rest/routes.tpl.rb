# index GET /models
if INDEX
  get '/PLURAL' do
    PLURAL_before :index
    PLURAL_index
    PLURAL_after :index    
    RENDERER :"PLURAL/index", options  
  end
end

# new GET /models/new
if NEW
  get '/PLURAL/new' do
    PLURAL_before :new  
    PLURAL_new
    PLURAL_after :new    
    RENDERER :"PLURAL/new", options
  end
end

# create POST /models
if CREATE
  post '/PLURAL' do
    PLURAL_before :create
    PLURAL_create
    PLURAL_after :create
    redirect url_for_PLURAL_show(@SINGULAR), 'SINGULAR created'
  end
end

# show GET /models/1
if SHOW
  get '/PLURAL/:id' do
    PLURAL_before :show
    PLURAL_show
    PLURAL_after :show
    if @SINGULAR.nil?
      throw :halt, [404, 'SINGULAR not found']
    else
      RENDERER :"PLURAL/show", options
    end
  end
end

# edit GET /models/1/edit
if EDIT
  get '/PLURAL/:id/edit' do
    PLURAL_before :edit
    PLURAL_edit
    PLURAL_after :edit    
    RENDERER :"PLURAL/edit", options
  end
end

# update PUT /models/1
if UPDATE
  put '/PLURAL/:id' do
    PLURAL_before :update  
    PLURAL_update
    PLURAL_after :update
    if @SINGULAR.nil?
      throw :halt, [404, 'SINGULAR not found']
    else
      redirect url_for_PLURAL_show(@SINGULAR), 'SINGULAR updated'
    end
  end
end

# destroy DELETE /models/1
if DESTROY
  delete '/PLURAL/:id' do
    PLURAL_before :destroy
    PLURAL_destroy
    PLURAL_after :destroy
    redirect url_for_PLURAL_index, 'SINGULAR destroyed'
  end
end

