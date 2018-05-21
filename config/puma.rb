# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
app_dir = File.expand_path("../..", __FILE__)

threads(5, 5)

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port(ENV.fetch("PORT") {3000})

# Specifies the `environment` that Puma will run in.
#
rails_env = ENV.fetch("RAILS_ENV") {"development"}
environment(rails_env)


# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
# preload_app!

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end
pidfile "#{app_dir}/tmp/pids/puma.pid"

# Production Config
if rails_env == "production"
  # Specifies the number of `workers` to boot in clustered mode.
  # Workers are forked webserver processes. If using threads and workers together
  # the concurrency of the application would be max `threads` * `workers`.
  # Workers do not work on JRuby or Windows (both of which do not support
  # processes).
  workers 5

  # Daemonize the server into the background. Highly suggest that
  # this be combined with "pidfile" and "stdout_redirect".
  #
  # The default is "false".
  #
  # daemonize
  daemonize true

  # Redirect STDOUT and STDERR to files specified. The 3rd parameter
  # ("append") specifies whether the output is appended, the default is
  # "false".
  #
  # stdout_redirect '/u/apps/lolcat/log/stdout', '/u/apps/lolcat/log/stderr'
  # stdout_redirect '/u/apps/lolcat/log/stdout', '/u/apps/lolcat/log/stderr', true
  stdout_redirect("#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true)
end

# Allow puma to be restarted by `rails restart` command.
plugin(:tmp_restart)