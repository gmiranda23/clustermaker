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

def gce_bootstrap(number)
  name = "test-webserver" + number.to_s
  options = [
    "-Z us-central1-a",
    "--gce-image centos-6-v20140415",
    "--gce-machine-type g1-small",
    "-d chef-full",
    "-i auth/google_compute_engine",
    "-x gmiranda"
    ].join(' ')
  command = "knife google server create #{name} #{options}"
  system(command)
end

Parallel.each(1..total.to_i, :in_threads=>procs.to_i) do |number|
  gce_bootstrap(number)
end
