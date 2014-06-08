#!/opt/chef/embedded/bin/ruby

require 'parallel'

# default to 10 total tasks, 8 processes
total = ARGV[0].nil? ? ( 10 ) : ( ARGV[0] )
procs = ARGV[1].nil? ? ( 8 ) : ( ARGV[1] )

#def numeric_hostname(fqdn, number)
#  host = fqdn.split(".")[0]
#  domain = fqdn.split(".").drop(1).join(".")
#  host + number.to_s + "." + domain
#end

def gce_server_delete(number)
  name = "test-webserver" + number.to_s
  options = [
    "-Z us-central1-a",
    "-y",
    ].join(' ')
  command = "knife google server delete #{name} #{options}"
  system(command)
end

def gce_disk_delete(number)
  name = "test-webserver" + number.to_s
  options = [
    "-Z us-central1-a",
    "-y",
    ].join(' ')
  command = "knife google disk delete #{name} #{options}"
  system(command)
end

def chef_cleanup(number)
  name = "test-webserver" + number.to_s
  client_command = "knife client delete #{name} -y"
  node_command = "knife node delete #{name} -y"
  system(client_command)
  system(node_command)
end


Parallel.each(1..total.to_i, :in_threads=>procs.to_i) do |number|
  gce_server_delete(number)
  chef_cleanup(number)
end

puts "\n", "Waiting 90s before destroying disks...", "\n"
sleep(90)

Parallel.each(1..total.to_i, :in_threads=>procs.to_i) do |number|
  gce_disk_delete(number)
end

puts "\n", "Don't forget to clean up ~/.ssh/known_hosts", "\n"
