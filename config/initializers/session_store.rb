# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_file_upload_session',
  :secret      => 'aa02ce8b6c77d23e56e63b682fbffa8f074ba9a3d1a3064f170b43040ef6288893cce89984b101c8aaceaaa96a822ac96d18908a0672f3ad268f93ee77f4e0cd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
