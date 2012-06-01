require 'rspec/expectations'
require 'cucumber/chef'
require 'cucumber/chef/steps'
require 'cucumber/chef/helpers'

class CustomWorld
  include Cucumber::Chef
  include Cucumber::Chef::Helpers
end

World do
  CustomWorld.new
end

$servers = Hash.new(nil)

Before do
  knife_rb = Cucumber::Chef.locate(:file, ".chef", "knife.rb")
  Chef::Config.from_file(knife_rb)

  # cleanup previous lxc containers on first run
  if ($servers.size == 0)
    STDOUT.puts("  * Destroying All LXC Containers")
    STDOUT.flush if STDOUT.respond_to?(:flush)

    servers.each do |name|
      server_destroy(name)
    end
  end

  # for Opscode Hosted chef-server use this:
  #chef_set_client_config(:orgname => "cucumber-chef")

  # for Opscode OS chef-server on the Cucumber-Chef test lab use this:
  chef_set_client_config(:chef_server_url => "http://192.168.255.254:4000",
                         :validation_client_name => "chef-validator")
end

After do |scenario|
  # cleanup non-persistent lxc containers on exit
  $servers.select{ |name, attributes| !attributes[:persist] }.each do |name, attributes|
    server_destroy(name)
  end
end
