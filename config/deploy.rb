require 'capistrano/puppetize'
require 'bazaar'

def fog
  @fog ||= Fog::Compute.new(
      provider: 'AWS',
      region: 'eu-west-1',
      aws_access_key_id: ENV['CODEWATCH_AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['CODEWATCH_AWS_SECRET_ACCESS_KEY']
  )
end

def find_servers
  @servers ||= fog.servers.select { |s| s.tags['Group'] == 'streamer' }
end

def find_load_balancer_servers
  @load_balancers ||= fog.servers.select { |s| s.tags['Group'] == 'load-balancer' }
end

def find_vod_servers
  @vod ||= fog.servers.select { |s| s.tags['Group'] == 'vod' }
end

def servers_to_update
  if ENV['server']
    server = (find_servers + find_load_balancer_servers + find_vod_servers).find { |s| s.dns_name == ENV['server']}
    if server
      return ["#{fetch(:user)}@#{server.dns_name}"]
    else
      raise ArgumentError, 'ServerNotFound'
    end
  elsif ENV['server_type']
    case ENV['server_type']
      when 'streamer'
        find_servers.map { |s| "#{fetch(:user)}@#{s.dns_name}" }
      when 'load_balancer'
        find_load_balancer_servers.map { |s| "#{fetch(:user)}@#{s.dns_name}" }
      when 'vod'
        find_vod_servers.map { |s| "#{fetch(:user)}@#{s.dns_name}" }
    end
  else
    (find_servers + find_load_balancer_servers + find_vod_servers).map { |s| "#{fetch(:user)}@#{s.dns_name}" }
  end
end

set :region, ENV['region'] || 'eu-west-1'
set :instance_region, ENV['instance_region'] || 'eu-west-1b'
set :codewatch_aws_access_key_id, ENV['CODEWATCH_INSTANCE_AWS_ACCESS_KEY_ID']
set :codewatch_aws_secret_access_key, ENV['CODEWATCH_INSTANCE_AWS_SECRET_ACCESS_KEY']
set :application, 'codewatch_streamer'
set :user, 'ubuntu'
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"

set :use_sudo, true
set :runner, "#{fetch(:user)}"
set :scm, :git
set :repo_url, 'git@github.com:joseairosa/codewatch_streamers.git' # thats a public path, if you want private you have to setup github public key etc stuff

set :ssh_private_key, File.expand_path("#{ENV['HOME']}/.ssh/ec2/codewatch-streamer-ec2.pem")
set :ssh_options, { keys: fetch(:ssh_private_key), forward_agent: true }

warn "Executing actions on #{servers_to_update.join(' ')}"

# role :app, *(streamer_server_ids)
role :app, servers_to_update
#%w{ubuntu@ec2-52-18-68-213.eu-west-1.compute.amazonaws.com}
