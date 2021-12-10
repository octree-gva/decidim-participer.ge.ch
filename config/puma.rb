# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads_min = ENV.fetch("RAILS_MIN_THREADS") { threads_count }
threads threads_min, threads_count

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV", "development")

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("RAILS_PID_FILE", Rails.root.join("tmp/pids/server.pid"))

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Set the private key for tls connection
# To disable local certificate, use the SSL_CUSTOM_CERT env. 
if ["1", "true", "enabled"].include?(ENV.fetch("SSL_CUSTOM_CERT", "false"))
    ssl_host = ENV.fetch("SSL_CERT_HOST", '0.0.0.0')
    ssl_port = ENV.fetch("SSL_CERT_PORT", '8443')
    ssl_key_path = ENV.fetch("SSL_CERT_KEY_PATH", '/certs/privkey.pem')
    ssl_cert_path = ENV.fetch("SSL_CERT_FULLCHAIN_PATH", '/certs/fullchain.pem')
    puts "Bind puma on :#{ssl_port} with custom ssl certificates"
    ssl_bind ssl_host, ssl_port, { key: ssl_key_path, cert: ssl_cert_path }
else
    puma_port = ENV.fetch("PORT", 3000)
    puts "Bind puma on :#{puma_port} with no certificates"
    # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
    port puma_port
end

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
