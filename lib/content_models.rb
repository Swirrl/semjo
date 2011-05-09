module ContentModels
  
  DRAFT_STATUS = "draft"
  PUBLISHED_STATUS = "published"

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  # Class methods
  module ClassMethods
    
    def define_publishing_related_methods
      
      class_eval do
        
        # TODO: make this a bit more intelligent
        def set_published(published, account_name)
          if published && self.published_at == nil 
            # notice: only change the published at time and user if publishing for first time.
            self.published_at = Time.now.utc
            self.published_by = account_name
          elsif published == false
            self.published_at = nil
            self.published_by = account_name
          end
          # otherwise do nothing
        end
  
        def is_published?
          !!self.published_at
        end
        
      end
    end
  
    def define_permalink_related_methods
      
      class_eval do
        
        # special setter for permalink
        def set_permalink(new_permalink)
          new_permalink = self.class.sanitize_permalink(new_permalink) # make sure it's sanitized
          if new_permalink != self.permalink # only bother doing anything if it's actually changed.     
            self.permalink = new_permalink
            self.permalink_updated = true # make a note that we're changing the permalink
          end
        end
  
        def generate_permalink_from_title      
          if self.new_document?
            self.sanitized_title = self.class.sanitize_permalink(title)
            self.permalink = self.sanitized_title
          end
    
          # if it's a new doc, or we're manually forcing the permalink change....
          if self.new_document? || self.permalink_updated
            check_permalink_uniqueness
          end
        end
  
        def self.sanitize_permalink(the_permalink)
          the_permalink.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'') #sanitize
        end
  
        def check_permalink_uniqueness    
          # find other docs with the same sanitized title
          model_method = self.class.to_s.tableize
          the_blog = self.blog
          assoc = the_blog.send(model_method)
                    
          other_occurrences = assoc.by_sanitized_title(:key => self.sanitized_title).all
                        
          if other_occurrences.length > 0 
            suffix = "-#{other_occurrences.length}"
            if self.new_document?
              self.permalink += suffix # if there's a duplicate, add a suffix.
            else
              # if it's not a new document, then it's ok if the other occurrence is ourselves
              
              if other_occurrences.length == 1 
                Rails.logger.debug("1 other occurance")                
                if other_occurrences[0].id == self.id
                  Rails.logger.debug("other occurance is us!")
                else
                  Rails.logger.debug("other occurance is not us!")
                  self.permalink += suffix 
                end
              else
                Rails.logger.debug(">1 other occurrance")
              end
              
            end
          end
        end
        
      end
      
    end
    
    
    
    def define_validations_and_callbacks
      validates :title, :presence => true
      validates_length_of :title, :within => 3..255 
      before_save :generate_permalink_from_title
    end
    
    def define_properties_and_views
      
      property :permalink
      
      property :title
      property :raw, TrueClass #don't run content through textilizer.
      property :published_at, DateTime
      property :content
      property :clean_content # use for the content, stripped of all markup - for searching, etc.
      property :status
      property :published_by #account name of who published the article
      property :sanitized_title
   
      design do 
        view :by_sanitized_title
        view :by_permalink
      
        view :by_published_at,
          :map => 
            "function(doc) {
              if ((doc['couchrest-type'] == 'Article') && doc['published_at']) {
                emit(doc['published_at'], 1);
              }
            }",
           :reduce =>
              "function(keys, values, rereduce) {
                return sum(values);
              }"
      
        view :by_created_at
      end
    
      timestamps!
      
      attr_accessor :permalink_updated
      
      class_eval do
        
        # this is so that we can just use permalink as the id in active_model rails routes.
        def to_param
          self.permalink
        end

      end
      
    end
    
  end

end