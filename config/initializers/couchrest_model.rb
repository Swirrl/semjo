CouchRest::Model::Base.configure do |config| 
  config.model_type_key = 'couchrest-type'  #uncomment to use old-style couchrest model name
  
  #config.auto_update_design_doc = true # set to false not to auto update design docs 
  config.auto_update_design_doc = false if Rails.env.to_s == :production
end  