Semjo::Application.config.session_store :cookie_store, 
  :key => '_semanticjournal_session', 
  :expire_after => 1.hour #change this if you want longer sessions (or remove to just expire when session ends).

