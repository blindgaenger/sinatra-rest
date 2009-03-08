# index GET /models
if INDEX
  def url_for_PLURAL_index
    '/PLURAL'
  end
end

# new GET /models/new
if NEW
  def url_for_PLURAL_new
    '/PLURAL/new'
  end
end

# create POST /models
if CREATE
  def url_for_PLURAL_create
    '/PLURAL'
  end
end

# show GET /models/1
if SHOW
  def url_for_PLURAL_show(model)
    "/PLURAL/#{escape_model_id(model)}"
  end
end

# edit GET /models/1/edit
if EDIT
  def url_for_PLURAL_edit(model)
    "/PLURAL/#{escape_model_id(model)}/edit"
  end
end

# update PUT /models/1
if UPDATE
  def url_for_PLURAL_update(model)
    "/PLURAL/#{escape_model_id(model)}"
  end
end

# destroy DELETE /models/1
if DESTROY
  def url_for_PLURAL_destroy(model)
    "/PLURAL/#{escape_model_id(model)}"
  end
end

