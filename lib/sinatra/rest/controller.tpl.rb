# index GET /models
def PLURAL_index
  @PLURAL = MODEL.all
end

# new GET /models/new
#if @editable && @inputable
  def PLURAL_new
    @SINGULAR = MODEL.new
  end
#end

# create POST /models
#if @editable
  def PLURAL_create
    mp = filter_model_params(params)
    @SINGULAR = MODEL.new(mp)
    @SINGULAR.save
  end
#end

# show GET /models/1
def PLURAL_show
  mp = filter_model_params(params)
  @SINGULAR = MODEL.find_by_id(mp[:id])
end

# edit GET /models/1/edit
#if @editable && @inputable
  def PLURAL_edit
    mp = filter_model_params(params)  
    @SINGULAR = MODEL.find_by_id(mp[:id])
  end
#end

# update PUT /models/1
#if @editable
  def PLURAL_update
    mp = filter_model_params(params)  
    @SINGULAR = MODEL.find_by_id(mp[:id])
    @SINGULAR.update_attributes(mp)
  end
#end

# destroy DELETE /models/1
#if @editable
  def PLURAL_destroy
    mp = filter_model_params(params)  
    MODEL.delete(mp[:id])
  end
#end

