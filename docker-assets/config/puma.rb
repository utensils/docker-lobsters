environment ENV.fetch("RAILS_ENV") { "development" }
port ENV.fetch("PORT") { 3000 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
plugin :tmp_restart
