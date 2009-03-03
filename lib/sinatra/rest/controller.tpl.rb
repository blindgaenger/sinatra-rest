# index GET /models
def PLURAL_index
  @PLURAL = MODEL.all
end

# new GET /models/new
if @editable && @inputable
  def PLURAL_new
    @SINGULAR = MODEL.new
  end
end

# create POST /models
if @editable
  def PLURAL_create
    @SINGULAR = MODEL.new(params)
    @SINGULAR.save
  end
end

# show GET /models/1
def PLURAL_show
  @SINGULAR = MODEL.find_by_id(params[:id])
end

# edit GET /models/1/edit
if @editable && @inputable
  def PLURAL_edit
    @SINGULAR = MODEL.find_by_id(params[:id])
  end
end

# update PUT /models/1
if @editable
  def PLURAL_update
    @SINGULAR = MODEL.find_by_id(params[:id])
    @SINGULAR.update_attributes(params)
  end
end

# destroy DELETE /models/1
if @editable
  def PLURAL_destroy
    MODEL.delete(params[:id])
  end
end

