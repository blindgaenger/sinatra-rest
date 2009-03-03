# index GET /models
def url_for_PLURAL_index
  '/PLURAL'
end

# new GET /models/new
if @editable && @inputable
  def url_for_PLURAL_new
    '/PLURAL/new'
  end
end

# create POST /models
if @editable
  def url_for_PLURAL_create
    '/PLURAL'
  end
end

# show GET /models/1
def url_for_PLURAL_show(model)
  "/PLURAL/\#{escape_model_id(model)}"
end

# edit GET /models/1/edit
if @editable && @inputable
  def url_for_PLURAL_edit(model)
    "/PLURAL/\#{escape_model_id(model)}/edit"
  end
end

# update PUT /models/1
if @editable
  def url_for_PLURAL_update(model)
    "/PLURAL/\#{escape_model_id(model)}"
  end
end

# destroy DELETE /models/1
if @editable
  def url_for_PLURAL_destroy(model)
    "/PLURAL/\#{escape_model_id(model)}"
  end
end

