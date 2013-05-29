pid "log/app.pid"

worker_processes 3

preload_app true

timeout 60

stderr_path "log/app.stderr.log"
stdout_path "log/app.stdout.log"

before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end