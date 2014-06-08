#!/opt/chef/embedded/bin/ruby

require 'parallel'

# default to 10 total tasks, 8 processes
total = ARGV[0].nil? ? ( 10 ) : ( ARGV[0] )
procs = ARGV[1].nil? ? ( 8 ) : ( ARGV[1] )

def gce_disk_delete(number)
  name = "test-webserver" + number.to_s
  options = [
    "-Z us-central1-a",
    "-y",
    ].join(' ')
  command = "knife google disk delete #{name} #{options}"
  system(command)
end

Parallel.each(1..total.to_i, :in_threads=>procs.to_i) do |number|
  gce_disk_delete(number)
end

puts "\n", "Don't forget to clean up ~/.ssh/known_hosts", "\n"
