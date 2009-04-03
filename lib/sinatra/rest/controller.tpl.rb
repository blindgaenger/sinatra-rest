def PLURAL_before(name)
  # override
end

def PLURAL_after(name)
  # override
end

# index GET /models
if INDEX
  def PLURAL_index(options=nil)
    @PLURAL = call_model_method(MODEL, :all, options)
  end
end

# new GET /models/new
if NEW
  def PLURAL_new(options=nil)
    @SINGULAR = call_model_method(MODEL, :new, options)
  end
end

# create POST /models
if CREATE
  def PLURAL_create(options=params)
    mp = filter_model_params(options)
    @SINGULAR = call_model_method(MODEL, :new, mp)
    @SINGULAR.save
  end
end

# show GET /models/1
if SHOW
  def PLURAL_show(options=params)
    mp = filter_model_params(options)
    @SINGULAR = call_model_method(MODEL, :find_by_id, mp[:id])
  end
end

# edit GET /models/1/edit
if EDIT
  def PLURAL_edit(options=params)
    mp = filter_model_params(options) 
    @SINGULAR = call_model_method(MODEL, :find_by_id, mp[:id])
  end
end

# update PUT /models/1
if UPDATE
  def PLURAL_update(options=params)
    mp = filter_model_params(options)  
    @SINGULAR = call_model_method(MODEL, :find_by_id, mp[:id])
    @SINGULAR.update_attributes(mp) unless @SINGULAR.nil?
  end
end

# destroy DELETE /models/1
if DESTROY
  def PLURAL_destroy(options=params)
    mp = filter_model_params(options)  
    call_model_method(MODEL, :delete, mp[:id])
  end
end


