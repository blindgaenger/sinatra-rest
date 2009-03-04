# index GET /models
def PLURAL_index(options={})
  @PLURAL = MODEL.all(options)
end

# new GET /models/new
#if @editable && @inputable
  def PLURAL_new(options={})
    @SINGULAR = MODEL.new(options)
  end
#end

# create POST /models
#if @editable
  def PLURAL_create(options=params)
    mp = filter_model_params(options)
    @SINGULAR = MODEL.new(mp)
    @SINGULAR.save
  end
#end

# show GET /models/1
def PLURAL_show(options=params)
  mp = filter_model_params(options)
  @SINGULAR = MODEL.find_by_id(mp[:id])
end

# edit GET /models/1/edit
#if @editable && @inputable
  def PLURAL_edit(options=params)
    mp = filter_model_params(options)  
    @SINGULAR = MODEL.find_by_id(mp[:id])
  end
#end

# update PUT /models/1
#if @editable
  def PLURAL_update(options=params)
    mp = filter_model_params(options)  
    @SINGULAR = MODEL.find_by_id(mp[:id])
    @SINGULAR.update_attributes(mp) unless @SINGULAR.nil?
  end
#end

# destroy DELETE /models/1
#if @editable
  def PLURAL_destroy(options=params)
    mp = filter_model_params(options)  
    MODEL.delete(mp[:id])
  end
#end

