# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_build_worker_session',
  :secret      => 'cf68e9b54908210e953ce84a92b793c51a6f28a1c04efa257192c8768bc1fd0625d83c7484ee676855a20fad513e69fa20e9af277db725b90ca12486db42687c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
