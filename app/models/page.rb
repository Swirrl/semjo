class Page < CouchRest::Model::Base
  
  include ContentModels

  define_properties_and_views 
  define_validations_and_callbacks
   
  define_publishing_related_methods
  define_permalink_related_methods
 
  proxied_by :blog
                   
end
