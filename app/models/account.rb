# this is the top-level document that stores info about the user, i.e. email, name etc.
class Account < CouchRest::Model::Base
  
  # central db  
  use_database CouchRest.database("#{APP_CONFIG['couch_db_location']}/semanticjournal")

  # WE USE THE ACCOUNT NAME AS THE ID. 
  # This is the only model for which we do this, so no need to scope it 
  # (even if we do use non GUIDs for other model IDs, we can just scope them, and they won't overlap)
  unique_id :name
  
  property :name # the UNIQUE account name, by which we can identify the person to others (without having to reveal email address)
  
  property :display_name
  
  property :email
  
  property :active, TrueClass, :default => true

  property :password_hash
  property :password_salt

  property :personal_uri
  
  design do    
    view :by_email
  
    view :by_active_email,
      :map => "
        function(doc) {
          if (doc['couchrest-type'] == 'Account' && doc['active'] == true) { 
            emit(doc['email'], null); 
          }
        }"
  end
      
  timestamps! #force writing of updated_at and created_at
  
  before_save :downcase_email

  # validation
  validate :validate_passwords # use a special method for this, as we don't have couch properties to store the cleartext password
  validate :check_email_uniqueness
  validates :email, :presence => true, :format => {:with => /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i}
  validates :name, :presence => true

  # authentication stuff....

  def validate_passwords
    #only check if new document, or password being changed.
    if self.new_document? || @entered_password || @confirm_password 
     
      if @entered_password.nil? || @entered_password.length < 4
        errors.add(:password,  "is too short or is not specified")
      end
      
      unless @entered_password == @confirm_password
        errors.add(:password, "doesn't match the confirmation")
      end
      
    end
    return true
  end
  
  def check_email_uniqueness
    if self.new_document? && Account.by_email(:key => self.email).length > 0
      errors.add(:email, "already exists")
    end
    return true
  end
  
  def downcase_email
    self.email = email.downcase
  end
  
  def self.authenticate(email, entered_password)
    
    #notice that we don't care about the case of the email.    
    account = Account.by_active_email(:key => email.downcase).first 
    
    Rails.logger.debug( "ACCOUNT #{account.inspect}" )
    
    
    if account
      entered_password_hash = encrypted_password(entered_password, account.password_salt)
      unless account.password_hash == entered_password_hash
        account = nil
      end
    else
      account = nil
    end
    
    # return the authenticated account (will be nil if auth failed).
    return account
    
  end
  
  def password=(pass)
    @entered_password = pass
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt = salt
    self.password_hash = Account.encrypted_password(pass,salt)
  end
  
  def confirm_password=(pass)
    @confirm_password = pass
  end
  
  def password
    nil
  end
  
  def confirm_password
    nil
  end
  
  private
  
  def self.encrypted_password(pass, salt)
    Digest::SHA256.hexdigest(pass + salt)
  end

end