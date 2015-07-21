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

def lb
  @lb ||= Fog::AWS::ELB.new(
      region: 'eu-west-1',
      aws_access_key_id: ENV['CODEWATCH_AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['CODEWATCH_AWS_SECRET_ACCESS_KEY']
  )
end

def find_servers
  @servers ||= fog.servers.select { |s| s.tags['Group'] == 'streamer' }
end

def find_load_balancer_servers
  @load_balancers ||= fog.servers.select { |s| s.tags['Group'] == 'lb' }
end

def find_vod_servers
  @vod ||= fog.servers.select { |s| s.tags['Group'] == 'vod' }
end

def servers_to_update
  if ENV['server']
    server = (find_servers + find_load_balancer_servers + find_vod_servers).find { |s| s.dns_name == ENV['server']}
    if server
      return [server]
    else
      raise ArgumentError, 'ServerNotFound'
    end
  else
    case fetch(:stage)
      when :streamer
        find_servers
      when :load_balancer
        find_load_balancer_servers
      when :vod
        find_vod_servers
    end
  end
end

def servers_ssh
  servers_to_update.map { |s| "#{fetch(:user)}@#{s.dns_name}" }
end

set :newrelic, ENV['CODEWATCH_NEWRELIC']
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

warn "Executing actions on #{servers_to_update.map(&:public_ip_address).join(' ')}"

# role :app, *(streamer_server_ids)
role :app, servers_ssh
#%w{ubuntu@ec2-52-18-68-213.eu-west-1.compute.amazonaws.com}
